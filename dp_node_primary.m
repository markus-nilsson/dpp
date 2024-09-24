classdef dp_node_primary < dp_node_base

    methods (Abstract)
        get_iterable(obj) % need to be declared to work differently from base
    end
    
    methods

        function obj = dp_node_primary()
            obj.dpm_list = {...
                dpm_iter(obj), ...
                dpm_report(obj)};
        end        

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