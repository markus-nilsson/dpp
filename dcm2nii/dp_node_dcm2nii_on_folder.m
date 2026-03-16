classdef dp_node_dcm2nii_on_folder < dp_node_items

    % this runs dcm2nii on folders with folders with dicoms
    %
    % expects the following of the outputs of the previous node
    % ip - input path to folders of dicoms
    % op - output path to niis

    properties
        do_print_skip = 0;
    end

    methods

        function obj = dp_node_dcm2nii_on_folder()          
            obj = obj@dp_node_items(dp_node_dcm2nii());
        end

        function yes_no = do_skip(obj, name)

            yes_no = 0;

            if (strfind(name, 'PhysioLog'))
                yes_no = 1; 
                return;
            end

            if (strfind(name, '_PMU'))
                yes_no = 1; 
                return;
            end


        end

        function input = po2i(obj, po)

            if (~exist(po.ip, 'dir'))
                error('could not find input path (ip)');
            end

            di = dir(fullfile(po.ip));

            input.items = {};

            for c = 1:numel(di)

                if (~di(c).isdir), continue; end
                if (di(c).name(1) == '.'), continue; end

                dcm_folder = fullfile(po.ip, di(c).name);

                % Skip physiolog et c
                if (obj.do_skip(dcm_folder))
                    continue;
                end

                tmp_input.dcm_folder = dcm_folder;
                
                tmp_input.bp = po.bp;
                tmp_input.op = po.op;

                x = tmp_input.dcm_folder;
                if (x(end) == filesep), x = x(1:(end-1)); end
                tmp_input.dcm_name = x((1+find(x == filesep, 1, 'last')):end);  
                
                tmp_input.id = po.id;

                % we haven't really decided on naming here... 
                
                input.items{end+1} = tmp_input;
            end
        end
        
    end

end