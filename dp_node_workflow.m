classdef dp_node_workflow < dp_node % assume this is for nifti files

    properties
        nodes = {};
    end

    methods

        function obj = dp_node_workflow(nodes)
            obj.nodes = nodes;

            obj.output_test = nodes{end}.output_test;
        end

        function output = i2o(obj, input)

            tmp = cell(size(obj.nodes));
            for c = 1:numel(obj.nodes)
                
                if (c == 1)
                    this_input = input;
                else
                    this_input = tmp{c-1};
                end

                tmp{c} = obj.nodes{c}.i2o(this_input);
            end

            output = tmp{end};
            output.wf_output = tmp;
            
        end

        function output = execute(obj, input, output)

            tmp = cell(size(obj.nodes));
            for c = 1:numel(obj.nodes)

                if (c == 1)
                    this_input = input;
                else
                    this_input = tmp{c-1};
                end

                this_output = output.wf_output{c};

                tmp{c} = obj.nodes{c}.execute(this_input, this_output);
            end
            
            output = tmp{end};
            output.wf_output = tmp;

        end

        function output = run_clean(obj, output)

            for c = 1:numel(obj.nodes)
                output.wf_output{c} = obj.nodes{c}.run_clean(output.wf_output{c});
            end
            
        end

    end

end