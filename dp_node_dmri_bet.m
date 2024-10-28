classdef dp_node_dmri_bet < dp_node_workflow

    methods

        function obj = dp_node_dmri_bet()

            nodes = {...
                dp_node_append({...
                    {'original_op', 'op'}, ...
                    {'op', @(x) x.tmp.bp}}), ...
                dp_node_dmri_subsample(@(xps) find(xps.b == min(xps.b), 1, 'first'), '_b0'), ...
                dp_node_append({...
                    {'nii_fn', 'dmri_fn'}, ...
                    {'op', 'original_op'}}), ...
                dp_node_fsl_bet()};

            nodes{2}.do_i2o_pass = 1;

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