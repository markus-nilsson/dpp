classdef dp_node_ants_n4_bias_corr < dp_node
    % This class runs N4BiasFieldCorrection from ANTS.
    %
    % The following arguments are supported:
    % -d, --image-dimensionality: Image dimensionality (2, 3, or 4) [default: 3].
    % -i, --input-image: The input image (required).
    % -x, --mask-image: The mask image. If not specified, the entire image is used.
    % -o, --output: The output image [default: output.nii.gz].
    % -s, --shrink-factor: Shrink factor for multi-resolution [default: 4].
    % -c, --convergence: Convergence criteria, e.g., [50x50x50x50,0.0000001].
    % -b, --bspline-fitting: B-spline fitting parameters, e.g., [300].
    % -t, --bias-field-estimate: Bias field estimate parameters.
    % -r, --rescale-intensities: Rescale intensities to [0,1] if specified.
    % -v, --verbose: Verbose output.
    
    properties
        opt_str = ''; % Optional string for additional parameters
    end

    methods

        function obj = dp_node_ants_n4_bias_corr(opt_str)
            
            if nargin > 0, obj.opt_str = opt_str; end

            obj.conda_env = 'mrtrix-env'; % dual use of that environment
        end
    
        function output = i2o(~, input)
            output.nii_fn = dp.new_fn(input.op, input.nii_fn, '_n4');
        end

        function output = execute(obj, input, output)

            % Build the N4BiasFieldCorrection command 
            n4_cmd = sprintf('N4BiasFieldCorrection -i %s -o %s %s', ...
                input.nii_fn, output.nii_fn, obj.opt_str);

            % Create the output directory if it doesn't exist
            msf_mkdir(fileparts(output.nii_fn));

            % Execute the command
            [status, cmdout] = obj.syscmd(n4_cmd);
            
            if status ~= 0
                error('N4BiasFieldCorrection failed: %s', cmdout);
            end
        end
    end
end