classdef dp_node_make_xps < dp_node_dmri_xps_make

    % legact leftover, consider editing dcm2nii pipe instead

    properties
        xps = [];
    end

    methods

        function obj = dp_node_make_xps()
            error('move into dcm2nii structure, and workflow with dmri nodes');
            obj.output_test = {'nii_fn', 'xps_fn'};
        end

    end

end