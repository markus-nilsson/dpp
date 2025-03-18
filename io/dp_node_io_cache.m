classdef dp_node_io_cache < dp_node
    
    % dp_node_io_cache caches the full list of outputs.
    % When get_iterable is called, if the cache is empty it calls the parent's
    % get_iterable, stores the result, and returns it. Otherwise, it returns the cached outputs.
    
    properties
        cache = {};  % An empty cell array means no cache is stored.
    end
    
    methods

        function outputs = get_iterable(obj)

            if isempty(obj.cache)
                outputs = get_iterable@dp_node(obj);
                obj.cache = outputs;
                obj.log(1, 'Cached %d outputs from parent.', numel(outputs));
            else
                outputs = obj.cache;
                obj.log(1, 'Returning %d cached outputs.', numel(outputs));
            end

        end
        
        function clear_cache(obj)
            obj.cache = {};
            obj.log(1, 'Cache cleared.');
        end
    end
end