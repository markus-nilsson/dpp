classdef dp_node_dmri_xps_make < dp_node_dmri_xps

    methods

        function output = execute(obj, input, output)

            % Check that we have the necessary input
            if ~(isfield(input, 'bval_fn') && exist(input.bval_fn, 'file'))
                obj.log('%s: no bval_fn from previous node', input.id);
                return;
            end

            % figure out the value of b-delta
            % ideally, use the json instead of this hack
            [~,name] = msf_fileparts(input.nii_fn);

            f = @(x) ~isempty(strfind(name, x)); %#ok<STREMP>
            is_lte = f('_LTE');
            is_pte = f('_PTE');
            is_ste = f('_STE');
            is_mdt = f('_MDT');
            is_dti = f('_DTI');
            is_dki = f('_DKI');
            is_hardi = f('_hardi');
            is_resex = f('_RESEX');

            if (sum([is_lte is_pte is_ste is_mdt is_dti is_dki is_resex is_hardi]) ~= 1)
                error('could not determine sequence type')
            end

            if (is_lte) || (is_dti) || (is_resex) || (is_dki) || (is_hardi)
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