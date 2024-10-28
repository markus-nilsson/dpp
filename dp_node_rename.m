classdef dp_node_rename < dp_node

    % Relabels field, or allows computation of fields

    properties
        translation_table; % { {'output_field', 'input_field'} }
        % if input field is a function, run it on the input
        % oterwise, set output_field to input_field
    end
    
    methods

        function obj = dp_node_rename(translation_table)
            obj.translation_table = translation_table;

            % check input
            x = translation_table;
            if (~iscell(x)), error('Translation table must be a cell struct'); end
            if (~all(2 == cellfun(@(y) numel(y), x))), error('Must be cell with pairs of cells'); end
        end        

        function output = i2o(obj, input)

            f = obj.translation_table;
            for c = 1:numel(f)
                if (isa(f{c}{2}, 'function_handle'))
                    output.(f{c}{1}) = f{c}{2}(input);
                else
                    output.(f{c}{1}) = input.(f{c}{2});
                end
            end

        end

        % 
        % %  not implemented yet
        % function [status, f, age] = input_exist(obj, input)
        %     status = []; 
        %     f = [];
        %     age = [];
        % end
        % 
        % function [status, f, age] = output_exist(obj, output)
        %     status = [];
        %     f = [];
        %     age = [];
        % end

    end


end