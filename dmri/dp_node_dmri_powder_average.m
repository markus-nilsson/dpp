classdef dp_node_dmri_powder_average < dp_node_dmri

    % Computes powder-averaged diffusion data by averaging signal across all diffusion encoding
    % directions. Creates rotationally invariant diffusion measurements for analysis.

    properties
        do_std = 1;
    end

    methods

        function obj = dp_node_dmri_powder_average(do_std)

            if (nargin > 0)
                obj.do_std = do_std;
            end

            obj.input_test = {'dmri_fn'};
            obj.output_test = {'dmri_fn'};

            if (obj.do_std)
                obj.output_test{end+1} = 'std_fn';
            end

            
        end


        function output = i2o(obj, input)

            output.dmri_fn = dp.new_fn(input.op, input.dmri_fn, '_pa');
            output.xps_fn = mdm_xps_fn_from_nii_fn(output.dmri_fn);

            if (obj.do_std)
                output.std_fn = dp.new_fn(input.op, input.dmri_fn, '_pa_std');
            end

            % preserve mask, if it exists
            if (isfield(input, 'mask_fn')), output.mask_fn = input.mask_fn; end

        end

        function output = execute(obj, input, output)

            s.nii_fn = input.dmri_fn;
            s.xps = mdm_xps_load(input.xps_fn);

            opt.mdm.pa_std = obj.do_std;
            mdm_s_powder_average(s, input.op, opt);

        end

    end
end