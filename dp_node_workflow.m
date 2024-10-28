classdef dp_node_workflow < dp_node % assume this is for nifti files

    properties (SetAccess = private, GetAccess = public)
        nodes = {};
    end

    methods

        function obj = dp_node_workflow(nodes)
            obj.nodes = nodes;
            obj.output_test = nodes{end}.output_test;

            % enable passthrough, so that nodes in the workflow can 
            % be used with any of the dpm's supported by the class
            for c = 1:numel(nodes)
                obj.nodes{c}.do_dpm_passthrough = 1; 
            end
        end

        function output = i2o(obj, input)

            c_input = cell(size(obj.nodes));
            c_output = cell(size(obj.nodes));

            log = @(varargin) obj.log(varargin{:});            

            log(2, '\nWorkflow input to output (i2o)\n');
            log(2, '\ninput (to workflow):\n%s', formattedDisplayText(input));
            
            for c = 1:numel(obj.nodes)
                
                % Get previous output
                if (c == 1)
                    po = input;
                else
                    po = c_output{c-1};
                end
                
                % replicate the structure in dp.m                
                po          = obj.nodes{c}.manage_po(po);
                this_input  = obj.nodes{c}.run_po2i(po, 0);                
                this_output = obj.nodes{c}.run_i2o(this_input);

                log(2, '\noutput (from %s):\n%s', obj.nodes{c}.name, ...
                    formattedDisplayText(this_output));                
                
                c_input{c} = this_input;
                c_output{c} = this_output;

            end

            output = c_output{end};

            output.wf_output = c_output;
            output.wf_input  = c_input;
            
        end

        function obj = update_node(obj, varargin) % set necessary properties

            obj = update_node@dp_node(obj, varargin{:});
            
            % make sure nodes involves have names, are updated
            for c = 1:numel(obj.nodes)
                obj.nodes{c}.update_node(varargin{:});
            end

        end

        function output = run_on_one(obj, input, output)

            % some dpm's (like mgui start) should not be executed on 
            % all nodes in the workflow, just the last one
            if (~obj.get_dpm().do_run_on_all_in_workflow)

                obj.nodes{end}.opt = obj.opt;
                obj.nodes{end}.mode = obj.mode;
                
                output.wf_output{end} = obj.nodes{end}.get_dpm().run_on_one(...
                    output.wf_input{end}, output.wf_output{end});

                return;
            end

            % input not used here, must use a well-formatted output
            if (obj.get_dpm().do_run_node(input,output))

                obj.log(0, '%s: Running workflow (%s)', input.id, obj.name);

                for c = 1:numel(obj.nodes)

                    % Transfer the options to the node
                    obj.nodes{c}.opt = obj.opt;
                    obj.nodes{c}.mode = obj.mode;

                    this_input  = output.wf_input{c};
                    this_output = output.wf_output{c};

                    this_output = obj.nodes{c}.run_on_one(this_input, this_output);
                end

            else
                obj.log(0, '%s: Skipping workflow, outputs done (%s)', input.id, obj.name);
            end

            % later steps need this
            this_output.wf_output = output.wf_output;
            this_output.wf_input = output.wf_input;

            output = this_output;

        end 

        function [status, f, age] = input_exist(obj, input)
            [status, f, age] = obj.nodes{1}.input_exist(input);
        end

        function [status, f, age] = output_exist(obj, output)
            [status, f, age] = obj.nodes{end}.output_exist(output);
        end
        
        
        % 
        % function output = execute(obj, input, output)
        % 
        %     warning('this should not be used')
        % 
        %     1;
        %     % input not used here, must use a well-formatted outtput
        %     for c = 1:numel(obj.nodes)
        % 
        %         % Transfer the options to the node
        %         obj.nodes{c}.opt = obj.opt;
        %         obj.nodes{c}.mode = obj.mode;
        % 
        %         this_input  = output.wf_input{c};
        %         this_output = output.wf_output{c};
        % 
        %         this_output = obj.nodes{c}.execute(this_input, this_output);
        %     end
        % 
        %     % later steps need this
        %     this_output.wf_output = output.wf_output;
        %     this_output.wf_input = output.wf_input;
        % 
        %     output = this_output;
        % 
        % end

        function output = run_clean(obj, output)

            for c = 1:numel(obj.nodes)
                obj.nodes{c}.opt = obj.opt; % transfer options to node
                output.wf_output{c} = obj.nodes{c}.run_clean(output.wf_output{c});
            end
            
        end

        function modes = get_supported_modes(obj)
            modes = {};
            for c = 1:numel(obj.nodes)
                modes = cat(2, modes, ...
                    cellfun(@(x) x.get_mode_name(), obj.dpm_list, 'UniformOutput', false));                
            end
            modes = unique(modes);
        end

        function previous_outputs = get_iterable(obj)

            first_node_is_primary = isa(obj.nodes{1}, 'dp_node_primary');

            if (~isempty(obj.previous_node))

                if (first_node_is_primary)
                    error('workflows cannot have both primary nodes as first nodes, and a previous node');
                end

                previous_outputs = get_iterable@dp_node_base(obj);
                return;
            end

            % If the first node is a primary node, use that one for 
            % iterables. This will be no problems for later pipes,
            % as the execute method just passes on the input.
            if (first_node_is_primary)
                previous_outputs = obj.nodes{1}.get_iterable();
                return;
            end

            error('Did not find a way to obtain iterables');

        end

    end

end