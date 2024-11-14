classdef dp_node_make_xps < dp_node_dmri_xps_make

    % legact leftover, consider editing dcm2nii pipe instead

    methods

        function input = po2i(obj, po)
            input = po;
            input.dmri_fn = po.nii_fn;
        end

    end

end