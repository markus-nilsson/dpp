classdef dp_node_io_rename < dp_node

    % Relabels field, or allows computation of fields
    %
    % Constructor takes 
    %
    %   translation_table = { {'output_field', 'input_field'} }
    %
    % if input field is a function, run it on the input
    % otherwise, set output_field to input_field

    properties
        translation_table;
        do_rename_immediately = 0; 
    end
    
    methods

        function obj = dp_node_io_rename(translation_table)
            obj.translation_table = translation_table;

            % We do not need to run the execute method of these io objects
            obj.get_dpm('execute').do_run_execute = 0;

            % check input
            x = translation_table;
            if (~iscell(x)), error('Translation table must be a cell struct'); end
            if (~all(2 == cellfun(@(y) numel(y), x))), error('Must be cell with pairs of cells'); end
        end        

        function output = i2o(obj, input)

            f = obj.translation_table;
            for c = 1:numel(f)

                switch (class(f{c}{2}))
                    
                    case 'function_handle'
                        output.(f{c}{1}) = f{c}{2}(input);

                    case {'struct', 'double'}
                        output.(f{c}{1}) = f{c}{2};
                    
                    case {'string', 'char'}

                        % If you want to use strings, use function handle
                        % (dp_node_rename({'field', @(x) 'your string'})
                        %
                        % Soft warning
                        if (~isfield(input, f{c}{2}))

                            obj.log(0, '%s: Warning (%s)', input.id, obj.name);

                            obj.log(0, '%s:   %s field missing (fields present: %s)', ...
                                input.id, f{c}{2}, strjoin(fieldnames(input)));

                            obj.log(0, '%s:   If you wanted to set a string, use @(x) str instead', input.id);

                            % Set the field to the string, soft error style
                            output.(f{c}{1}) = (f{c}{2});
                            

                        else
                            
                            % Take the value from the input field
                            output.(f{c}{1}) = input.(f{c}{2});
    
                        end

                    otherwise 

                        error('case not defined');

                end

                % Set the new field also to the input, allowing it to be
                % used in later translations (somewhat dangerous, use with
                % carefullness)
                if (obj.do_rename_immediately)
                    input.(f{c}{1}) = output.(f{c}{1});
                end

            end

        end

        function obj = update(obj, varargin)
            obj = update@dp_node(obj, varargin{:});
        end        

    end

end