classdef dp % data processor

    % we are working with input and output structures, with some rules
    % embedded here

    % fields that are expected of the input and output structures
    %
    % id - uniquely defines a subject or subject/date
    % bp - base path
    % *_fn - filenames, will be checked if they exist
    %
    % in addition, it could have these field(s):
    %
    % tmp - temporary info, with fields
    %   bp - base path
    %   do_delete - determines whether the path will be deleted after
    %   execution



    % to dos: add name filtering, enable options pass-through


    methods (Static)

        function outputs = run(node, mode, tmp)

            if (nargin < 2), mode = 'report'; end
            if (nargin < 3), tmp = []; end

            % options argument
            %   assume it is an id filter if it is a string or cell array,
            %   otherwise make sure it is a structure
            if (isempty(tmp))
                opt.present = 1;
            elseif (isstruct(tmp))
                opt = tmp;
            elseif (ischar(tmp))
                opt.id_filter = {tmp};
            elseif (iscell(tmp))
                opt.id_filter = tmp;
            end

            % deal with options
            opt = msf_ensure_field(opt, 'c_level', 0); 
            opt.c_level = opt.c_level + 1;

            opt.indent = zeros(1, 2*(opt.c_level - 1)) + ' ';

            opt.log = @(varargin) fprintf(cat(2, '%s', varargin{1}, '\n'), opt.indent, varargin{2:end});
            
            % Report on status
            
            if (opt.c_level == 1)
                opt.log(' ');
                opt.log('Available modes: report, debug, execute, and iter');
                opt.log(' ');
            end

            opt.node_name = class(node);
            opt.log('Running %s with mode ''%s''', opt.node_name, mode);

            outputs = dp.run_on_all(node, mode, opt);

            if (opt.c_level == 1)
                opt.log(' ');
            end

        end

        function outputs = run_on_all(node, mode, opt)

            % Configure options
            switch (mode)
                case 'execute'
                    opt.verbose = 1;
                case 'report'
                case 'debug' % do not capture errors here
                    opt.do_try_catch = 0;
                    opt.verbose = 1;
                case 'visualize'
                    1;
                case 'iter' % grab outputs
                    opt.verbose = 0; % force it to be off here
                case 'mgui'
                    1;
                otherwise
                    error('output mode unknown');
            end

            opt = msf_ensure_field(opt, 'verbose', 0);
            opt = msf_ensure_field(opt, 'do_try_catch', 1);
            opt = msf_ensure_field(opt, 'id_filter', {});
            

            % Run previous steps first to get items to iterate over
            opt = msf_ensure_field(opt, 'iter_mode', 'iter');
            previous_outputs = node.get_iterable(opt);

            opt.log('Found %i candidate items', numel(previous_outputs));

            % Filter and exclude items
            [previous_outputs,opt] = dp.exclude_items(previous_outputs, opt);
            [previous_outputs,opt] = dp.filter_items(previous_outputs, opt);


            % Check before we move on
            if (numel(previous_outputs) == 0)
                opt.log('Iteration list empty - no actions will be taken!');
                outputs = {};
                return;
            end


            % Run iterations, save outputs

            if (opt.c_level == 1)
                opt.log(' ');
                opt.log('Starting iterations for mode: %s', mode);
                opt.log(' ');
            end


            % Decide on what to execute
            switch (mode)
                case 'execute'
                    fn = @(ip, op) dp.execute_on_one(node, ip, op, opt);
                case 'report'
                    fn = @(ip, op) dp.report_on_one(ip, op);
                case 'debug' 
                    fn = @(ip, op) dp.execute_on_one(node, ip, op, opt);
                case 'visualize'
                    fn = @(ip, op) dp.visualize_on_one(ip, op, opt);
                case 'iter' 
                    fn = @(ip, op) dp.iter_on_one(ip, op, opt);
                case 'mgui'
                    fn = @(ip, op) dp.iter_on_one(ip, op, opt);
            end

            run_fun = @(input, output) dp.run_on_one(fn, input, output, opt);


            n_errors = struct('input', 0, 'output', 0, 'run', 0);
            outputs = {};
            
            % initialize for later use
            input = []; output = []; 

            for c = 1:numel(previous_outputs) % loop over inputs

                pop = previous_outputs{c};

                if (~msf_isfield(pop, 'id'))
                    error('id field missing');
                end

                % add current options if options is missing
                % (this is a critical information flow issue, where
                % there will be bugs creeping up)
                if (~isfield(pop, 'opt')), pop.opt = opt; end

                % compute input to this node from previous output
                try
                    input = node.po2i(pop);
                    input = msf_ensure_field(input, 'id', pop.id);

                    [inputs_exist, f] = dp.io_exist(input);
                    if (~isempty(inputs_exist)) && (~all(inputs_exist))
                        f = f(~inputs_exist);
                        error('Missing input: %s', dp.join_cell_str(f') );
                    end

                catch me
                    if (opt.verbose) || (strcmp(mode, 'report'))
                        fprintf('%s --> %s (input err)\n', pop.id, me.message);
                    end
                    n_errors.input = n_errors.input + 1;
                    continue;
                end

                % compile output filenames
                try
                    output = node.i2o(input);
                    output = msf_ensure_field(output, 'id', input.id);
                catch me
                    if (opt.verbose) || (strcmp(mode, 'report'))
                        fprintf('%s --> %s (output err)\n', input.id, me.message);
                    end
                    n_errors.output = n_errors.output + 1;
                    continue;
                end

                % execute the command
                if (opt.do_try_catch)
                    try
                        outputs{end+1} = run_fun(input, output);
                    catch me
                        if (opt.verbose)
                            fprintf('%s --> %s\n', input.id, me.message);
                        end
                        n_errors.run = n_errors.run + 1;
                        continue;
                    end
                else
                    outputs{end+1} = run_fun(input, output);
                end

                % clean up temporary directory if asked to do so
                if (isstruct(output)) && (isfield(output, 'tmp')) && ...
                        (isfield(output.tmp, 'do_delete')) && ...
                        (output.tmp.do_delete)

                    msf_delete(output.tmp.bp);

                end

            end

            % Wrap up with some reporting
            switch (mode)
                case 'report'

                    f = @(x) isfield(x, 'status') && (strcmp(x.status, 'done'));
                    n_done = sum(cellfun(f, outputs));

                    opt.log(' ');
                    opt.log('Status: %i done (all ouputs is Y) out of %i possible', ...
                        n_done, numel(previous_outputs));

                    if (isstruct(input))
                        disp(' ');
                        disp('Example of input structure');
                        disp(input)
                    end

                    if (isstruct(output))
                        disp(' ');
                        disp('Example of output structure');
                        disp(output)
                    end

                case 'iter'

                    if (n_errors.input > 0)
                        opt.log('Excluding %i items due to errors in input', n_errors.input);
                    end

                    if (n_errors.run > 0)
                        opt.log('Excluding %i items due to missing output', n_errors.run);
                    end

                    if (n_errors.output > 0)
                        opt.log('Excluding %i items due to other erros (should be 0)', n_errors.output);
                    end

                case 'mgui'

                    %
                    dp.open_mgui(outputs, node, opt);
   

            end
        end

        function [outputs, opt] = exclude_items(inputs, opt)

            opt = msf_ensure_field(opt, 'id_exclude', {});
            opt = msf_ensure_field(opt, 'log', @()1);

            if (isempty(opt.id_exclude))
                outputs = inputs;
                return;
            end            

            ind_included = ones(size(inputs)) == 1;
            ind_excluded = ones(size(opt.id_exclude)) == 0;
            for c_exclude = 1:numel(opt.id_exclude)
                for c = 1:numel(inputs)
                    if (strcmp(inputs{c}.id, opt.id_exclude{c_exclude}))
                        ind_included(c) = 0;
                        ind_excluded(c_exclude) = 1;
                        break;
                    end
                end
            end

            outputs = inputs(ind_included);

            % speed up this function by trimming this list
            opt.id_exclude = opt.id_exclude(~ind_excluded);

            opt.log('Excluding %i items due to opt.id_exclude', ...
                sum(ind_excluded));

        end

        function [outputs, opt] = filter_items(inputs, opt)

            opt = msf_ensure_field(opt, 'id_filter');

            if (isempty(opt.id_filter))
                outputs = inputs;
                return;
            end

            if (~iscell(opt.id_filter))
                opt.id_filter = {opt.id_filter};
            end

            % Filter the list, if asked for
            status = ones(size(inputs)) == 0;
            for c = 1:numel(inputs)
                for c2 = 1:numel(opt.id_filter) % assume this is a cell array
                    if (strcmp(inputs{c}.id, opt.id_filter{c2}))
                        status(c) = 1 > 0;
                        break;
                    end
                end
            end

            % Avoid repeated displays
            if (numel(inputs) > 1)
                opt.log('--> Input filter active: %i out of %i ids passed', ...
                    sum(status), numel(inputs));
            end

            outputs = inputs(status);

        end

        function output = run_on_one(fn, input, output, opt)

            if (opt.verbose), fprintf('Processing: %s\n', input.id); end

            output = fn(input, output);

            if (opt.verbose), fprintf(' --> DONE\n'); end

        end


        function output = execute_on_one(node, input, output, opt)

            opt = msf_ensure_field(opt, 'do_overwrite', 0);

            % not sure this is how we should do it, but let's try
            output = msf_ensure_field(output, 'opt', struct('present', 1));
            output.opt = msf_ensure_field(output.opt, 'do_overwrite', 0);

            if (output.opt.do_overwrite)
                opt.do_overwrite = output.opt.do_overwrite;
            end
            
            outputs_exist = dp.io_exist(output);

            if (all(outputs_exist)) && (~opt.do_overwrite)
                if (opt.verbose), disp('All outputs exist, skipping'); end
                return;
            end

            output = node.execute(input, output);
            
        end


        function output = report_on_one(input, output)

            str = input.id;

            for c_iter = 1:2

                switch (c_iter)

                    case 1
                        my_struct = input;
                    case 2
                        my_struct = output;
                end

                if (isstruct(my_struct))

                    % report on the existance of files
                    status = dp.io_exist(my_struct);

                    for c = 1:numel(status)
                        str = sprintf('%s\t%s', str, 'N' + status(c) * ('Y' - 'N'));
                    end

                    % check if we are done
                    if (c_iter == 2) && (all(status))
                        output.status = 'done';
                    end
                end

                if (c_iter == 1)
                    str = sprintf('%s\t-->', str);
                end
            end

            str = sprintf('%s\n', str);

            fprintf(str);


        end

        % visualize
        function output = visualize_on_one(input, output, opt)

            % Determine conditions
            if (~isfield(output, 'vis'))
                opt.log('%s: output.vis missing, do not know what to show', output.id);
                return;
            end

            vis = output.vis;

            if (~isfield(vis, 'field_names'))
                opt.log('%s: output.vis.nii_fns missing, do not know what to show', output.id);
                return;
            end

            if (~isfield(vis, 'bp'))
                opt.log('%s: output.vis.bp missing, do not know where to output', output.id);
                return;
            end

            for c = 1:numel(vis.field_names) % expect a cell array

                field_name = vis.field_names{c};

                % Determine output name
                msf_mkdir(vis.bp);

                name = output.id;
                name = strrep(name, '/', '_');
                name = strrep(name, '\', '_');

                name = strcat(name);
                
                output.img_fns{c} = fullfile(vis.bp, ...
                    opt.node_name, field_name, [name '.png']);


                % Find nii filename
                nii_fn = output.(field_name);

                if (~exist(nii_fn, 'file'))
                    opt.log('%s: %s not found (%s)', outout.id, nii_fn, field_name);
                    continue; 
                end

                [I,h] = mdm_nii_read(nii_fn);

                I = mgui_misc_flip_volume(I, mdm_nii_oricode(h), 'LAS');

                nk = min(25, size(I,3));
                kmod = round(size(I,3) / nk);
                k = max(1, round( (size(I,3) - nk * kmod) / 2));


                ni = 1 + floor(sqrt(nk));
                nj = ceil(nk / ni);

                B = [];
                for i = 1:ni
                    A = [];
                    for j = 1:nj
                        if (k > size(I,3))
                            A = cat(1, A, zeros(size(I, [1 2])));
                        else
                            A = cat(1, A, I(:,:,k, 1));
                        end
                        k = k + kmod;
                    end
                    B = cat(2, B, A);
                end

                msf_clf;
                msf_imagesc(B);
                [~,name] = msf_fileparts(nii_fn);
                title(strrep(name, '_', ' '));
                colormap gray;
                clim([0 quantile(B(:), 0.99)]);
                pause(0.1);

                msf_mkdir(fileparts(output.img_fns{c}));
                print(output.img_fns{c}, '-dpng');
                opt.log('%s: %s done', output.id, field_name);


            end

        end

        % return output, if it is a valid input
        function output = iter_on_one(input, output, opt)

            if (~all(dp.io_exist(output)))
                error('Output missing, not a valid iter item');
            end

        end



        % run a function on the input/output structures
        function [status, f] = io_exist(io)

            % select fields with names ending with _fn
            f = fieldnames(io);
            f = f(cellfun(@(x) ~isempty(strfind(x(max(1,(end-2)):end), '_fn')), f));

            % Report the presence of the files
            status = zeros(size(f));
            for c = 1:numel(f)
                status(c) = exist(io.(f{c}), 'file') == 2;

                % allow empties to pass
                if (isempty(io.(f{c})))
                    status(c) = 1; 
                end
            end

            1;
            status2 = cellfun( @(x) exist(io.(x), 'file') == 2, f);

            1;

        end


        % merge output streams
        function outputs = merge_outputs(list_of_outputs, list_of_prefixes)

            % list_of_outputs - a cell list of outputs
            %
            % can be merged if they have the same id

            outputs = {};
            for c = 1:numel(list_of_outputs)

                for c3 = 1:numel(list_of_outputs{c})

                    % current output
                    co = list_of_outputs{c}{c3};

                    % search for id's in existing list of outputs
                    c_match = -1;
                    for c2 = 1:numel(outputs)
                        if (strcmp(co.id, outputs{c2}.id))
                            c_match = c2;
                            break;
                        end
                    end

                    % take action
                    if (c_match == -1) % no match found
                        outputs{end+1}.id = co.id;
                        c_match = numel(outputs);
                    end

                    % add fields to existing
                    f = fieldnames(co);
                    outputs{c_match}.(list_of_prefixes{c}) = 1;
                    for c2 = 1:numel(f)
                        outputs{c_match}.([list_of_prefixes{c} '_' f{c2}]) = co.(f{c2});
                    end

                end
            end

            % only keep those with all prefixes present
            status = zeros(size(outputs)) == 1;
            for c = 1:numel(outputs)
                status(c) = all(cellfun(@(x) isfield(outputs{c}, x), list_of_prefixes));
            end

            outputs = outputs(status);

            % delete the prefixes
            for c = 1:numel(outputs)
                for c2 = 1:numel(list_of_prefixes)
                    outputs{c} = rmfield(outputs{c}, list_of_prefixes{c2});
                end
            end

        end


        function str = join_cell_str(f)

            g = @(x) x(1:(end-3));
            
            str = g(cell2mat(cellfun(@(x) cat(2, x, ' / '), f, ...
                'UniformOutput', false)));
        end


        function open_mgui(outputs, node, opt)


            c_item = 1;
            for c = 1:numel(outputs)

                output = outputs{c};

                f = fieldnames(output);

                for c2 = 1:numel(f)

                    try 
                        if (~contains(f{c2}, '_fn')), continue; end
                        if (~contains(output.(f{c2}), '.nii.gz')), continue; end
                    catch me
                        disp(me.message);
                    end

                    id = strrep(output.id, '/', ' ');

                    ref.name = sprintf('%s: %s', id, f{c2});
                    ref.id = output.id;
                    ref.fn = output.(f{c2});
                    ref.f  = f{c2};

                    ref.output = output;

                    ref.roi_bp = fullfile(output.bp, '..', 'roi_dp', output.id, class(node));

                    EG.data.ref(c_item) = ref;
                    c_item = c_item + 1;

                end

            end
            
            % add ROI lists later
            if (~isfield(outputs{1}, 'roi'))

                EG.data.roi_list = {'tmp'};
                EG.data.nii_fn_to_roi_fn = @(c_subject, c_roi) dp.make_roi_fn(c_subject, c_roi, EG);
                EG.roi.do_save = 0;

            else

                roi = outputs{1}.roi;
                roi = msf_ensure_field(roi, 'do_save', 1);

                EG.data.roi_list = roi.names;
                EG.data.nii_fn_to_roi_fn = @(a,b)dp.make_roi_fn2(EG.data.ref(a),b);
                EG.roi.do_save = roi.do_save;

            end

            EG.conf.slice_mode = 'retain_slice';
            
            h_fig = mgui_misc_get_mgui_fig();

            if (~isempty(h_fig)), close(h_fig); end

            mgui(EG, 3);


        end

        function roi_fn = make_roi_fn2(ref, c_roi)
            roi_fn = ref.output.roi.roi_fns{c_roi};
        end
        

        function roi_fn = make_roi_fn(c_subject, c_roi, EG)

            ref = EG.data.ref(c_subject); 

            roi_name = [EG.data.roi_list{c_roi} '_' ref.f];
            roi_name = lower(strrep(roi_name, ' ', '_'));

            ext = '.nii.gz';

            roi_fn = fullfile(ref.roi_bp, [roi_name ext]);

        end

    end
end