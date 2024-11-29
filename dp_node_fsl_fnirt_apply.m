classdef dp_node_fsl_fnirt_apply < dp_node

    % apply non-linear warp from fnirt
    %
    % input.nii_fn
    % input.warp_fn
    % input.target_fn
    %
    % output.nii_fn

    methods

        function output = i2o(obj, input)
            
            output.nii_fn = dp.new_fn(input.op, input.nii_fn, '_fnirt');
            
        end

        function output = execute(obj, input, output)

            [~,~,suffix] = msf_fileparts(output.nii_fn);
            f = @(x) x(1:(end-numel(suffix)));

            % Build the command 
            warp_cmd = cat(2, ...
                'applywarp ', ...
                sprintf('--ref=''%s'' ', input.target_fn), ...
                sprintf('--in=''%s'' ', input.nii_fn), ...
                sprintf('--warp=''%s'' ', input.warp_fn), ...
                sprintf('--out=''%s'' ', f(output.nii_fn)));

            msf_mkdir(fileparts(output.nii_fn));

            system(warp_cmd); % Execute it
        end
    end
end