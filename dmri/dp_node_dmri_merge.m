classdef dp_node_dmri_merge < dp_node

    % Merges multiple diffusion MRI datasets into a single combined dataset. Concatenates
    % data volumes and corresponding acquisition parameters while maintaining proper metadata.

    properties
        merge_fields;
        output_fn;
    end

    methods

        function obj = dp_node_dmri_merge(fields, output_fn)
            obj.merge_fields = fields;
            obj.output_fn = output_fn;
        end

        function output = i2o(obj, input)

            output.dmri_fn = fullfile(input.op, obj.output_fn);
            output.xps_fn  = mdm_xps_fn_from_nii_fn(output.dmri_fn);

        end

        function output = execute(obj, input, output)

            s = cell(1, numel(obj.merge_fields));
            for c = 1:numel(obj.merge_fields)
                s{c} = mdm_s_from_nii(input.(obj.merge_fields{c}));
            end
            
            opt.do_overwrite = 1;
            [nii_path, nii_name] = msf_fileparts(output.dmri_fn);
            msf_mkdir(nii_path);
            mdm_s_merge(s, nii_path, nii_name, opt);

        end


    end
end