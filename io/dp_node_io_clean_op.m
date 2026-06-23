classdef dp_node_io_clean_op < dp_node

    % Delete all files and folders in op

    properties
        n_warning = 0;
        do_clean = 1;
    end
    
    methods

        function obj = dp_node_io_clean_op()

        end 

        function output = i2o(obj, input)
            output.nii_fn = fullfile(input.op, sprintf('%i.txt', ...
                round(24*60*60*now)));
        end

        function output = execute(obj, input, output)

            if (~obj.do_clean)
                % Reset pipeline to continue
                warning('You answered no to previous clean, aborting for safety');
                return;
            end

            if (obj.n_warning < 3)
                warning('This will delete %s', input.op);
                s = builtin('input', 'Continue? (will warn thrice, reply exactly YES to resume): ', 's');

                if ~strcmp(lower(s), 'yes')
                    obj.do_clean = 0;
                    return;
                end

                obj.n_warning = obj.n_warning + 1;
                1;
            end

            msf_delete(input.op);

        end

    end

end