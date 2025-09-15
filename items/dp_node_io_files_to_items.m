classdef dp_node_io_files_to_items < dp_node

    % packages files in a folder as items.(field_name), which you
    % set in the constructor
    %
    % filter_list accepts regular expressions, positive match excludes or 
    % inclues the file, depending on filter_mode 

    properties
        do_print_filter = 0;
        ext = '*'; % e.g. '*.zip' for zip files
        filter_list = {};
        filter_mode = 'exclude';
        field_name = 'item_fn';
    end

    methods

        function obj = dp_node_io_files_to_items(ext, field_name, ...
                filter_list, filter_mode)

            if (nargin >= 2), obj.field_name  = field_name; end
            if (nargin >= 3), obj.ext         = ext; end
            if (nargin >= 4), obj.filter_list = filter_list; end
            if (nargin >= 5), obj.filter_mode = filter_mode; end

        end

        function output = i2o(obj, input)

            output.items = {};
           
            if (~exist(input.ip, 'dir'))
                obj.log(1, 'missing input folder %s', input.ip); 
                return;
            end

            di = dir(fullfile(input.ip, obj.ext));

            obj.log(1, 'Searching in %s with extension %s gave %i outputs\n', input.ip, obj.ext, numel(di));

            for c = 1:numel(di)

                if (di(c).name(1) == '.')
                    continue;
                end
                
                switch (obj.filter_mode)

                    case 'exclude'

                        if (obj.do_filter(di(c).name))
                            obj.log(2, 'Skipping: %s:%s\n', input.id, di(c).name);
                            continue;
                        end

                    case 'include'

                        if (~obj.do_filter(di(c).name))
                            obj.log(2, 'Not including: %s:%s\n', input.id, di(c).name);
                            continue;
                        end
                        
                end

                tmp_input.(obj.field_name) = fullfile(input.ip, di(c).name);
                tmp_input.op = input.op;
                tmp_input.id = input.id;
                tmp_input.bp = input.bp;

                output.items{end+1} = tmp_input;
            end
        end
    end

    methods (Hidden)

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
        

    end
end