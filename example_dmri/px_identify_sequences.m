classdef px_identify_sequences < dp_node

    methods 

        function obj = px_identify_sequences()
            bp = '/media/fuji/MyBook1/BOF130_APTw/data/seg';
            obj.previous_node = p0_list_subjects(bp);
        end

        function output = i2o(obj, input)

            output.bp = input.bp;

            nii_path = fullfile(input.bp, input.id, 'normalized_bet');

            output.t1_fn = msf_find_fn(nii_path, 't1_bet_normalized.nii.gz');
            output.flair_fn = msf_find_fn(nii_path, 'fla_bet_normalized.nii.gz');
            output.t2_fn = msf_find_fn(nii_path, 't2_bet_normalized.nii.gz');
            output.t1c_fn = msf_find_fn(nii_path, 't1c_bet_normalized.nii.gz');



            output.vis.field_names = {'t1_fn', 'flair_fn', 't2_fn', 't1c_fn'};
            output.vis.bp = fullfile(input.bp, '..', 'reports');
            

        end

    end

end


