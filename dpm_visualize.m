classdef dpm_visualize < dpm

    % 2do
    % add time stamps in the figure so we know if it is a new output
    % or, add option to clean output folder before execution

    methods

        function mode_name = get_mode_name(obj)
            mode_name = 'visualize';
        end
        
        function opt = dp_opt(obj, opt)
            1;
        end
        

        function output = run_on_one(obj, input, output)

            % Determine conditions
            if (~isfield(output, 'vis'))
                error('%s: output.vis missing', output.id);
            end

            vis = output.vis;

            if (~isfield(vis, 'field_names'))
                error('%s: output.vis.nii_fns missing, do not know what to show', output.id);
            end

            if (~isfield(vis, 'bp'))
                error('%s: output.vis.bp missing, do not know where to output', output.id);
            end

            obj.node.visualize(input, output);


        end

        function process_outputs(obj, outputs, opt)
            1;
        end

    end

end