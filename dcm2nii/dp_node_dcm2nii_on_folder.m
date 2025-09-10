classdef dp_node_dcm2nii_on_folder < dp_node_items

    % this runs dcm2nii_and_xps on folders with dicoms
    %
    % expects the following of the outputs of the previous node
    % ip - input path to dcms
    % op - output path to dcs

    properties
        do_print_skip = 0;
    end

    methods

        function obj = dp_node_dcm2nii_on_folder()          
            obj = obj@dp_node_items(dp_node_dcm2nii_and_xps());
        end

        function input = po2i(obj, po)

            % expect:
            % po.ip (input folder with zips)
            % po.op (output folder with zips)

            if (~exist(po.ip, 'dir'))
                error('could not find input path (ip)');
            end

            di = dir(fullfile(po.ip));

            input.items = {};
            for c = 1:numel(di)

                if (~di(c).isdir), continue; end
                if (di(c).name(1) == '.'), continue; end

                % if (obj.do_skip(di(c).name))
                %     if (obj.do_print_skip)
                %         obj.log('Skipping: %s:%s\n', po.id, di(c).name);
                %     end
                %     continue;
                % end

                tmp_input.dcm_folder = fullfile(po.ip, di(c).name);
                
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