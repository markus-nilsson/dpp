classdef dp_node_dmri < dp_node

    % Base class for diffusion MRI processing nodes. Provides common helper methods
    % and utilities for handling diffusion data, including automatic XPS file handling.

    methods

        function input = po2i(obj, po)
            input = po;
            if (~isfield(input, 'xps_fn'))
                input.xps_fn = mdm_xps_fn_from_nii_fn(input.dmri_fn);
            end
        end
    end
end