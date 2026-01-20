classdef dp_node_workflow < dp_node % assume this is for nifti files

    properties (SetAccess = private, GetAccess = public)
        nodes = {};
    end

    methods

        function obj = dp_node_workflow(nodes, name)
            
            obj.nodes = nodes;

            if (nargin > 1), obj.name = name; end

            % Basic checking
            if (numel(nodes) <= 1)
                error('need at least two nodes for this to make sense');
            end

            % set previous nodes
            obj.nodes{1}.connect(obj); % xxx: see note below
            for c = 2:numel(nodes)
                obj.nodes{c}.connect(obj.nodes{c-1});
            end

            % xxx: do this for the new structure too
            obj.output_test = obj.nodes{end}.output_test;
            obj.input_test = obj.nodes{1}.input_test;

            % (connecting the first node to allow an unbroken chain to the
            %  first primary node, but this is more of a fix than a feature)
            %
            % new: trying to connect first node directly to the right prev
            
            % enable passthrough, so that nodes in the workflow can 
            % be used with any of the dpm's supported by the class
            for c = 1:numel(nodes)
                obj.nodes{c}.do_dpm_passthrough = 1; 
            end
        end

        function obj = connect(obj, varargin)
            obj = connect@dp_node(obj, varargin{:});
            obj.nodes{1}.connect(varargin{:});
        end
    
        function output = i2o(obj, input)

            c_input = cell(size(obj.nodes));
            c_output = cell(size(obj.nodes));

            log = @(varargin) obj.log(varargin{:});            

            log(2, '\nWorkflow (%s) input to output (i2o)\n', obj.name);
            log(2, '\ninput (to workflow %s):\n%s', ...
                obj.name, formattedDisplayText(input));
            
            for c = 1:numel(obj.nodes)
                
                % Get previous output
                if (c == 1)
                    po = input;
                else
                    po = c_output{c-1};
                end
                
                % Compute input and output
                [c_input{c}, c_output{c}] = obj.nodes{c}.run_po2io(po);
                
            end

            output = c_output{end};

            output.wf_output = c_output;
            output.wf_input  = c_input;

            log(2, '\noutput (from workflow %s):\n%s', ...
                obj.name, formattedDisplayText(output));            
            
        end



        % function output = run_on_one(obj, input, output)
        % 
        %     % some dpm's (like mgui start) should not be executed on 
        %     % all nodes in the workflow, just the last one
        %     if (~obj.get_dpm().do_run_on_all_in_workflow)
        % 
        %         % this is a difficult one, try a new thing
        %         output = run_on_one@dp_node(obj, input, output);
        % 
        %         return;
        %     end
        % 
        %     % input not used here, must use a well-formatted output
        %     if (obj.get_dpm().do_run_node(input, output))
        % 
        %         obj.log(0, '%s: Running workflow (%s)', input.id, obj.name);
        % 
        %         for c = 1:numel(obj.nodes)
        % 
        %             obj.nodes{c}.mode = obj.mode;
        % 
        %             this_input  = output.wf_input{c};
        %             this_output = output.wf_output{c};
        % 
        %             this_output = obj.nodes{c}.run_on_one(this_input, this_output);
        %         end
        % 
        %     else
        %         obj.log(0, '%s: Skipping workflow, outputs done (%s)', input.id, obj.name);
        %         this_output = output.wf_output{end};
        %     end
        % 
        %     % later steps need this
        %     this_output.wf_output = output.wf_output;
        %     this_output.wf_input = output.wf_input;
        % 
        %     output = this_output;
        % 
        % end 


        function output = execute(obj, ~, output)

            for c = 1:numel(obj.nodes)

                i = output.wf_input{c};
                o = output.wf_output{c};

                % Calling back on the dpm here. Unconventional. Bad.
                % But I do not see another solution now. 
                output.wf_output{c} = obj.nodes{c}.get_dpm('execute').run_on_one(i, o);
            end

        end


        function [status, f, age] = input_exist(obj, input)
            [status, f, age] = obj.nodes{1}.input_exist(input);
        end

        function [status, f, age] = output_exist(obj, output)
            % transfer output test restrictions from workflow to this node
            obj.nodes{end}.output_test = obj.output_test;
            [status, f, age] = obj.nodes{end}.output_exist(output);
        end
        
        function output = run_clean(obj, output)

            for c = 1:numel(obj.nodes)
                output.wf_output{c} = obj.nodes{c}.run_clean(output.wf_output{c});
            end
            
        end

        function modes = get_supported_modes(obj)
            % xxx: this should probably just report the modes of the 
            %      last node, perhaps this is what makes a pipeline
            %      and a workflow different - a pipeline should have 
            %      steps that are all "important" for output
            modes = {};
            for c = 1:numel(obj.nodes)
                modes = cat(2, modes, ...
                    cellfun(@(x) x.get_mode_name(), obj.dpm_list, 'UniformOutput', false));                
            end
            modes = unique(modes);
        end

        function previous_outputs = get_iterable(obj)

            first_node_is_primary = isa(obj.nodes{1}, 'dp_node_primary');

            if (~isempty(obj.previous_node)) && (first_node_is_primary)
                error('workflows cannot have both primary nodes as first nodes, and a previous node');
            end

            % Standard is to just use the previous node
            if (~isempty(obj.previous_node))
                previous_outputs = get_iterable@dp_node(obj);
                return;
            end

            % If the first node is a primary node, use that one for 
            % iterables. This will be no problems for later pipes,
            % as the execute method just passes on the input.
            %
            % xxx: possibly breaks concepts of this framework
            if (first_node_is_primary)
                previous_outputs = obj.nodes{1}.get_iterable();
                return;
            end

            error('Did not find a way to obtain iterables');

        end

    end

end