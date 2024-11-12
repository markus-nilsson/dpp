classdef dp_node_core < ...
        ...
        dp_node_core_dpm & ...
        dp_node_core_log & ...
        dp_node_core_central & ...
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

    end   

end