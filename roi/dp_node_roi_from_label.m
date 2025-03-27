classdef dp_node_roi_from_label < dp_node_roi & dp_node_core_roi

    properties (Hidden)
        last_labels_fn = [];
        cache;
    end

    methods

        function obj = dp_node_roi_from_label(name, segm_node)

            roi_names = segm_node.segm_labels();
            roi_ids   = segm_node.segm_ids();

            obj = obj@dp_node_roi(name, msf_tmp_path, roi_names);
            obj.roi_use_single = 1; % assume label applies to all contrats
            obj.roi_ids = roi_ids;
        end

        function output = i2o(obj, input)
            output = i2o@dp_node_roi(obj, input);
            output.labels_fn = input.labels_fn; % pass through label for roi_fn
        end

        function roi_fn = roi_get_fn(obj, output, f, c_roi)
            
            % this function makes a temporary roi file
            % not the best for execution speed, but try it for now

            if (obj.is_in_parallel())
                error('not built for parallel execution yet');
                % get thread id for future multi-threaded executions
            else
                c_core = 1; 
            end

            % xxx: make this robust for future use, by better naming
            roi_fn = fullfile(msf_tmp_path, sprintf('roi_core%i.nii.gz', c_core));

            [R,h] = obj.roi_get_volume(output, f, c_roi);

            mdm_nii_write(uint8(R), roi_fn, h, 0);

        end

        function [R,h] = roi_get_volume(obj, output, ~, c_roi)

            % implement caching here, to speed things up
            if (~strcmp(output.labels_fn, obj.last_labels_fn))
                obj.last_labels_fn = output.labels_fn;

                [R,h] = mdm_nii_read(output.labels_fn);

                obj.cache.R = R;
                obj.cache.h = h;
            else
                R = obj.cache.R;
                h = obj.cache.h;
            end

            switch (ndims(R))
                case 3
                    ids = obj.roi_ids{c_roi};

                    O = zeros(h.dim(2), h.dim(3), h.dim(4)); 

                    for c = 1:numel(ids)
                        O = O | (R == ids(c));
                    end
                    R = O;
                case 4
                    R = R(:, :, :, obj.roi_ids(c_roi));
                otherwise
                    error('strange dimension of ROI file');
            end

        end


        function answer = is_in_parallel(~)
            try
                answer = ~isempty(getCurrentTask());
            catch err
                answer = false;
            end
        end

    end
end