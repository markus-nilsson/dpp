classdef dp_node_dmri < dp_node

    % Base class for diffusion MRI processing nodes. Provides common helper methods
    % and utilities for handling diffusion data, including automatic XPS file handling.

    methods
        
        function obj = dp_node_dmri()
            obj.input_spec.add('dmri_fn', 'file', 1, 1, 'Diffusion MRI nifti file');
            obj.input_spec.add('xps_fn', 'file', 0, 1, 'Experimental parameter set file (auto-generated if not provided)');
        end

        function input = po2i(obj, po)
            input = po;
            if (~isfield(input, 'xps_fn'))
                input.xps_fn = mdm_xps_fn_from_nii_fn(input.dmri_fn);
            end
        end
    end
end