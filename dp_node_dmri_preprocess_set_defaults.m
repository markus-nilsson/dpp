classdef dp_node_dmri_preprocess_set_defaults < dp_node_workflow

    % Builds an input structure suitable for dmri operations
    % with outputs as follows
    %
    % dmri_fn
    % bval_fn
    % bvec_fn
    % json_fn
    % xps_fn

    methods

        function obj = dp_node_dmri_preprocess_set_defaults(input_field_name, xps)
            
            % only use the xps argument if you want to force ans xps upon
            % the data, otherwise, it uses the data from bval bvec
            %
            % this now assumes LTE (b_delta = 1)

            if (nargin < 2), xps = []; end

            nodes = {dp_node_io_rename({{'dmri_fn', input_field_name}})};

            if (isempty(xps))

                % adds dmri_fn, bval_fn, bvec_fn
                nodes{end+1} = dp_node_dmri_io_bval_bvec('dmri_fn');

                % make the xps_fn
                b_delta = 1; % assume linear tensor encoding
                nodes{end+1} = dp_node_dmri_xps_from_bval_bvec(b_delta);

            else

                % force an xps onto the data
                nodes{end+1} = dp_node_dmri_xps_force(xps);

                % make bval bvec from this xps
                nodes{end+1} = dp_node_dmri_io_xps_to_bval_bvec();

            end

            % add the json_fn
            function json_fn = dmri2json_fn(dmri_fn)
                [p,n] = msf_fileparts(dmri_fn);
                json_fn = fullfile(p, cat(2, n, '.json'));
            end
            nodes{end+1} = dp_node_io('json_fn', @(x) dmri2json_fn(x.dmri_fn));


            obj = obj@dp_node_workflow(nodes);

        end
    end

end