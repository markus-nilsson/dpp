classdef dp_node_ants_apply < dp_node
    % Wrapper around antsApplyTransforms onto a given reference grid
    % input.nii_fn   : image to be transformed (e.g. atlas labels in MNI)
    % input.ref_fn   : reference grid / output space (e.g. trimmed FA)
    % input.affine_fn, input.invwarp_fn : from dp_node_ants_reg_quick
    % output.nii_fn  : resampled image in ref_fn space

    properties
        options = '';       % e.g. ' -n NearestNeighbor' for labels
        use_inverse = 1;    % default = inverse chain
    end

    methods

        function obj = dp_node_ants_apply(options)
            if (nargin>0), obj.options = options; end
            obj.output_test = {'nii_fn'};
        end

        function output = i2o(obj, input)
            output.nii_fn = dp.new_fn(input.op, input.nii_fn, '_ants');
            output.ref_fn = input.ref_fn;
        end

        function output = execute(obj, input, output)
            msf_mkdir(fileparts(output.nii_fn));
            if obj.use_inverse
                % apply inverse chain: template→subject (fixed → moving)
                t = sprintf('-t "[%s,1]" -t "%s" ', input.affine_fn, input.invwarp_fn);
            else
                % apply forward chain: subject→template (moving → fixed)
                t = sprintf('-t "%s" -t "%s" ', input.warp_fn, input.affine_fn);
            end

            if isempty(obj.options), obj.options = ' -n NearestNeighbor'; end

            % cmd using composed transform chain "t" (forward or inverse, depending on use_inverse)
            cmd = sprintf('antsApplyTransforms -d 3 -i "%s" -r "%s" %s -o "%s"%s', ...
                input.nii_fn, input.ref_fn, t, output.nii_fn, obj.options);


            system(cmd);
        end
    end
end
