classdef dp_node_export_to_png < dp_node

    properties
        prefix;
        c_vol = 1;
    end

    methods

        function obj = dp_node_export_to_png(prefix, c_vol)
            obj.prefix = prefix;
            if (nargin > 1), obj.c_vol = c_vol; end

            obj.input_test = {'nii_fn'};
        end

        function output = i2o(obj, input)
            output.done_fn = fullfile(input.op, obj.prefix, 'done', input.id, cat(2, obj.prefix, '_done.txt'));
        end

        function output = execute(obj, input, output)
            
            % Load the NIfTI file
            [I, ~] = mdm_nii_read(input.nii_fn);

            I = I(:,:,:,obj.c_vol);

            % Normalize the data
            I(I < 0) = 0;
            I = I / quantile(I(:), 0.995);

            % Create output folders
            op = fullfile(output.op, obj.prefix);
            msf_mkdir(fullfile(op, 'cor'));
            msf_mkdir(fullfile(op, 'sag'));
            msf_mkdir(fullfile(op, 'tra'));

            % Save coronal slices
            for i = 1:size(I, 1)
                slice_data = squeeze(I(i, :, :));
                obj.save_slice_as_png(slice_data, fullfile(op, 'cor'), obj.prefix, input.id, i);
            end

            % Save sagittal slices
            for i = 1:size(I, 2)
                slice_data = squeeze(I(:, i, :));
                obj.save_slice_as_png(slice_data, fullfile(op, 'sag'), obj.prefix, input.id, i);
            end

            % Save transverse slices
            for i = 1:size(I, 3)
                slice_data = squeeze(I(:, :, i));
                obj.save_slice_as_png(slice_data, fullfile(op, 'tra'), obj.prefix, input.id, i);
            end

            % Save indicator
            msf_mkdir(fileparts(output.done_fn));
            mdm_txt_write({'Done, yay!'}, output.done_fn);
        end
    end

    methods (Static)
        
        function save_slice_as_png(slice_data, output_folder, prefix, id, slice_num)
        
            % Generate a reproducible unique hash based on input.id and slice number
            data_to_hash = sprintf('%s_%d', id, slice_num);
            hash = string(dp_node_export_to_png.data_hash(data_to_hash));
            filename = sprintf('%s_%s.png', prefix, hash);
            filepath = fullfile(output_folder, filename);
            
            % Save the slice as a PNG file
            imwrite(slice_data, filepath);

        end

        function hash = data_hash(data)

            engine = java.security.MessageDigest.getInstance('MD5');
            engine.update(uint8(data));
            hash = sprintf('%.2x', typecast(engine.digest(), 'uint8'));
            
        end
    end
end