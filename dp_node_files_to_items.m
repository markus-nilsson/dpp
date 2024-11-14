classdef dp_node_files_to_items < dp_node_items

    % packages zip files in a folder as items
    %
    % filter_list accepts regular expressions, positive match excludes or 
    % inclues the file, depending on filter_mode 

    properties
        do_print_filter = 0;
        ext = '*'; % e.g. '*.zip' for zip files
        filter_list = {};
        filter_mode = 'exclude'; 
    end

    methods

        function obj = dp_node_files_to_items(inner_node, ext, filter_list, filter_mode)

            obj = obj@dp_node_items(inner_node);

            if (nargin >= 2), obj.ext         = ext; end
            if (nargin >= 3), obj.filter_list = filter_list; end
            if (nargin >= 4), obj.filter_mode = filter_mode; end

        end

        function yes_no = do_filter(obj, fn)
            
            yes_no = 0; % (default is opposite of match)

            if (isempty(obj.filter_list)), return; end

            for c = 1:numel(obj.filter_list)

                if (~isempty(regexp(fn, obj.filter_list{c})))
                    yes_no = 1; % yes
                    return;
                end

            end

        end

        function input = po2i(obj, po)

            % xxx: split this class into more and glue with workflow
            %      we should not use po2i this way!
            %      as this does not allow proper error handling
            if (~isfield(po, 'ip'))
                error('missing field ip');
            end

            % expect:
            % po.ip (input folder with files of type ext)
            % po.op (output folder)

            di = dir(fullfile(po.ip, obj.ext));

            input.items = {};
            for c = 1:numel(di)

                if (di(c).name(1) == '.')
                    continue;
                end
                
                switch (obj.filter_mode)

                    case 'exclude'

                        if (obj.do_filter(di(c).name))
                            if (obj.do_print_filter)
                                obj.log('Skipping: %s:%s\n', po.id, di(c).name);
                            end
                            continue;
                        end

                    case 'include'

                        if (~obj.do_filter(di(c).name))
                            if (obj.do_print_filter)
                                obj.log('Not including: %s:%s\n', po.id, di(c).name);
                            end
                            continue;
                        end
                        
                end

                tmp_input.zip_fn = fullfile(po.ip, di(c).name);
                tmp_input.op = po.op;
                tmp_input.id = po.id;
                tmp_input.bp = po.bp;

                [~,name] = msf_fileparts(tmp_input.zip_fn);
                tmp_input.dcm_name = name;
                
                input.items{end+1} = tmp_input;
            end
        end


    end
end