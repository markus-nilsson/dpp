classdef dp_node_io_split_merge < dp_node_io_merge

    % has one input, but does processing in many nodes, and then joins it
    % up

    % uses all merge logics

    % the name previous_nodes is really bad, we should change it here and
    % in dp_node_io_merge (less bad there, but here it makes no sense,
    % should really be just "nodes" as these are process in parallell)

    methods

        function output = i2o(obj, input)

            % this is generally a function we cannot call for io merge,
            % unless it is a merge from a single point, that is, all
            % nodes takes the same input. that could happen in a workflow
            % then previous_node would be set, in addition to
            % previous_nodes, which details the actual nodes in here
            if (isempty(obj.previous_node)), error('need a connection');end

            % grab previous output from a single input
            outputs = cell(size(obj.previous_nodes));
            for c = 1:numel(obj.previous_nodes)
                outputs{c} = obj.previous_nodes{c}.i2o(input);
            end

            output = obj.split_merge_outputs(outputs);

        end
      

        function output = run_on_one(obj, input, output)

            outputs = cell(size(obj.previous_nodes));
            for c = 1:numel(obj.previous_nodes)
                obj.previous_nodes{c}.mode = obj.mode;
                outputs{c} = obj.previous_nodes{c}.run_on_one(input, output.outputs{c});
            end            

            output = obj.split_merge_outputs(outputs);
        
        end

        % not sure this is the right thing to do
        function output = split_merge_outputs(obj, outputs)

            % rename (legacy)
            output.id = outputs{1}.id;
            output.output = outputs;

            output = dp_node_io_merge.rename_outputs({output}, ...
                obj.previous_nodes, obj.do_prefix);

            output = output{1};
            output.outputs = outputs;  

        end



        function obj = connect(obj, varargin)
            obj = connect@dp_node_io_merge(obj, varargin{:});

            % connect nodes part of the split merge
            for c = 1:numel(obj.previous_nodes)
                obj.previous_nodes{c}.connect(varargin{1});
            end

        end        


        function [status, f, age] = input_exist(obj, input)
            [status, f, age] = obj.io_exist2(input, obj.input_test);
        end

        function [status, f, age] = output_exist(obj, output)
            [status, f, age] = obj.io_exist2(output, obj.output_test);
        end        


    end

    methods (Hidden)

        function nodes = get_previous_nodes(obj)
            nodes = {obj.previous_node};
        end
    end

end