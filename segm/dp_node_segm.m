classdef dp_node_segm < dp_node

    methods

        function ids = segm_ids(obj)
            [~,ids] = obj.segm_info();
        end

        function labels = segm_labels(obj)
            labels = obj.segm_info();
        end

    end

    methods (Hidden, Abstract)
        [labels, ids] = segm_info(obj);
    end

end