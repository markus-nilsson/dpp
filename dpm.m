classdef dpm < handle

    % Data processing mode - implements means to process data

    properties
        node;
    end

    methods

        % Connect the data processing mode to a node
        function obj = dpm(node)
            obj.node = node;
        end

    end

    methods (Abstract)

        mode_name = get_mode_name(obj)
        opt = dp_opt(obj, opt)
        output = run_on_one(obj, input, output)
        process_outputs(obj, outputs)


    end
end