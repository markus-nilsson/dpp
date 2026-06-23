classdef dp_node_imop_merge < dp_node

    % dp_node_imop_merge(fields, filename)
    % Merge input.(fields) into filename in input.op

    properties
        filename;
        fields;
        do_normalize;
    end


    methods

        function obj = dp_node_imop_merge(fields, filename, do_normalize)
            if (nargin < 3), do_normalize = 0; end
            obj.fields = fields;
            obj.filename = filename;
            obj.do_normalize = do_normalize;

            obj.input_test = fields;
            obj.output_test = {'nii_fn'};
        end

        function output = i2o(obj, input)

            output.nii_fn = fullfile(input.op, obj.filename);

        end

        function output = execute(obj, input, output)

            J = [];
            for c = 1:numel(obj.fields)

                [I,h] = mdm_nii_read(input.(obj.fields{c}));

                if (obj.do_normalize)
                    I = I / quantile(abs(I(:)), 0.99);
                end

                J = cat(4, J, I);
                    
            end

            mdm_nii_write(J, output.nii_fn, h);

        end

    end

end