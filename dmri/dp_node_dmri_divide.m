classdef dp_node_dmri_divide < dp_node

    % XXX: Move to elsewhere
    % Divides diffusion MRI data by performing mathematical division operations. Typically used
    % for signal normalization or creating ratio maps between different acquisition conditions.

    properties
        suffix;
    end

    methods

        function obj = dp_node_dmri_divide(suffix)

            if (nargin == 0), suffix = '_div'; end

            obj.suffix = suffix;

            if (suffix(1) ~= '_'), warning('probably want _suffix'); end

            obj.input_test = {'dmri_fn', 'xps_fn', 'divisor_fn'};
            obj.output_test = {'dmri_fn', 'xps_fn'};
            
        end

        function output = i2o(obj, input)
            output.dmri_fn = dp.new_fn(input.op, input.dmri_fn, obj.suffix);
            output.xps_fn = mdm_xps_fn_from_nii_fn(output.dmri_fn);
        end

        function output = execute(obj, input, output)

            [I,h] = mdm_nii_read(input.dmri_fn);
            [J,~] = mdm_nii_read(input.divisor_fn); % Read the 3D volume to divide by

            % Check if the divisor is 3D and the dmri_fn is 4D
            if (ndims(J) ~= 3)
                error('Divisor volume must be 3D');
            end

            if ~(all(size(I,[1 2 3]) == size(J, [1 2 3])))
                error('Spatial dimensions of the volumes must match');
            end

            % Perform element-wise division for each volume in the 4D dmri_fn
            I = double(I); J = double(J);
            for t = 1:size(I, 4)
                I(:,:,:,t) = I(:,:,:,t) ./ J; 
            end

            mdm_nii_write(I, output.dmri_fn, h);


            copyfile(input.xps_fn, output.xps_fn);

        end
    end
end