classdef dp_node_core_roi < handle

    % implements methods to attach regions of interests to nodes

    % having this as a core function allows all nodes to have a basic
    % interaction mode where we can interact with the output
    
    % default setting is that roi's are saved in a temporary folder, 
    % thereby being reset by every construction of the pipeline 

    properties

        roi_use_single = false; % True - all have the same resolution

        roi_bp; % base path for the roi's

        roi_names; % cell array

        roi_ids; % array of ids, usually just 1's for separate ROIs, but different for labels

        roi_can_be_modified = true; % False not yet implemented (!)

    end

    methods

        function obj = dp_node_core_roi()
            obj.roi_names = {'Temporary'};
            obj.roi_bp = msf_tmp_path(1);
        end

        function roi_fn = roi_get_fn(obj, output, f, c_roi)

            bp = fullfile(obj.roi_bp, output.id, obj.name);

            if (obj.roi_use_single)
                roi_fn = fullfile(bp, cat(2, obj.roi_names{c_roi}, '.nii.gz'));
            else
                roi_fn = fullfile(bp, cat(2, obj.roi_names{c_roi}, '_', f, '.nii.gz'));
            end

        end

    end

end