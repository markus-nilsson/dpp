classdef dp_node_primary < dp_node

    methods (Abstract)

        get_iterable(obj, opt)

    end
    

    methods

        %  not implemented yet
        function [status, f] = input_exist(obj, input)
            status = []; 
            f = [];
        end
        
        function [status, f] = output_exist(obj, input)
            status = [];
            f = [];
        end

    end


end