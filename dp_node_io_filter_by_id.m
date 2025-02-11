classdef dp_node_io_filter_by_id < dp_node

    % Filter by ID, in either include or exclude filter_mode
    properties
        ids = {}
        filter_mode = 'include' % or exclude
    end

    methods

        function obj = dp_node_io_filter_by_id(ids, filter_mode)

            if (~iscell(ids)), ids = {ids}; end
            
            obj.ids = ids;

            if (nargin > 1), obj.filter_mode = filter_mode; end
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
            if (numel(outputs) > 1)
                obj.log(0, '\n%tFiltering: %i out of %i outputs will be %sd', ...
                    sum(status), numel(outputs), obj.filter_mode);
            end

            % Execute filter
            switch (obj.filter_mode)
                case 'include'
                    outputs = outputs(status);
                case 'exclude'
                    outputs = outputs(~status);
                otherwise
                    error('Unknown filtering filter_mode (%s)', obj.filter_mode)
            end
            

        end
    end


end
