classdef dp_node_dmri_dwibiascorrect < dp_node_workflow_tmp

    % run dwibiascorrect from mrtrix on a dmri_fn and xps_fn

    methods

        function obj = dp_node_dmri_dwibiascorrect()

            nodes = {...
                dp_node_dmri_io_xps_to_bval_bvec(), ...
                dp_node_mrtrix_dwibiascorrect(), ...
                dp_node_copy_and_rename({{'xps_fn', @(x) mdm_xps_fn_from_nii_fn(x.dmri_fn)}}).set('do_i2o_pass', 1), ...
                };

            obj = obj@dp_node_workflow_tmp(nodes, ...
                'dp_node_dmri_dwibiascorrect', ...
                {'dmri_fn', 'xps_fn'});

            obj.input_spec.add('dmri_fn', 'file', 1, 1, 'dMRI data');
            obj.input_spec.add('xps_fn', 'file', 1, 1, 'xps file');

            obj.output_spec.add('dmri_fn', 'file', 1, 1, 'dMRI data');
            obj.output_spec.add('xps_fn', 'file', 1, 1, 'xps file');

        end

    end

end
