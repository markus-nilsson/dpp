classdef dp_node_dmri_topup_prep_one < dp_node

    % Prepares individual datasets for TOPUP processing by extracting phase-encoding parameters
    % and organizing acquisition data. Handles single-direction data preparation for distortion correction.

    properties
        suffix = '_topuprep';
        
        % normalised "phase-encode direction vector" 
        phase_encode_vector;

        % time (in seconds) between the readout of the centre of the 
        % first echo and the centre of the last echo (equal to dwell-time
        % multiplied by # of phase-encode steps minus one)
        epi_time;

        % range of b-values used for topup
        b_min = -inf;
        b_max = 0.11e9;

    end
    

    methods

        function obj = dp_node_dmri_topup_prep_one(suffix, pe_vector, time)

            if (suffix(1) ~= '_'), suffix = cat(2, '_', suffix); end

            obj.suffix = suffix;
            obj.phase_encode_vector = pe_vector;
            obj.epi_time = time;

            obj.input_test = {'nii_fn','xps_fn'};

        end

        function output = i2o(obj, input)
            output.nii_fn = dp.new_fn(input.op, input.nii_fn, obj.suffix);
            output.spec_fn = dp.new_fn(input.op, input.nii_fn, obj.suffix, 'txt');
        end

        function output = execute(obj, input, output)

            % get b-values
            xps = mdm_xps_load(input.xps_fn);
            ind = (xps.b > obj.b_min) & (xps.b < obj.b_max);

            % average relevant volumes
            [I,h] = mdm_nii_read(input.nii_fn);
            I = mean(I(:,:,:,ind), 4);

            mdm_nii_write(I, output.nii_fn, h);

            % Write topup specification file
            % xxx: this should find correct information from a json file
            tmp = sprintf('%1.2f %1.2f %1.2f %1.2f', ...
                obj.phase_encode_vector(1), ...
                obj.phase_encode_vector(2), ...
                obj.phase_encode_vector(3), ...
                obj.epi_time);
            
            mdm_txt_write({tmp}, output.spec_fn);

        end
    end
end

