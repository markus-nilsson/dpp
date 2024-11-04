classdef dp_node_dmri_flirt_apply < dp_node_fsl_flirt_apply

    % coregistration of fa using flirt
    %
    % expected outputs from previous node
    % - dmri_fn 
    % - matrix_fn - from a previous flirt registration
    % - xps_fn (optional, will create if needed)
    % - mask_fn (optional)

    methods

        function input = po2i(obj, po)
            input = po;
            input.nii_fn = po.dmri_fn;

            if (~isfield(input, 'xps_fn'))
                input.xps_fn = mdm_xps_fn_from_nii_fn(po.dmri_fn);
            end
        end

        function output = i2o(obj, input)

            f = @(a,b,c) msf_fn_new_path(a, msf_fn_append(b, c));
            output.dmri_fn = f(input.op, input.dmri_fn, '_flirt');

            output.nii_fn = output.dmri_fn;

            if (isfield(input, 'mask_fn'))
                output.mask_fn = f(input.op, input.mask_fn, '_flirt');
            end

        end

        function output = execute(obj, input, output)

            output = execute@dp_node_fsl_flirt_apply(obj, input, output);

            % apply to mask, if passed along
            if (isfield(input, 'mask_fn'))
                tmp_input = input;
                tmp_input.nii_fn = input.mask_fn;
                tmp_output = output;
                tmp_output.nii_fn = output.mask_fn;

                execute@dp_node_fsl_flirt_apply(obj, tmp_input, tmp_output);
            end

            % rotate the xps (unverified code)
            
            tmp = mdm_txt_read(input.matrix_fn);

            tmp = cellfun(@(x) str2num(x)', tmp, 'UniformOutput', false);
            tmp = cell2mat(tmp);
            tmp = tmp(1:3,1:3);

            R = tmp;

            xps = mdm_xps_load(input.xps_fn);

            for c = 1:xps.n
                xps.bt(c,:) = tm_3x3_to_1x6(R * tm_1x6_to_3x3(xps.bt(c,:)) * R');
            end

            if (isfield(xps, 'u'))
                xps.u = xps.u * R';
            end

            mdm_xps_save(xps, mdm_xps_fn_from_nii_fn(output.dmri_fn));

        end    
    end
end