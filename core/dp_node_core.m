classdef dp_node_core < ...
        ...
        dp_node_core_dpm & ...
        dp_node_core_log & ...
        dp_node_core_central & ...
        dp_node_core_roi & ...
        dp_node_core_syscmd & ...
        dp_node_core_navigator & ...
        dp_node_core_run_fun & ...
        dp_node_core_tmp & ...
        handle

    properties

        previous_node = [];
        name;

    end

    methods

        function obj = dp_node_core()
            obj.name = class(obj);
        end
       
        function obj = setup(obj, previous_node, name)
            
            if (nargin < 2), previous_node = {}; end
            if (nargin < 3), name = class(obj); end
            
            obj.previous_node = previous_node;
            obj.name = name;
        end

        % same as above, better name?
        function obj = connect(obj, previous_node, name)
            
            obj.previous_node = previous_node;

            if (nargin > 2), obj.name = name; end

        end
        
    end   

end