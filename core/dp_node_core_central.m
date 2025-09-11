classdef dp_node_core_central < handle

    methods

        % methods that we expected to be overloaded 
        % (this is where you implement the processing code)

        function input = po2i(~, previous_output) 
            input = previous_output;
        end

        function outputs = i2o(~, inputs)
            outputs = inputs;
        end

        function output = execute(~, ~, output)
            1;
        end
      
    end   

end