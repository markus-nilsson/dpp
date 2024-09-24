classdef dp_node_make_xps < dp_node

    methods

        function obj = dp_node_make_xps()
            obj.output_test = {'nii_fn', 'xps_fn'};
        end

        function input = po2i(obj, po)
            
            if ~(isfield(po, 'bval_fn') && exist(po.bval_fn, 'file'))
                error('no bval_fn from previous node');
            end

            input = po;
        end

        function output = i2o(obj, input)
            output = input;
            output.xps_fn = mdm_xps_fn_from_nii_fn(input.nii_fn);
        end

        function output = execute(obj, input, output)

            % figure out the value of b-delta
            % ideally, use the json instead of this hack
            [~,name] = msf_fileparts(input.nii_fn);

            f = @(x) ~isempty(strfind(name, x)); %#ok<STREMP>
            is_lte = f('_LTE');
            is_pte = f('_PTE');
            is_ste = f('_STE');
            is_mdt = f('_MDT');
            is_dti = f('_DTI');
            is_resex = f('_RESEX');

            if (sum([is_lte is_pte is_ste is_mdt is_dti is_resex]) ~= 1)
                error('could not determine sequence type')
            end

            if (is_lte) || (is_dti) || (is_resex)
                b_delta = 1;
            elseif (is_pte)
                % validation required
                b_delta = -0.5;
                error('some validation required here')
            elseif (is_ste)
                b_delta = 0;
            elseif (is_mdt)
                b_delta = 0;
            else
                error('should not happen');
            end

            xps = mdm_xps_from_bval_bvec(...
                input.bval_fn, input.bvec_fn, b_delta);

            mdm_xps_save(xps, output.xps_fn);

        end
    end
end