classdef dp_node_copy < dp_node

    % this node will copy all input files, identified as fields ending with
    % '_fn' to the 

    methods

        function obj = dp_node_copy()
        end

        function output = i2o(obj, input)

            f = fieldnames(input);

            for c = 1:numel(f)

                tmp = f{c};

                % copy fields with _fn
                if (~strcmp('_fn', tmp( max(1,(end-2)):(end))))
                    continue; 
                end

                output.(tmp) = msf_fn_new_path(input.op, input.(tmp));

            end
            
        end

        function output = execute(obj, input, output)

            f = fieldnames(input);

            for c = 1:numel(f)

                tmp = f{c};

                % copy fields with _fn
                if (~strcmp('_fn', tmp( max(1,(end-2)):(end))))
                    continue; 
                end

                % possibly one should throw a warning here
                if (~isfield(output, tmp))
                    error('bad output structure');
                end

                obj.log(output.(tmp));
                msf_mkdir(fileparts(output.(tmp)));
                copyfile(input.(tmp), output.(tmp));


            end

        end

    end
end