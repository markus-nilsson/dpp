classdef dp_node_dmri < dp_node

    % helpful methods for dmri processing

    methods

        function input = po2i(obj, po)
            input = po;
            if (~isfield(input, 'xps_fn'))
                input.xps_fn = mdm_xps_fn_from_nii_fn(input.dmri_fn);
            end
        end
    end
end