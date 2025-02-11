classdef dp_node_io_filter_by_id < dp_node

    % Filter by ID, in either include or exclude mode
    properties
        ids = {}
        mode = 'include' % or exclude
    end

    methods

        function obj = dp_node_io_filter_by_id(ids, mode)

            if (~iscell(ids)), ids = {ids}; end
            
            obj.ids = ids;

            if (nargin > 1), obj.mode = mode; end
        end

        function outputs = process_outputs(obj, outputs)

            % Find matches
            status = ones(size(outputs)) == 0;
            for c = 1:numel(status)

                for c2 = 1:numel(obj.ids)

                    if (isequal(outputs{c}.id, obj.ids{c2}))
                        status(c) = true;
                        break;
                    end

                end

            end

            % Report on result of filtering
            if (numel(inputs) > 1)
                node.log(0, '%tFiltering: %i out of %i outputs will be %sd', ...
                    obj.mode, sum(status), numel(inputs));
            end

            % Execute filter
            switch (obj.mode)
                case 'include'
                    outputs = outputs(status);
                case 'exclude'
                    outputs = outputs(~status);
                otherwise
                    error('Unknown filtering mode (%s)', obj.mode)
            end
            

        end
    end


end
