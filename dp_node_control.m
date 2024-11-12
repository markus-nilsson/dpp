classdef dp_base_control < dp_node_core

    % this should really be named run manager, as this
    % class implements functions related to running nodes

    properties
        opt;
        do_i2o_pass = 0;
    end

    methods

        function obj = dp_node_base()

        end

        function output = run_clean(obj, output)

            % clean up temporary directory if asked to do so
            if (~isstruct(output)), return; end
            
            if (isfield(output, 'tmp')) && ...
                    (isfield(output.tmp, 'do_delete')) && ...
                    (output.tmp.do_delete)

                msf_delete(output.tmp.bp);

            end
            
        end

        function obj = update_node(obj, opt) % set necessary properties

            if (isempty(obj.name))
                obj.name = class(obj);
            end

            if (nargin > 1)
                obj.opt = opt;
            end
        end
        

        function outputs = clean_iterable(obj, outputs)

            % one of these functions that are here to make life easier
            % but that should not have to be here if things were 
            % done correctly from the start
            if (isa(obj.previous_node, 'dp_node_primary'))
                ind = ones(size(outputs));
                for c = 1:numel(ind)
                    if (outputs{c}.id(1) == '.')
                        ind(c) = 0;
                    end
                end
                outputs = outputs(ind == 1);
            end

        end

        % run on all outputs from the previous node
        function outputs = run(obj, mode, opt_in)
            
            if (nargin < 2), mode = 'report'; end
            if (nargin < 3), opt_in.present = 1; end

            % set mode
            obj.mode = mode;

            % deal with options
            obj.opt.present = 1;
            opt = dp_node_base.default_opt(opt_in);
            opt = obj.get_dpm().dp_opt(opt);

            % force outside do_try_catch
            if (isfield(opt_in, 'do_try_catch'))
                opt.do_try_catch = opt_in.do_try_catch;
            end

            % make sure this and previous nodes have names
            obj.update_node(opt);

            if (~isempty(obj.previous_node))
                obj.previous_node.update_node();
            end       

            outputs = dpm.run(obj);
        end

        % run the data processing mode's function here
        function output = run_on_one(obj, input, output)
            output = obj.get_dpm().run_on_one(input, output);
        end

        % run the data processing mode's processing/reporting
        function outputs = process_outputs(obj, outputs)
            outputs = obj.get_dpm().process_outputs(outputs);
        end
       
        function pop = manage_po(obj, pop)
            if (~msf_isfield(pop, 'id')), error('id field missing'); end
        end

        % compute input to this node from previous output
        function input = run_po2i(obj, pop, varargin)
            
            input = obj.po2i(pop);

            % transfer id, output path, base path, if they exist
            f = {'id', 'op', 'bp'};
            for c = 1:numel(f)
                if (isfield(pop, f{c}) && ~isfield(input, f{c}))
                    input.(f{c}) = pop.(f{c});
                end
            end

        end

        % compile output
        function output = run_i2o(obj, input)

            % check quality of input
            f = {'id', 'bp'}; % op not needed at all times

            for c = 1:numel(f)
                if (~isfield(input, f{c}))
                    % xxx: better solution needed
                    obj.log(0, 'Mandatory input field missing (%s)', f{c});
                    error('Mandatory input field missing (%s)', f{c});
                end
            end

            output = obj.i2o(input);

            % check quality of input
            f = {'id', 'op', 'bp'};            

            if (obj.do_i2o_pass) % pass all inputs to outputs
                f = cat(2, fieldnames(input));
            end

            for c = 1:numel(f)
                if (isfield(input, f{c}) && ~isfield(output, f{c}))
                    output.(f{c}) = input.(f{c});
                end
            end
            
        end

    end

    methods (Static)

        function opt = default_opt(opt)
            
            opt = msf_ensure_field(opt, 'verbose', 0);
            opt = msf_ensure_field(opt, 'do_try_catch', 1);
            opt = msf_ensure_field(opt, 'id_filter', {});
            opt = msf_ensure_field(opt, 'iter_mode', 'iter');

            % do not write over existing data as per default
            opt = msf_ensure_field(opt, 'do_overwrite', 0);
            
            opt = msf_ensure_field(opt, 'c_level', 0);
            opt.c_level = opt.c_level + 1;

            opt.indent = zeros(1, 2*(opt.c_level - 1)) + ' ';

            opt = msf_ensure_field(opt, 'id_filter', {});

            if (ischar(opt.id_filter))
                opt.id_filder = {opt.id_filter};
            end
        end

    end

end