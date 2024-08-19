classdef dp_node_primary < dp_node

    methods (Abstract)

        get_iterable(obj, opt)

    end
    

    methods

        function type = get_type(obj)
            type = 'primary';
        end

    end


end