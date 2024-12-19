classdef dp_node_segm_brats_plus_md < dp_node_segm

    methods

        % construct names of output files
        function output = i2o(~, input)

            % mav or simple is the choice here
            output = input;
            output.labels_fn = fullfile(input.op, 'seg_with_md.nii.gz');
            
        end

        function output = execute(~, input, output)

            MD = mdm_nii_read(input.md_fn); 
            [L,h] = mdm_nii_read(input.labels_fn);

            N = ((L == 1) | (L == 4)) & (MD > 2.5);

            L(N(:) > 0) = 8;

            mdm_nii_write(uint8(L), output.labels_fn, h);


        end
    end

    methods (Hidden)

        function [labels, ids] = segm_info(obj)

            labels = {...
                'Tumor', ...
                'Odema', ...
                'CE', ...
                'Necrosis', ...
                'Tumor incl CE and N', ...
                'Tumor incl CE'};
            ids    = {1, 2, 4, 8, [1 4 8], [1 4]};

        end

    end
end