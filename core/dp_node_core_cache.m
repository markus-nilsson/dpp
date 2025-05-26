classdef dp_node_core_cache < dp_node_core_opt & handle

    properties
        cache
    end


    methods

        function obj = dp_node_core_cache()
            obj.cache.run_id = [];
        end

        function cache_store(obj, outputs)
            obj.cache.outputs = outputs;
            obj.cache.run_id = obj.opt.run_id;
        end

        function outputs = cache_get(obj)


            if (obj.cache_present())
                outputs = obj.cache.outputs;                
            else
                error('no cache stored');
            end

        end

        function tf = cache_present(obj)          
            tf = isequal(obj.cache.run_id, obj.opt.run_id);
        end

    end



end