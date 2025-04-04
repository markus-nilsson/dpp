classdef dp_node_io_filter_by_id < dp_node

    % Filter by ID, in either include or exclude filter_mode

    % xxx: Weak implementation as of now  (2025-03-28)

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

        function output = i2o(obj, input)

            % Just pass through if all is good
            output = input;

            % Check for a match
            is_match = 0;
            for c = 1:numel(obj.ids)
                if (isequal(input.id, obj.ids{c}))
                    is_match = 1;
                end
            end

            % Deal with the consequences
            switch (obj.filter_mode)
                case 'include'
                    if (~is_match), error('Subject not included'); end
                case 'exclude'
                    if (is_match), error('Subject excluded'); end
                otherwise
                    error('invalid filter_mode (%s)', obj.filter_mode);
            end


        end

        function outputs = process_outputs(obj, outputs)

            status = dp_node_io_filter_by_id.match_filter(...
                outputs, obj.ids);

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

    methods (Static)

        function status = match_filter(outputs, filter)

            % Find matches
            status = ones(size(outputs)) == 0;
            
            for c = 1:numel(status)

                for c2 = 1:numel(filter)

                    if (isequal(outputs{c}.id, filter{c2}))
                        status(c) = true;
                        break;
                    end
                end
            end
        end
    end


end
