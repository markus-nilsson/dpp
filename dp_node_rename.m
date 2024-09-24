classdef dp_node_rename < dp_node_base

    properties
        translation_table; % { {'output_field', 'input_field'} }
    end
    
    methods

        function obj = dp_node_rename(translation_table)
            obj.translation_table = translation_table;
        end        


        function output = i2o(obj, input)

            f = obj.translation_table;
            for c = 1:numel(f)
                output.(f{c}{2}) = input.(f{c}{1});
            end

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