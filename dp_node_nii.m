classdef dp_node_nii < dp_node

    methods

        function obj = dp_node_nii()
            obj.dpm_list = {...
                dpm_iter(obj), ...
                dpm_report(obj), ...
                dpm_execute(obj), ...
                dpm_debug(obj), ...
                dpm_visualize(obj)};
        end


        function output = run_clean(obj, output)

            % clean up temporary directory if asked to do so
            if (~isstruct(output)), return; end
            if (~isfield(output, 'tmp')), return; end

            output.tmp = msf_ensure_field(output.tmp, 'do_delete', 0);
            
            if (output.tmp.do_delete)
                msf_delete(output.tmp.bp);
            end

        end

        function [status, f] = input_exist(obj, input)
            [status, f] = obj.io_exist(input);
        end

        function [status, f] = output_exist(obj, input)
            [status, f] = obj.io_exist(input);
        end

        function input = run_po2i(obj, pop)

            input = run_po2i@dp_node(obj, pop);

            [inputs_exist, f] = obj.io_exist(input);

            if (~isempty(inputs_exist)) && (~all(inputs_exist))
                f = f(~inputs_exist);
                error('Missing input: %s', obj.join_cell_str(f') );
            end
        end
        
    end

    methods (Hidden, Static)

        % run a function on the input/output structures
        function [status, f] = io_exist(io)

            % select fields with names ending with _fn
            f = fieldnames(io);
            f = f(cellfun(@(x) ~isempty(strfind(x(max(1,(end-2)):end), '_fn')), f));

            % Report the presence of the files
            status = zeros(size(f));
            for c = 1:numel(f)
                status(c) = exist(io.(f{c}), 'file') == 2;

                % allow empties to pass
                if (isempty(io.(f{c})))
                    status(c) = 1; 
                end
            end

            status2 = cellfun( @(x) exist(io.(x), 'file') == 2, f);

        end        


        function str = join_cell_str(f)

            g = @(x) x(1:(end-3));
            
            str = g(cell2mat(cellfun(@(x) cat(2, x, ' / '), f, ...
                'UniformOutput', false)));
        end
        
        

    end

end