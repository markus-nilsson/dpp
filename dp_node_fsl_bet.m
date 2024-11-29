classdef dp_node_fsl_bet < dp_node

    % brain extraction tool from FSL
    
    properties
        opt_str = []; % example -f 0.7 -g 0.4 (see bet documentation)
    end

    methods

        function obj = dp_node_fsl_bet(opt_str)
            if (nargin == 0), opt_str = ''; end
            obj.opt_str = opt_str;
            obj.output_test = {'nii_fn', 'mask_fn'};

        end
    
        function output = i2o(obj, input)
            output.mask_fn = msf_fn_new_path(input.op, msf_fn_append(input.nii_fn, '_mask'));
            output.nii_fn  = msf_fn_new_path(input.op, msf_fn_append(input.nii_fn, '_bet'));
        end

        function output = execute(obj, input, output)

            % Build the flirt command 
            bet_cmd = sprintf('bet %s %s %s', input.nii_fn, output.nii_fn, obj.opt_str);

            msf_mkdir(fileparts(output.nii_fn));
            msf_system(bet_cmd); % Execute the command

            % also output the mask
            [I,h] = mdm_nii_read(output.nii_fn);
            mdm_nii_write(double(I > 0), output.mask_fn, h);
            
        end
    end
end