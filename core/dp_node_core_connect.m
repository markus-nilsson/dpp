classdef dp_node_core_connect < handle
    
    properties

        previous_node = [];
        primary_node = [];
        name;

    end

    methods

        function obj = dp_node_core_connect()
            obj.name = class(obj);
        end
       
        function obj = setup(obj, previous_node, name)
            warning('deprecated');
            
            if (nargin < 2), previous_node = {}; end
            if (nargin < 3), name = class(obj); end
            
            obj.previous_node = previous_node;
            obj.name = name;
        end

        % same as above, better name?
        function obj = connect(obj, previous_node, name)

            if (nargin > 2), warning('use set_name'); end
            
            obj.previous_node = previous_node;

            if (nargin > 2), obj.name = name; end

        end

        function obj = set(obj, field, value)
            obj.(field) = value;
        end

        function obj = set_name(obj, name)
            obj.name = name;
        end


        % Overload this e.g. in dp_node_io_merge
        function nodes = get_previous_nodes(obj)

            if (~isempty(obj.previous_node))
                nodes = {obj.previous_node};
            else
                nodes = {};
            end

        end

        % get primary node (need to be fast)
        function node = get_primary_node(obj, do_use_cache)

            if (nargin < 2), do_use_cache = 1; end

            % Use cache if available
            if (~isempty(obj.primary_node)) && (do_use_cache)
                node = obj.primary_node;
                return;
            end

            nodes = obj.get_previous_nodes();

            if (isempty(nodes))

                if (~isa(obj, 'dp_node_primary'))
                    node = []; 
                    warning('primary node not found (current node not a dp_node_primary)')
                    return;
                else

                node = obj;                
                
                end

            else % search left branch to get to primary node
                node = nodes{1}.get_primary_node();
            end

            % Store for caching
            obj.primary_node = node;

        end        
        
    end  

end