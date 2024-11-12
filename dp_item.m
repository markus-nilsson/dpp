classdef dp_item

    % status methods
    methods(Static)


        function outputs = exclude(inputs, node, id_exclude)

            % Prefer to use input, but for legacy reasons, use opt
            if (nargin < 3)
                if (isfield(node.opt, 'id_exclude'))
                    id_exclude = node.opt.id_exclude; 
                else
                    id_exclude = {};
                end
            end

            % Return if there is nothing to exclude
            if (isempty(id_exclude))
                outputs = inputs;
                return;
            end

            % Go through and exclude subjects based on their id's
            ind_included = ones(size(inputs)) == 1;
            ind_excluded = ones(size(id_exclude)) == 0;
            for c_exclude = 1:numel(id_exclude)
                for c = 1:numel(inputs)
                    if (strcmp(inputs{c}.id, id_exclude{c_exclude}))
                        ind_included(c) = 0;
                        ind_excluded(c_exclude) = 1;
                        break;
                    end
                end
            end

            outputs = inputs(ind_included);

            node.log(0, '%tExcluding %i items due to id_exclude', ...
                sum(ind_excluded));

        end

        function outputs = filter(inputs, node)

            % move to the same structure as exclude, eventually

            % not sure this should be here, move to dp_opt
            opt = node.opt;
            opt = msf_ensure_field(opt, 'id_filter');
            
            if (isempty(opt.id_filter))
                outputs = inputs;
                return;
            end

            if (~iscell(opt.id_filter))
                opt.id_filter = {opt.id_filter};
            end

            % Filter the list, if asked for
            status = ones(size(inputs)) == 0;
            for c = 1:numel(inputs)
                for c2 = 1:numel(opt.id_filter) % assume this is a cell array
                    if (strcmp(inputs{c}.id, opt.id_filter{c2}))
                        status(c) = 1 > 0;
                        break;
                    end
                end
            end

            % Avoid repeated displays
            if (numel(inputs) > 1)
                node.log(0, '%i--> Input filter active: %i out of %i ids passed', ...
                    sum(status), numel(inputs));
            end

            outputs = inputs(status);

        end

    end

end