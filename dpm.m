classdef dpm

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
        output = run_on_one(obj, node, input, output, opt)
        process_outputs(obj, outputs, opt)


    end
end