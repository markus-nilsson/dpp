classdef dp_node_dmri_xps_make < dp_node_dmri_xps

    % Creates experimental parameter sets (XPS) from bval/bvec files for diffusion MRI analysis.
    % Automatically detects sequence type from filename patterns (LTE, PTE, STE, DTI, DKI, HARDI, etc.)
    % and sets appropriate b_delta values. Combines b-values, gradient directions, and encoding 
    % parameters into standardized XPS format for downstream processing and analysis.

    methods

        function obj = dp_node_dmri_xps_make()
            obj.input_test = {'dmri_fn'};
        end

        function po = po2i(~, po)

            if (~isfield(po, 'bval_fn')) && (~isfield(po, 'bvec_fn'))
                [a,b] = mdm_fn_nii2bvalbvec(po.dmri_fn);
                po.bval_fn = a;
                po.bvec_fn = b;
            end
        end

        function output = execute(obj, input, output)

            % Check that we have the necessary input
            if ~(isfield(input, 'bval_fn') && exist(input.bval_fn, 'file'))
                obj.log('%s: bval_fn missing', input.id);
                return;
            end

            if ~(isfield(input, 'bvec_fn') && exist(input.bvec_fn, 'file'))
                obj.log('%s: no bvec_fn missing', input.id);
                return;
            end
            

            % figure out the value of b-delta
            % ideally, use the json instead of this hack
            [~,name] = msf_fileparts(input.dmri_fn);

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