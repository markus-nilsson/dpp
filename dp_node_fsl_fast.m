classdef dp_node_fsl_fast < dp_node

    % fast from FSL
    %
    % creates a lot of files, which are not cleaned for now
    
    properties
        opt_str = '-B'; 
    end

    methods

        function obj = dp_node_fsl_bet(opt_str)
            if (nargin > 0), obj.opt_str = opt_str; end
            obj.input_test = {'nii_fn'};
            obj.output_test = {'nii_fn'};
        end
    
        function output = i2o(~, input)
            output.nii_fn  = dp.new_fn(input.op, input.nii_fn, '_restore');
        end

        function output = execute(obj, input, output)

            % Build the command 
            fast_cmd = sprintf('fast %s -o %s %s', ...
                obj.opt_str, ...
                input.nii_fn, ...
                input.nii_fn);

            msf_mkdir(fileparts(output.nii_fn));
            obj.syscmd(fast_cmd); % Execute the command

        end
    end
end
