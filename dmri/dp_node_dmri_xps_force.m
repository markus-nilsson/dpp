classdef dp_node_dmri_xps_force < dp_node_dmri_xps

    % Forces a specific experimental parameter set (XPS) onto a diffusion dataset. Overwrites
    % existing acquisition parameters with user-defined values for custom analysis workflows.

    properties
        xps;
    end

    methods

        function obj = dp_node_dmri_xps_force(xps)
            obj.xps = xps;
        end

        function output = execute(obj, ~, output)
            mdm_xps_save(obj.xps, output.xps_fn);
        end
    end
end