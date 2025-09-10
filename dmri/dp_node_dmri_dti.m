classdef dp_node_dmri_dti < dp_node

    % Performs Diffusion Tensor Imaging (DTI) analysis using linear least squares fitting.
    % Computes standard DTI metrics including fractional anisotropy (FA), mean diffusivity (MD), and signal intensity maps.

    properties
        filter_sigma = 0;
    end

    methods

        function obj = dp_node_dmri_dti(filter_sigma)
            obj.input_test = {'dmri_fn'};
            obj.output_test = {'md_fn', 'fa_fn', 's0_fn', 'fa_col_fn'};
            
            if (nargin > 0)
                obj.filter_sigma = filter_sigma;
            end
        end

        function output = i2o(obj, input)
            
            output.md_fn = fullfile(input.op, 'dti_lls_md.nii.gz');
            output.fa_fn = fullfile(input.op, 'dti_lls_fa.nii.gz');
            output.fa_col_fn = fullfile(input.op, 'dti_lls_fa_u_rgb.nii.gz');
            output.s0_fn = fullfile(input.op, 'dti_lls_s0.nii.gz');

            % pass info about the dmri fn, and mask_fn if existent
            output.dmri_fn = input.dmri_fn;

            if (isfield(input, 'mask_fn')), output.mask_fn = input.mask_fn; end

        end

        function output = execute(obj, input, output)

            % diffusion data
            s.nii_fn = input.dmri_fn;
            s.xps = mdm_xps_load(input.xps_fn); 
            
            % s = mdm_s_from_nii(input.dmri_fn); 

            if (isfield(input, 'mask_fn'))
                s.mask_fn = input.mask_fn;
            end

            % this is not beautiful management of options
            if (~isfield(input, 'opt'))
                input.opt.present = 1;
            end

            opt = dti_lls_opt(input.opt);
            opt.filter_sigma = obj.filter_sigma;
            

            msf_mkdir(input.op);
            dti_lls_pipe(s, input.op, opt);

        end

    end

end




