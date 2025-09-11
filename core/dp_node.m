classdef dp_node < dp_node_base

    % intention of this node is to implement methods dealing with file io 

    methods

        function obj = dp_node()
            obj.dpm_list = {...
                dpm_iter(obj), ...
                dpm_report(obj), ...
                dpm_execute(obj), ...
                dpm_debug(obj), ...
                dpm_mgui(obj), ...
                dpm_visualize(obj)};

        end


    end

end