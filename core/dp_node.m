classdef dp_node < dp_node_base

    % intention of this node is to implement methods dealing with file io 

    methods

        function obj = dp_node()
            obj.dpm_list = {...
                dpm_iter(obj), ...
                dpm_report(obj), ...
                dpm_execute(obj), ...
                dpm_debug(obj), ...
                dpm_mgui(obj), ...
                dpm_visualize(obj)};

        end

        function [status, f, age] = input_exist(obj, input)
            [status, f, age] = obj.io_exist2(input, obj.input_test);
        end

        function [status, f, age] = output_exist(obj, output)
            [status, f, age] = obj.io_exist2(output, obj.output_test);
        end

    end

    methods (Hidden, Static)

        % run a function on the input/output structures
        % these should be moved elsewhere        
        % sorry for the poor naming

        function [status, f, age] = io_exist2(io, test_fields)

            if (~isempty(test_fields)) % test only the fields asked for
                
                for c = 1:numel(test_fields)

                    if (~isfield(io, test_fields{c}))
                        disp(fieldnames(io)); % error will be thrown
                    end

                    tmp.(test_fields{c}) = io.(test_fields{c});
                end
                do_pass_empty = 0;
            else
                tmp = io;
                do_pass_empty = 1;
            end

            [status, f, age] = dp_node.io_exist(tmp, do_pass_empty);

        end

        function [status, f, age] = io_exist(io, do_pass_empty)

            if (nargin < 2)
                do_pass_empty = 1;
            end

            % select fields with names ending with _fn
            f = fieldnames(io);
            f = f(cellfun(@(x) ~isempty(strfind(x(max(1,(end-2)):end), '_fn')), f));

            % Report the presence of the files
            status = zeros(size(f));
            age = zeros(size(f));

            for c = 1:numel(f)
            
                status(c) = exist(io.(f{c}), 'file') == 2;

                if (status(c))
                    d = dir(io.(f{c}));
                    age(c) = d.datenum;
                else
                    age(c) = NaN;
                end

                % allow empties to pass
                if (isempty(io.(f{c}))) && (do_pass_empty)
                    status(c) = 1; 
                end
            end

            %status2 = cellfun( @(x) exist(io.(x), 'file') == 2, f);

        end        


        function str = join_cell_str(f)

            g = @(x) x(1:(end-3));
            
            str = g(cell2mat(cellfun(@(x) cat(2, x, ' / '), f, ...
                'UniformOutput', false)));
        end

    end

end