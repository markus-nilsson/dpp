classdef dp_node_nn_2d_unet < dp_node

    properties
        net = [];
        suffix;
    end

    methods

        function obj = dp_node_nn_2d_unet(nn_fn, suffix)

            if (nargin < 2), suffix = ''; end

            if (exist(nn_fn, 'file'))
                obj.net = nn_unet_2d(nn_fn).load();
            else
                error('cannot find the network');
            end

            if (numel(suffix) > 0) && (suffix(1) ~= '_')
                suffix = cat(2, '_', suffix);
            end

            obj.suffix = suffix;

            % test declaration
            obj.input_test = {'input_fn'};
            obj.output_test = {'nii_fn'};
        end

        function output = i2o(obj, input)            
            output.nii_fn = dp.new_fn(input.op, input.input_fn, obj.suffix);
        end

        function output = execute(obj, input, output)
            obj.net.apply(input.input_fn, input.output_fn, output.nii_fn);
        end

    end

end

