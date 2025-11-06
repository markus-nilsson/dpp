classdef dp_node_make_xps < dp_node_dmri_xps_make

    % Legacy wrapper for XPS creation from NIfTI files. Provides backward compatibility
    % for older processing pipelines that use different input naming conventions.
    % XXX: Will be removed in future releases

    methods
        
        function obj = dp_node_make_xps()
            obj = obj@dp_node_dmri_xps_make();
            
            obj.input_spec.add('nii_fn', 'file', 1, 1, 'Nifti file (legacy input)');
        end

        function input = po2i(obj, po)
            input = po;
            input.dmri_fn = po.nii_fn;
        end

    end

end