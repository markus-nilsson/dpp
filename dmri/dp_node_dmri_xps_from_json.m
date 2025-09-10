classdef dp_node_dmri_xps_from_json < dp_node

    % Creates experimental parameter sets (XPS) from JSON metadata files. Extracts diffusion
    % acquisition parameters from BIDS-style JSON sidecar files for proper data characterization.

    methods

        function obj = dp_node_dmri_xps_from_json()
            obj.output_test = {'xps_fn', 'status_file_fn'};
        end

        function output = i2o(obj, input)

            output.dmri_fn = input.dmri_fn;
            output.xps_fn  = mdm_xps_fn_from_nii_fn(output.dmri_fn);

            [~,name] = msf_fileparts(input.dmri_fn);
            output.status_file_fn = fullfile(input.op, [name '_xps_status.txt']);

        end

        function output = execute(obj, input, output)

            % Create xps from json
            xps = fwf_xps_from_siemens_json(input.dmri_fn);

            % Test it
            I = mdm_nii_read(input.dmri_fn);

            if (size(I,4) ~= xps.n)
                error('Sizes of xps and nii does not match (%i vs %i)', ...
                    xps.n, size(I,4));
            end
            

            mdm_xps_save(xps, output.xps_fn);

            msf_mkdir(fileparts(output.status_file_fn));
            mdm_txt_write({'done'}, output.status_file_fn);

        end

    end
end