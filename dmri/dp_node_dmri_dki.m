classdef dp_node_dmri_dki < dp_node

    % Performs Diffusion Kuirtosis Imaging (DKI) analysis using linear least squares fitting.
    % Computes standard DKI metrics 

    properties
        filter_sigma = 0;
    end

    methods

        function obj = dp_node_dmri_dki(filter_sigma)
            obj.input_test = {'dmri_fn'};
            obj.output_test = {'md_fn', 'fa_fn', 's0_fn', 'fa_col_fn', 'mk_fn'};
            
            if (nargin > 0)
                obj.filter_sigma = filter_sigma;
            end
        end

        function output = i2o(obj, input)
            
            output.md_fn = fullfile(input.op, 'dki_lls_MD.nii.gz');
            output.mk_fn = fullfile(input.op, 'dki_lls_MK.nii.gz');
            output.fa_fn = fullfile(input.op, 'dki_lls_FA.nii.gz');
            output.fa_col_fn = fullfile(input.op, 'dki_lls_FA_u_rgb.nii.gz');
            output.s0_fn = fullfile(input.op, 'dki_lls_s0.nii.gz');

            % pass info about the dmri fn, and mask_fn if existent
            output.dmri_fn = input.dmri_fn;

            if (isfield(input, 'mask_fn')), output.mask_fn = input.mask_fn; end

        end

        function output = execute(obj, input, output)

            % diffusion data
            s.nii_fn = input.dmri_fn;
            s.xps = mdm_xps_load(input.xps_fn); 
            
            if (isfield(input, 'mask_fn'))
                s.mask_fn = input.mask_fn;
            end

            % this is not beautiful management of options
            if (~isfield(input, 'opt'))
                input.opt.present = 1;
            end

            opt = dki_lls_opt(input.opt);
            opt.filter_sigma = obj.filter_sigma;
            
            msf_mkdir(input.op);
            dki_lls_pipe(s, input.op, opt);

        end

    end

end




