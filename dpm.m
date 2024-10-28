classdef dpm < handle

    % Data processing mode - implements means to process data

    properties
        node;
        do_run_on_all_in_workflow = 0;
    end

    methods

        % Connect the data processing mode to a node
        function obj = dpm(node)
            obj.node = node;
        end

        % Allow overloadig e.g. in dpm_execute
        function do_run = do_run_node(obj, input, output)
            do_run = 1; 
        end

    end

    methods (Abstract)

        mode_name = get_mode_name(obj)
        opt = dp_opt(obj, opt)
        output = run_on_one(obj, input, output)
        process_outputs(obj, outputs)


    end
end