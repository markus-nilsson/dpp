classdef dp_node_io_merge < dp_node

    % merges previous nodes
    %
    % will be called by a dpm iter block
    %
    % consider using items
    properties
        previous_nodes = {};
        do_prefix = 1; % add node name as prefix to merged fields
        % 0 - do not do this for the first node to be merged
    end

    methods

        function obj = dp_node_io_merge(varargin)
            if (nargin == 1)
                nodes = varargin{1};
            else
                nodes = varargin;
            end
            obj.previous_nodes = nodes;
        end

        function previous_outputs = get_iterable(obj)

            % in deep mode, return leftmost arm always
            %  (xxx: subject to change)
            if (obj.opt.deep_mode)
                previous_outputs = obj.previous_nodes{1}.get_iterable();
                return;
            end

            % grab previous output from each previous node
            list_of_outputs = cell(size(obj.previous_nodes));
            for c = 1:numel(obj.previous_nodes)
                list_of_outputs{c} = ...
                    obj.previous_nodes{c}.i_run(obj.opt.iter_mode);;
            end

            % keep only those outputs where the ids intersect
            previous_outputs = dp_node_io_merge.intersect_outputs(list_of_outputs);

            % rename (legacy)
            previous_outputs = dp_node_io_merge.rename_outputs(previous_outputs, ...
                obj.previous_nodes, obj.do_prefix);

            % report on outcome
            obj.log(0, '%t--> Merging outputs resulted in %i items', ...
                numel(previous_outputs));
        end

        function output = run_inner(obj, po)

            % assume we are in deep mode, otherwise do usual one
            if (~obj.opt.deep_mode)
                output = run_inner@dp_node(obj, po);
                return;
            end

            % grab previous output from each previous node
            pos = cell(size(obj.previous_nodes));
            for c = 1:numel(obj.previous_nodes)
                obj.previous_nodes{c}.mode = obj.mode;
                pos{c} = {obj.previous_nodes{c}.run_inner(po)};
            end

            % keep only those outputs where the ids intersect
            pos = dp_node_io_merge.intersect_outputs(pos);

            % rename (legacy)
            pos = dp_node_io_merge.rename_outputs(pos, ...
                obj.previous_nodes, obj.do_prefix);

            output = pos{1};

            %output = run_inner@dp_node(obj, po);


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

        function outputs = rename_outputs(inputs, nodes, do_prefix)

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

                        % skip workflow stuff
                        if (isequal(f{k}, 'wf_input')), continue; end 
                        if (isequal(f{k}, 'wf_output')), continue; end 
                    

                        if (do_prefix) || (j > 1)
                            new_fieldname = [names{j} '_' f{k}];
                        else
                            new_fieldname = f{k};
                        end

                        outputs{i}.(new_fieldname) = tmp.(f{k});
                    end
                end

                % set required fields to that of first node to merge
                outputs{i}.bp = inputs{i}.output{1}.bp;
                outputs{i}.id = inputs{i}.output{1}.id;

                % Look through outouts for an op, take the first you find
                for k = 1:numel(inputs{i}.output)
                    if (isfield(inputs{i}.output{k}, 'op'))
                        outputs{i}.op = inputs{i}.output{k}.op;
                        break;
                    end
                end
                
            end

        end

    end

    methods (Hidden)

        function nodes = get_previous_nodes(obj)
            nodes = obj.previous_nodes;           
        end        
    end

end