classdef dp_node_core < ...
        ...
        dp_node_core_dpm & ...
        dp_node_core_log & ...
        dp_node_core_central & ...
        dp_node_core_roi & ...
        dp_node_core_syscmd & ...
        handle

    properties

        previous_node = [];
        name;

    end

    methods

        % this method should move elsewhere
        function tmp = make_tmp(~)
            tmp.bp = msf_tmp_path(1);
            tmp.do_delete = 1;
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

            if (isempty(obj.name)), obj.name = class(obj); end
        end
        
    end   

end