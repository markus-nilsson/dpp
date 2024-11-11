classdef dp_node_io_merge < dp_node_base

    % merges previous nodes
    %
    % will be called by a dpm iter block
    %
    % consider using items

    methods

        function obj = dp_node_io_merge(nodes)
            obj.previous_node = nodes;
        end

        function previous_outputs = get_iterable(obj)

            % grab previous output from each previous node
            list_of_outputs = cell(size(obj.previous_node));
            for c = 1:numel(obj.previous_node)
                list_of_outputs{c} = obj.previous_node{c}.run(...
                    obj.opt.iter_mode, obj.opt);
            end

            % keep only those outputs where the ids intersect
            previous_outputs = dp_node_io_merge.intersect_outputs(list_of_outputs);

            % rename (legacy)
            previous_outputs = dp_node_io_merge.rename_outputs(previous_outputs, ...
                obj.previous_node);

            % report on outcome
            obj.log(0, '--> Merging outputs resulted in %i items', ...
                numel(previous_outputs));
        end


        function obj = update_node(obj, varargin) % update involved nodes

            obj = update_node@dp_node_base(obj, varargin{:});

            for c = 1:numel(obj.previous_node)
                obj.previous_node{c}.update_node(varargin{:});
            end

        end

        function [status, f, age] = input_exist(obj, input)
            status = []; f = []; age = []; % implement later
            %[status, f, age] = obj.io_exist2(input, obj.input_test);
        end

        function [status, f, age] = output_exist(obj, output)
            status = []; f = []; age = [];
            %[status, f, age] = obj.io_exist2(output, obj.output_test);
        end

    end

    methods (Static)

        % select intersect of outputs
        function outputs = intersect_outputs(list_of_outputs)

            % Pull out a list of id:s 
            ids = cell(size(list_of_outputs));
            for c = 1:numel(list_of_outputs)
                ids{c} = cellfun(@(x) x.id, list_of_outputs{c}, 'uniformoutput', 0);

                if (numel(ids{c}) ~= numel(unique(ids{c})))
                    obj.log(0, 'non unique ids detected in dp_node_merge');
                    error('assuming unique ids for the merge to work');
                end
            end

            % Find unique ids
            unique_ids = unique([ids{:}]);

            % find 
            ind = zeros(numel(unique_ids), numel(list_of_outputs));
            
            for i = 1:numel(unique_ids)
                for j = 1:numel(list_of_outputs)

                    tmp = cellfun(@(x)strcmp(x.id,unique_ids{i}), ...
                        list_of_outputs{j});

                    if (sum(tmp) == 0)
                        continue;
                    end

                    ind(i,j) = find(tmp);
                end
            end

            % keep only those with occurrances in each
            tmp = sum(ind > 0, 2) == numel(list_of_outputs);

            unique_ids = unique_ids(tmp);
            ind = ind(tmp, :);

            % assemble the intersect
            outputs = cell(1, numel(unique_ids));
            for i = 1:numel(unique_ids)

                tmp = struct('id', unique_ids{i});
                
                for j = 1:numel(list_of_outputs)
                    tmp.output{j} = list_of_outputs{j}{ind(i,j)};
                end

                outputs{i} = tmp;
            end

        end

        function outputs = rename_outputs(inputs, nodes)

            % grab node names
            names = cell(size(nodes));
            for c = 1:numel(nodes)
                names{c} = nodes{c}.name;
            end

            % we need unique names
            if (numel(names) ~= numel(unique(names)))
                error('merging previous nodes requires unique node names');
            end

            % rename fields
            outputs = cell(size(inputs));
            for i = 1:numel(inputs)

                outputs{i}.id = inputs{i}.id;

                for j = 1:numel(inputs{i}.output)
                    tmp = inputs{i}.output{j};
                
                    f = fieldnames(tmp);

                    for k = 1:numel(f)
                        outputs{i}.([names{j} '_' f{k}]) = tmp.(f{k});
                    end
                end

                % set required fields to that of first node to merge
                outputs{i}.bp = inputs{i}.output{1}.bp;
                outputs{i}.op = inputs{i}.output{1}.op;
                outputs{i}.id = inputs{i}.output{1}.id;
            end

        end

        % merge output streams
        function outputs = merge_outputs(list_of_outputs, list_of_prefixes)

            % list_of_outputs - a cell list of outputs
            %
            % can be merged if they have the same id
            error('deprecated');

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