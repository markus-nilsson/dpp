classdef dp_node_dmri_topup_prep_merge < dp_node_io_merge

    % Merges datasets from multiple processing nodes for TOPUP preparation. Combines
    % data streams while maintaining proper organization and parameter tracking.

    properties
        names;
    end
    
    methods

        function obj = dp_node_dmri_topup_prep_merge(nodes)

            % incoming nodes should have just passed through 
            % dp_node_dmri_topup_prep_one

            % check that all incoming nodes have unique names
            names = cellfun(@(x) x.name, nodes, 'UniformOutput',false);

            if (numel(unique(names)) ~= numel(names))
                error('incoming nodes need to have unique names');
            end

            obj = obj@dp_node_io_merge(nodes); 

            obj.names = names;

        end

    end
end