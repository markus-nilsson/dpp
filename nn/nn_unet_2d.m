classdef nn_unet_2d < handle

    % methods for setting up, training, and applying 2d unet

    properties

        nn_fn;

        task = 'regression'; % or segmentation
        ori = 'tra';

        % data related
        data_mode = 'preload';
        do_augment = 1;

        % network
        lgraph;
        encoderDepth = 3;

        % training
        f_train = 0.9; % fraction used for training
        numEpochs = 500;
        learnRate = 5e-6;
        miniBatchSize = 64;
        patchesPerImage = 1;

        grad_fun = @nn_gradfuns.mse


    end

    methods

        % we have two modes: either set it up, or load it ()
        function obj = nn_unet_2d(nn_fn)
            obj.nn_fn = nn_fn;
        end

        function obj = save(obj, c_epoch)

            % Save epoch
            if (nargin > 1)
                [nn_path, nn_name] = fileparts(obj.nn_fn);
                mat_fn = fullfile(nn_path, sprintf('%s_epoch%i.mat', nn_name, c_epoch));
            else
                mat_fn = obj.nn_fn;
            end

            % Convert to struct and save
            warning off;
            my_net = struct(obj);
            warning on;
            my_net.grad_fun = char(my_net.grad_fun); % fixes some matlab probs
            save(mat_fn, 'my_net');

        end

        function obj = load(obj)

            load(obj.nn_fn, 'my_net');

            p = properties(obj);
            for c = 1:numel(p)
                try
                    obj.(p{c}) = my_net.(p{c});
                catch me
                    disp(me.message);
                end
            end

            obj.grad_fun = eval(obj.grad_fun);

        end

        function inputSize = compute_input_size(obj, sz)

            switch (obj.ori)
                case 'tra'
                    inputSize = [sz(1) sz(2) sz(4)];
                case 'sag'
                    inputSize = [sz(2) sz(3) sz(4)];
                case 'cor'
                    inputSize = [sz(1) sz(3) sz(4)];
                otherwise
                    error('not implemented');
            end

            inputSize(1:2) = floor(inputSize(1:2) / 2^obj.encoderDepth) * 2^obj.encoderDepth;

        end

        function obj = setup_unet(obj, taskName, ori, nnFiles, encoderDepth, numOutputs)

            arguments
                obj
                taskName
                ori
                nnFiles
                encoderDepth (1,1) double = 3
                numOutputs (1,1) double = 1
            end

            % Store
            obj.ori = ori;
            obj.encoderDepth = encoderDepth;


            % Determine input size
            I = mdm_nii_read(nnFiles{1}.input_fn);
            inputSize = obj.compute_input_size(size(I));

            obj.task = taskName;

            % Step 1: Create base U-Net
            obj.lgraph = unet(inputSize, max(2, numOutputs), 'EncoderDepth', encoderDepth);

            switch (obj.task)

                case 'regression'

                    % Step 2: Remove final softmax and last conv layer
                    obj.lgraph = removeLayers(obj.lgraph, {'FinalNetworkSoftmax-Layer', 'encoderDecoderFinalConvLayer'});

                    % Step 3: Add new convolution layer
                    finalConv = convolution2dLayer([1 1], numOutputs, ...
                        'Name', 'Final-ConvolutionLayer', 'Padding', 'same');
                    obj.lgraph = addLayers(obj.lgraph, finalConv);
                    obj.lgraph = connectLayers(obj.lgraph, ...
                        sprintf('Decoder-Stage-%i-ReLU-2', encoderDepth), 'Final-ConvolutionLayer');

                case 'segmentation'

                    1; % no need to do anything

                otherwise

                    error('not implemented');

            end

            % Step 4: Initialize network with dummy input
            dummyInput = dlarray(0.5 + randn(inputSize, 'single'), 'SSCB');
            obj.lgraph = initialize(obj.lgraph, dummyInput);

        end

    end

    methods % application

        function apply(obj, input_fn, target_fn, output_fn)

            % input_fn: nifti file to transform
            % target_fn: provides nifti header, and scale, for regression
            %
            %             if empty, use input_fn

            if (isempty(target_fn))
                target_fn = input_fn;
            end

            % Decide on trim action (not sure this is good/necessary, but
            % we need some consistency here, perhaps this should be done
            % in training too... seems like it already does this)
            I = mdm_nii_read(input_fn);
            inputSize = obj.compute_input_size(size(I));


            % Read frmo nii, transform to dlarray, and put in batch
            ds1 = nn_datastore_nii_mem_2d({input_fn}, obj.ori);
            ds2 = transform(ds1, @(x) dlarray(single(x(1:inputSize(1),1:inputSize(2),:)), 'SSC'));


            if (1) % lean on memory
                f = @(x) squeeze(extractdata(gather(x)));

                ds3 = minibatchqueue(ds2, ...
                    'MiniBatchSize', 1, ...
                    'MiniBatchFormat', 'SSCB', ...
                    'OutputAsDlarray', true);

                for c = 1:ds1.NumObservations
                    X = ds3.next();
                    Yp(:,:,:,c) = f(forward(obj.lgraph, X));
                    Xp(:,:,:,c) = f(X);
                end

            else
                
                ds3 = minibatchqueue(ds2, ...
                    'MiniBatchSize', ds1.NumObservations, ...
                    'MiniBatchFormat', 'SSCB', ...
                    'OutputAsDlarray', true);

                X = ds3.next();
                Yp = forward(obj.lgraph, X);

                % Convert to matrices
                Yp = squeeze(extractdata(gather(Yp)));
            end

            switch (obj.ori)
                case 'tra'
                    Yp = permute(Yp, [1 2 4 3]);
                case 'cor'
                    Yp = permute(Yp, [1 4 2 3]);
                otherwise
                    error('not implemented');

            end
            

            I = zeros(size(I, 1), size(I, 2), size(I, 3), size(Yp, 4));
            I(1:size(Yp,1), 1:size(Yp,2), 1:size(Yp,3), :) = Yp;
            Yp = I;

            % Load output (to get header, possibly for scaling)
            [Y,h] = mdm_nii_read(target_fn);

            % Modify if relevant
            switch (obj.task)
                case 'regression'
                    Yp = Yp * quantile(Y(:), 0.99);
                case 'segmentation'
                    1;
            end

            % Save
            mdm_nii_write(Yp, output_fn, h);

        end

    end

    methods % training

        function train(obj, training_data)

            % training data: cell array of structures with
            % input_fn and output_fn

            % Prepare data
            data.inputSize = obj.lgraph.Layers(1).InputSize;
            [data.input, data.output, n] = obj.nn_prep_data(training_data);

            % Split into train and validation
            [data_train, data_val] = obj.split_train_val(data, n);


            fprintf('Training for %d epochs with learning rate %.1e\n', ...
                obj.numEpochs, obj.learnRate);

            c = 1;
            trailingAvg = [];
            trailingAvgSq = [];

            train_loss = zeros(1, obj.numEpochs);             
            val_loss = zeros(1, obj.numEpochs);             

            for c_epoch = 1:obj.numEpochs

                % Create patch datastore (once per epoch to get random
                % samples)
                mbq = obj.get_minibatch(data_train);

                n_eval = 0;

                while hasdata(mbq)
                    

                    % Grab data
                    [X, Y] = next(mbq);

                    % Skip batch if not fulfilling criteria
                    if (~obj.test_minibatch(X, Y)), continue; end

                    % Compute gradients and loss
                    [loss, gradients] = dlfeval(obj.grad_fun, ...
                        obj.lgraph, X, Y);

                    % Update network using Adam
                    [obj.lgraph, trailingAvg, trailingAvgSq] = adamupdate(...
                        obj.lgraph, gradients, ...
                        trailingAvg, trailingAvgSq, c, obj.learnRate);

                    % Update stats
                    train_loss(c_epoch) = train_loss(c_epoch) + extractdata(loss);
                    n_eval = n_eval + 1;

                    % Plotting
                    if (mod(c-1, 100) == 0)
                        Yp = forward(obj.lgraph, X);
                        obj.nn_plot(c_epoch, c, loss, X, Y, Yp, train_loss, val_loss);
                    end
                    

                    c = c + 1;

                end

                train_loss(c_epoch) = train_loss(c_epoch) / max(n_eval, 1);



                % ---- Validation (end of epoch) ----

                n_eval = 0;

                mbqVal = obj.get_minibatch(data_val);

                while hasdata(mbqVal)

                    [X, Y] = next(mbqVal);

                    if (~obj.test_minibatch(X, Y)), continue; end

                    % Forward only, no dlfeval, no gradients
                    tmp = dlfeval(obj.grad_fun, obj.lgraph, X, Y);

                    val_loss(c_epoch) = val_loss(c_epoch) + extractdata(tmp);
                    n_eval = n_eval + 1;
                end

                val_loss(c_epoch) = val_loss(c_epoch) / max(n_eval,1);


                % Allow save every n:th epoch
                if (mod(c_epoch, 5) == 0)
                    obj.save(c_epoch);
                end

                fprintf("Epoch %d, Loss = %.6f, Val Loss = %.6f\n", c_epoch, ...
                    train_loss(c_epoch), val_loss(c_epoch));
            end



            obj.save();

        end

    end

    methods % data management

        function [inputData, outputData, n] = nn_prep_data(obj, outputs)

            arguments
                obj
                outputs % cell list with input_fn, output_fn
            end

            % Load input and output data based on loading mode
            switch obj.data_mode

                case 'preload'

                    disp('Preloading data...');
                    f = @(field_name) cellfun(@(r) r.(field_name),  outputs, 'UniformOutput', false);
                    inputData  = nn_datastore_nii_mem_2d(f('input_fn'), obj.ori);
                    outputData = nn_datastore_nii_mem_2d(f('output_fn'), obj.ori);
                    disp('...done');

                case 'ondemand'
                    error('On-demand mode not implemented yet.');

                otherwise
                    error('Unsupported data_mode: %s', obj.data_mode);
            end

            % Format for network input
            asArray = @(x) {single(x(:, :, :, :))};
            inputData  = transform(inputData, asArray);
            outputData = transform(outputData, asArray);

            % Eliminate empty input slices (implement as a function in its own)
            switch (obj.ori)
                case 'tra'
                    ind = [1 2 4];
                case 'cor'
                    ind = [1 2 4]; % cor appears as tra slices, for now
                otherwise
                    error('not yet implemented');
            end

            ind = inputData.transform(@(x) squeeze(sum(x{1}, ind))).readall();
            ind = find(ind > 0);

            inputData = inputData.partition([], ind);
            outputData = outputData.partition([], ind);

            n = numel(ind);

        end

        function dataOut = nn_augment(obj, dataIn)

            dataOut = dataIn;

            % Random flip
            for c = 1:size(dataIn, 1)

                if (rand < 0.5)
                    dataOut{c,1}{1} = flip(dataIn{c,1}{1}, 1);
                    dataOut{c,2}{1} = flip(dataIn{c,2}{1}, 1);
                end

                if (rand < 0.5)
                    dataOut{c,1}{1} = flip(dataIn{c,1}{1}, 2);
                    dataOut{c,2}{1} = flip(dataIn{c,2}{1}, 2);
                end

            end

        end

        function [X,Y] = minibatchpreprocess(obj, X,Y)
            X = cat(4, X{:});
            Y = cat(4, Y{:});
        end

        function mbq = get_minibatch(obj, data)

            patchDs = randomPatchExtractionDatastore(...
                data.input, ...
                data.output, ...
                data.inputSize(1:2), ...
                'PatchesPerImage', obj.patchesPerImage, ...
                'DataAugmentation', 'none');

            if (obj.do_augment)
                augPatchDs = transform(patchDs, @(data) obj.nn_augment(data));
            else
                augPatchDs = patchDs;
            end

            mbq = minibatchqueue(augPatchDs, ...
                'MiniBatchSize', obj.miniBatchSize, ...
                'MiniBatchFcn', @(x,y) obj.minibatchpreprocess(x,y), ...
                'MiniBatchFormat', {'SSCB', 'SSCB'}, ...
                'OutputAsDlarray', true);

            mbq.reset();
        end

        function do_pass = test_minibatch(obj, X, Y)

            do_pass = 1;

            switch (obj.task)
                case 'regression'
                    return;
                case 'segmentation' % 1 - background mask, 2 - need segments in batch
                    do_pass = gather(extractdata(sum(Y(:,:,2:end,:), [1 2 3 4]))) > 0;
            end

        end

        function [train, val] = split_train_val(obj, data, n)            

            ind_train = rand(1,n) <= obj.f_train;
            ind_val = find(~ind_train);
            ind_train = find(ind_train);

            train.input  = data.input.partition([], ind_train);
            train.output = data.output.partition([], ind_train);
            train.inputSize = data.inputSize;

            val.input  = data.input.partition([], ind_val);
            val.output = data.output.partition([], ind_val);
            val.inputSize = data.inputSize;
            

        end


    end


    methods % plotting

        function nn_plot(obj, c_epoch, c, loss, X, Y, Yp, tl, vl)

            if (c == 1), msf_clf; end


            subplot(2,2,1);
            semilogy(c, gather(extractdata(loss)), 'ko');
            hold on;
 
            subplot(2,2,3); cla;
            semilogy(tl(1:c_epoch), 'ko'); hold on;
            semilogy(vl(1:c_epoch), 'ro');

            switch (obj.task)
                case 'segmentation'

                    ind = find(extractdata(gather(squeeze(sum(Y(:,:,2:end,:), [1 2 3]) > 0))));

                    if (numel(ind) == 0)
                        return;
                    end

                otherwise
                    ind = 1;
            end

            g = @(x) x(:,:,1,ind(1));
            f = @(x) g(gather(extractdata(x)));

            subplot(2,2,2);
            msf_imagesc(cat(1, f(X), f(Y), f(Yp)));
            clim([0 1.4]);

            subplot(2,2,4);
            msf_imagesc(f(Y) - f(Yp));
            clim([-1 1] * 0.2);

            pause(0.05);
        end

    end

end
