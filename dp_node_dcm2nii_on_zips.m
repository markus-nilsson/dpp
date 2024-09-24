classdef dp_node_dcm2nii_on_zips < dp_node_items

    properties
        do_print_skip = 0;
    end

    methods

        function obj = dp_node_dcm2nii_on_zips()          
            obj = obj@dp_node_items(dp_node_unzip_dcm2nii());
        end

        function yes_no = do_skip(obj, fn)
            yes_no = 0;
        end

        function input = po2i(obj, po)

            % expect:
            % po.ip (input folder with zips)
            % po.op (output folder with zips)

            di = dir(fullfile(po.ip, '*.zip'));

            input.items = {};
            for c = 1:numel(di)

                if (obj.do_skip(di(c).name))
                    if (obj.do_print_skip)
                        obj.log('Skipping: %s:%s\n', po.id, di(c).name);
                    end
                    continue;
                end

                tmp_input.dcm_zip_fn = fullfile(po.ip, di(c).name);
                tmp_input.bp = po.op;
                tmp_input.id = po.id;

                [~,name] = msf_fileparts(tmp_input.dcm_zip_fn);
                tmp_input.dcm_name = name;
                
                input.items{end+1} = tmp_input;
            end
        end
        
    end
end