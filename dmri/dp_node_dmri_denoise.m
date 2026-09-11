classdef dp_node_dmri_denoise < dp_node_dmri

    % Denoises diffusion MRI data using MRtrix's dwidenoise tool. Reduces noise
    % while preserving signal integrity using principal component analysis.

    properties
        denoise_method = 'mrtrix'; % or jespersen
    end

    methods

        function obj = dp_node_dmri_denoise(method)

            if (nargin > 0), obj.denoise_method = method; end

            obj.input_test = {'dmri_fn', 'xps_fn'};
            obj.output_test = {'dmri_fn', 'xps_fn'};
        end

        function output = i2o(obj, input) %#ok<INUSD>
            
            output.dmri_fn = dp.new_fn(input.op, input.dmri_fn, '_dn');
            output.xps_fn = mdm_xps_fn_from_nii_fn(output.dmri_fn);
            
        end

        function output = execute(obj, input, output) %#ok<INUSD>

            % xxx: this should be implemented by a workflow and connecting
            %      to two separate nodes instead
            switch (obj.denoise_method)
                case 'mrtrix'
                    output = obj.execute_mrtrix(input, output);
                case 'jespersen'
                    output = obj.execute_jespersen(input, output);
                otherwise
                    error('Denoising method %s unknown', obj.denoise_method);

            end

            % copy the xps from the original data 
            xps = mdm_xps_load(input.xps_fn);
            mdm_xps_save(xps, output.xps_fn);

        end

        function output = execute_mrtrix(~, input, output)

            % execute mrtrix denoising (linux version here, remove &> .. to debug
            cmd = sprintf('dwidenoise %s %s &> /dev/null', input.dmri_fn, output.dmri_fn);
            msf_delete(output.dmri_fn);
            msf_mkdir(fileparts(output.dmri_fn));
            a = msf_system(cmd);

            if (a ~= 0), error('command unsuccessful'); end

        end

        function output = execute_jespersen(obj, input, output)

            % execute sune's denoising
            [I,h] = mdm_nii_read(input.dmri_fn);

                
            window = [5 5 5]; % xxx: make property of object instead
            I = denoise(double(I), window);

            mdm_nii_write(I, output.dmri_fn, h);

        end


    end

end


