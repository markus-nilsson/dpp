classdef dp_node_fsl_fnirt < dp_node

    % non-linear coregistration using fnirt
    %
    % as of now written for dmri (fa)
    %
    % input.nii_fn
    % input.target_fn
    %
    % output.warp_fn 
    %
    % output.nii_fn (passthrough)
    % output.target_fn (passthrough)


    properties
        config_str = 'FA_2_FMRIB58_1mm';
    end

    methods

        function obj = dp_node_fsl_fnirt()
            obj.output_test = {'warp_fn'};
        end        

        function input = po2i(obj, po)

            input = po;

            % output came from the flirt node, so we want to preserve
            % the original nifti file throughout this chain
            if (isfield(po, 'original_nii_fn'))
                input.nii_fn = input.original_nii_fn;
            end

        end

        function output = i2o(obj, input)
            
            output.warp_fn = dp.new_fn(input.op, input.nii_fn, '_fnirtwarp');
            
            % pass along the (unwarped) nifti file and the target
            output.nii_fn = input.nii_fn;
            output.target_fn = input.target_fn;

        end

        function output = execute(obj, input, output)

            [~,~,suffix] = msf_fileparts(output.warp_fn);
            f = @(x) x(1:(end-numel(suffix)));

            % Build the fnirt command 
            fnirt_cmd = cat(2, ...
                'fnirt ', ...
                sprintf('--ref=''%s'' ', input.target_fn), ...
                sprintf('--in=''%s'' ', input.nii_fn), ...
                sprintf('--aff=''%s'' ', input.matrix_fn), ...
                sprintf('--cout=''%s'' ', f(output.warp_fn)), ...
                sprintf('--config=''%s'' ', obj.config_str));

            msf_mkdir(fileparts(output.warp_fn));

            system(fnirt_cmd); % Execute it
        end
    end
end