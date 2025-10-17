classdef dp_node_copy < dp_node

    % this node will copy files to input.op
    % 
    % it will select all input files, identified as fields ending with '_fn'
    % alternatively, use the constructor to specify desired fields
    
    properties
        field_names        
    end

    methods

        function obj = dp_node_copy(field_names)
            if (nargin > 0)
                obj.field_names = field_names;
            end
        end

        function output = i2o(obj, input)

            f = obj.get_fieldnames_to_copy(input);

            for c = 1:numel(f)

                tmp = f{c};

                output.(tmp) = msf_fn_new_path(input.op, input.(tmp));

            end
            
        end

        function output = execute(obj, input, output)

            f = obj.get_fieldnames_to_copy(input);

            for c = 1:numel(f)

                tmp = f{c};

                % possibly one should throw a warning here
                if (~isfield(output, tmp))
                    error('bad output structure');
                end

                obj.log(3, 'Copying file %s', output.(tmp));
                msf_mkdir(fileparts(output.(tmp)));
                msf_delete(output.(tmp));
                copyfile(input.(tmp), output.(tmp));

            end

        end

        function f = get_fieldnames_to_copy(obj, input)

            if (isempty(obj.field_names))
                f_tmp = fieldnames(input);

                % copy fields with _fn
                f = {};
                for c = 1:numel(f_tmp)

                    tmp = f_tmp{c};
                    if (~strcmp('_fn', tmp( max(1,(end-2)):(end))))
                        continue;
                    end
                    f{end+1} = f_tmp{c};
                end

            else
                f = obj.field_names;
            end

        end

    end

end