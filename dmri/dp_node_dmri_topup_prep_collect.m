classdef dp_node_dmri_topup_prep_collect < dp_node

    % Collect volumes prepared for topup

    % assume previous node is dp_node_dmri_topup_prep_merge

    
    methods

        function output = i2o(~, input)           
            output.topup_nii_fn = fullfile(input.op, 'topupinput.nii.gz');
            output.topup_spec_fn = fullfile(input.op, 'topup.txt');
        end

        function output = execute(obj, input, output)

            % assume previous node is dp_node_dmri_topup_prep_merge
            names = obj.previous_node.names;

            % merge niftis
            nii_fns = cellfun(@(x) input.(cat(2, x, '_nii_fn')), names, ...
                'UniformOutput', false);
            mdm_nii_merge(nii_fns, output.topup_nii_fn);

            % merge spec file
            txt = cell(1, numel(names));
            for c = 1:numel(names)
                tmp = mdm_txt_read(input.(cat(2, names{c}, '_spec_fn')));
                txt{c} = tmp{1};
            end
            mdm_txt_write(txt, output.topup_spec_fn);

        end

    end
end