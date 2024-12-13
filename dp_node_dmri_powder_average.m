classdef dp_node_dmri_powder_average < dp_node_dmri

    % coregistration of fa using flirt

    methods


        function output = i2o(obj, input)

            output.dmri_fn = dp.new_fn(input.op, input.dmri_fn, '_pa');
            output.xps_fn = mdm_xps_fn_from_nii_fn(output.dmri_fn);

            % preserve mask, if it exists
            if (isfield(input, 'mask_fn')), output.mask_fn = input.mask_fn; end

        end

        function output = execute(obj, input, output)

            s.nii_fn = input.dmri_fn;
            s.xps = mdm_xps_load(input.xps_fn);

            mdm_s_powder_average(s, input.op);

        end

    end
end