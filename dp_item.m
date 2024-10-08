classdef dp_item

    % status methods
    methods(Static)


        function outputs = exclude(inputs, opt)

            % not sure this should be here, move to dp_opt
            opt = msf_ensure_field(opt, 'id_exclude', {});
            opt = msf_ensure_field(opt, 'log', @()1);

            if (isempty(opt.id_exclude))
                outputs = inputs;
                return;
            end

            ind_included = ones(size(inputs)) == 1;
            ind_excluded = ones(size(opt.id_exclude)) == 0;
            for c_exclude = 1:numel(opt.id_exclude)
                for c = 1:numel(inputs)
                    if (strcmp(inputs{c}.id, opt.id_exclude{c_exclude}))
                        ind_included(c) = 0;
                        ind_excluded(c_exclude) = 1;
                        break;
                    end
                end
            end

            outputs = inputs(ind_included);

            opt.log('Excluding %i items due to opt.id_exclude', ...
                sum(ind_excluded));

        end

        function outputs = filter(inputs, opt)

            % not sure this should be here, move to dp_opt
            opt = msf_ensure_field(opt, 'id_filter');
            opt = msf_ensure_field(opt, 'log', @(varargin)1);
            
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
                opt.log('--> Input filter active: %i out of %i ids passed', ...
                    sum(status), numel(inputs));
            end

            outputs = inputs(status);

        end



        % merge output streams
        function outputs = merge_outputs(list_of_outputs, list_of_prefixes)

            % list_of_outputs - a cell list of outputs
            %
            % can be merged if they have the same id

            outputs = {};
            for c = 1:numel(list_of_outputs)

                for c3 = 1:numel(list_of_outputs{c})

                    % current output
                    co = list_of_outputs{c}{c3};

                    % search for id's in existing list of outputs
                    c_match = -1;
                    for c2 = 1:numel(outputs)
                        if (strcmp(co.id, outputs{c2}.id))
                            c_match = c2;
                            break;
                        end
                    end

                    % take action
                    if (c_match == -1) % no match found
                        outputs{end+1}.id = co.id;
                        c_match = numel(outputs);
                    end

                    % add fields to existing
                    f = fieldnames(co);
                    outputs{c_match}.(list_of_prefixes{c}) = 1;
                    for c2 = 1:numel(f)
                        outputs{c_match}.([list_of_prefixes{c} '_' f{c2}]) = co.(f{c2});
                    end

                end
            end

            % only keep those with all prefixes present
            status = zeros(size(outputs)) == 1;
            for c = 1:numel(outputs)
                status(c) = all(cellfun(@(x) isfield(outputs{c}, x), list_of_prefixes));
            end

            outputs = outputs(status);

            % delete the prefixes
            for c = 1:numel(outputs)
                for c2 = 1:numel(list_of_prefixes)
                    outputs{c} = rmfield(outputs{c}, list_of_prefixes{c2});
                end
            end

        end

    end

end