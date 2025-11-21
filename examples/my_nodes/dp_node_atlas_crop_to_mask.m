classdef dp_node_atlas_crop_to_mask < dp_node
    % Crop an atlas/label map with a provided mask (same grid).
    %
    % Inputs (from upstream):
    %   nii_fn   - atlas / label image to crop (e.g. warped JHU labels)
    %   mask_fn  - mask in the same space (e.g. trimmed FA brain mask)
    %   op       - optional output directory
    %
    % Output:
    %   nii_fn   - cropped atlas, saved as <op>/<basename>_crop.nii.gz

    properties
        suffix = '_crop';
    end

    methods
        function obj = dp_node_atlas_crop_to_mask(suffix)
            if nargin > 0
                obj.suffix = suffix;
            end
            obj.output_test = {'nii_fn'};
        end

        function output = i2o(obj, input)
            % Decide output folder
            if isfield(input, 'op') && ~isempty(input.op)
                op = input.op;
            else
                [op, ~, ~] = msf_fileparts(input.nii_fn);
            end

            % Use dp.new_fn to append suffix before extension
            output.nii_fn = dp.new_fn(op, input.nii_fn, obj.suffix);
        end

        function output = execute(obj, input, output)
            % Read atlas/labels and mask
            [A, Ah] = mdm_nii_read(input.nii_fn);
            B       = mdm_nii_read(input.mask_fn);

            % Basic safety
            if ~isequal(size(A), size(B))
                error('dp_node_atlas_crop_to_mask: atlas/mask size mismatch');
            end

            msf_mkdir(fileparts(output.nii_fn));

            % Apply crop
            mdm_nii_write(A .* (B > 0), output.nii_fn, Ah);

        end
    end
end
