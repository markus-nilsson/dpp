classdef dp_node_make_xps < dp_node_dmri_xps_make

    % Legacy wrapper for XPS creation from NIfTI files. Provides backward compatibility
    % for older processing pipelines that use different input naming conventions.

    methods

        function input = po2i(obj, po)
            input = po;
            input.dmri_fn = po.nii_fn;
        end

    end

end