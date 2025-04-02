classdef dp_node_segm_hd_bet < dp_node

    % brain extraction HD BET
    
    methods

        function obj = dp_node_segm_hd_bet()
            obj.output_test = {'nii_fn', 'mask_fn'};
        end
    
        function output = i2o(obj, input)
            output.mask_fn = dp.new_fn(input.op, input.nii_fn, '_mask');
            output.nii_fn  = dp.new_fn(input.op, input.nii_fn, '_hdbet');
        end

        function output = execute(obj, input, output)

            % Build the flirt command 
            hd_bet_cmd = sprintf('hd-bet -i "%s" -o "%s"', ...
                input.nii_fn, ...
                output.nii_fn);

            msf_mkdir(fileparts(output.nii_fn));
            obj.syscmd(hd_bet_cmd); % Execute the command

            % also output the mask
            [I,h] = mdm_nii_read(output.nii_fn);
            I = mio_mask_fill(I > 0);
            mdm_nii_write(double(I > 0), output.mask_fn, h);

           
        end
    end
end