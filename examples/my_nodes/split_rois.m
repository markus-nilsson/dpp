classdef split_rois < dp_node_roi_from_label

    properties
        roi_list
    end

    methods


        function obj = split_rois(name, segm_node, roi_list)
            obj = obj@dp_node_roi_from_label(name,segm_node);
            obj.roi_list = roi_list;

            slab_suffix = {'_I','_II','_III'};

            % find ROI ids from the segm node's vocabulary
            base_ids = [];
            for k = 1:numel(roi_list)
                hit = find(strcmpi(obj.roi_names, roi_list{k}), 1);
                if ~isempty(hit)
                    % extract numeric value if roi_ids is a cell array
                    if iscell(obj.roi_ids)
                        base_ids(end+1) = obj.roi_ids{hit};
                    else
                        base_ids(end+1) = obj.roi_ids(hit);
                    end
                else
                    warning('split_rois: tract %s not found', roi_list{k});
                end
            end

            % assign three new IDs per base tract
            next_id = max([obj.roi_ids{:}]) + 1;   % unwrap cells if needed


            for i = 1:numel(base_ids)
                base_name = obj.roi_names{i};   % or your roi_list{i}
                for s = 1:3
                    obj.roi_ids{end+1}   = next_id;
                    obj.roi_names{end+1} = [roi_list{i} slab_suffix{s}];
                    next_id = next_id + 1;
                end
            end

        end

        function [R,h] = roi_get_volume(obj, output, ~, c_roi)

            rid = obj.roi_ids;
            if iscell(rid), ridv = [rid{:}]; else, ridv = rid; end
            ix = find(ridv == c_roi, 1);

            name = obj.roi_names{ix};

            % --- is this one of our synthetic slabs? (… I / II / III) ---
            if endsWith(name,'_I') || endsWith(name,'_II') || endsWith(name,'_III')

                % which slab is requested?
                if     endsWith(name,'_I'),   slab = 1;
                elseif endsWith(name,'_II'),  slab = 2;
                else                          slab = 3;
                end

                % base tract name without the suffix
                base_name = regexprep(name, '(_I|_II|_III)$', '');

                % look up the base tract's ROI id by exact (case-insensitive) name
                ix_base = find(strcmpi(obj.roi_names, base_name), 1);

                if iscell(rid), base_id = rid{ix_base}; else, base_id = rid(ix_base); end

                % fetch the base mask via the parent implementation
                [R,h] = roi_get_volume@dp_node_roi_from_label(obj, output, 1, base_id);

                switch slab
                    case 1
                        R(:, :, 44:end) = 0;
                    case 2
                        R(:, :, 1:44) = 0;
                        R(:, :, 66:end) = 0;
                    case 3
                        R(:, :, 1:66) = 0;
                end

            else
                [R,h] = roi_get_volume@dp_node_roi_from_label(obj, output, 1, c_roi);
            end


        end

    end


end