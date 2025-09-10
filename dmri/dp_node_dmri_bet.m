classdef dp_node_dmri_bet < dp_node_workflow

    % Brain extraction workflow for diffusion MRI data using FSL BET. Extracts a brain mask
    % by processing the b0 image and applies the mask to the full diffusion dataset.

    methods

        function obj = dp_node_dmri_bet(opt_str)

            if (nargin == 0), opt_str = ''; end

            nodes = {...
                dp_node_io_append({...
                    {'original_op', 'op'}, ...
                    {'original_dmri_fn', 'dmri_fn'}, ...
                    {'op', @(x) x.tmp.bp}}), ...
                dp_node_dmri_subsample(@(xps) (1:xps.n) == find(xps.b == min(xps.b), 1, 'first'), '_b0'), ...
                dp_node_io_append({...
                    {'nii_fn', 'dmri_fn'}, ...
                    {'op', 'original_op'}}), ...
                dp_node_fsl_bet(opt_str), ...
                dp_node_io_rename({...
                    {'dmri_fn', 'original_dmri_fn'}, ...
                    {'mask_fn', 'mask_fn'}})};

            nodes{2}.do_i2o_pass = 1;
            nodes{4}.do_i2o_pass = 1;

            obj = obj@dp_node_workflow(nodes);

        end

        function input = po2i(obj, po)

            input = po;

            % This will become a part of the output of the second
            % node above, so it will be properly cleaned
            input.tmp.bp = msf_tmp_path();
            input.tmp.do_delete = 1;

        end

    end
end