classdef p7_powder_averaging < dp_node

    methods

        function obj = p7_powder_averaging()
            obj.previous_node = p5_coreg;
        end

        function input = po2i(obj, prev_output) % build input to this step from previous output
            input.bp = prev_output.bp;
            input.nii_fn = prev_output.nii_fn;
            input.opt = mdm_opt();
        end

        function output = i2o(obj, input)
            output.bp = input.bp; % keep the same base path
            [op, name, ext] = msf_fileparts(input.nii_fn);
            output.nii_fn = fullfile(op, [name '_pa' ext]);
            output.op = op;
        end

        function output = execute(obj, input, output)

            % diffusion data
            s_fwf = mdm_s_from_nii(input.nii_fn);

            % apply powder averaging
            mdm_s_powder_average(s_fwf, output.op, input.opt);

        end

    end

end




