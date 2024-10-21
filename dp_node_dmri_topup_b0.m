classdef dp_node_dmri_topup_b0 < dp_node

    % Estimate b0 using topup

    methods
        
        % construct names of output files
        function output = i2o(obj, input)

            % pass on
            output = input;

            % fill up with more files here
            output.topup_data_path = fullfile(input.op, 'topup_data');

        end

        function output = execute(obj, input, output)

            % run topup

            cmd = sprintf(['bash --login -c ''topup ' ...
                '--imain=%s --datain=%s --out=%s'''], ...
                input.topup_nii_fn, ...
                input.topup_spec_fn, ...
                output.topup_data_path);

            system(cmd);


        end
    end
end

