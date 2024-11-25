classdef dp_node_items_from_files < dp_node_items

    % packages files in a folder as items

    properties
        do_print_filter = 0;
        ext = '*.*'; % e.g. '*.zip' for zip files
        filter_list = {};
        filter_mode = 'exclude'; 
    end

    methods

        function obj = dp_node_items_from_files(ext, filter_list, filter_mode)

            obj = obj@dp_node_items(dp_node);

            if (nargin >= 1), obj.ext         = ext; end
            if (nargin >= 2), obj.filter_list = filter_list; end
            if (nargin >= 3), obj.filter_mode = filter_mode; end

            % help the user
            if (~iscell(obj.filter_list))
                obj.filter_list = {obj.filter_list};
            end

            % expect:
            % po.ip (input folder with files of type ext)
            % po.op (output folder)            
            obj.input_fields = {'ip', 'op'};

        end

        function input = po2i(~, po)
            input = po; % overload, to allow creation of items
        end

        % overloading to get things to work, but not nice
        function output = run_on_one(obj, input, output)
            output = obj.get_dpm().run_on_one(input, output);
        end          
        
        function output = i2o(obj, input)

            di = dir(fullfile(input.ip, obj.ext));

            output = input;
            output.items = {};
            for c = 1:numel(di)

                if (di(c).name(1) == '.')
                    continue;
                end
                
                switch (obj.filter_mode)

                    case 'exclude'

                        if (obj.do_filter(di(c).name))
                            if (obj.do_print_filter)
                                obj.log(0, 'Skipping: %s:%s\n', po.id, di(c).name);
                            end
                            continue;
                        end

                    case 'include'

                        if (~obj.do_filter(di(c).name))
                            if (obj.do_print_filter)
                                obj.log(0, 'Not including: %s:%s\n', po.id, di(c).name);
                            end
                            continue;
                        end
                        
                end

                % found a match
                item.this_fn = fullfile(input.ip, di(c).name);
                
                % transfer mandatory files
                item.bp = input.bp;
                item.id = input.id;
                item.op = input.op;

                output.items{end+1} = item;
            end
        end
    
        function yes_no = do_filter(obj, fn)
            
            yes_no = 0; % (default is opposite of match)

            if (isempty(obj.filter_list)), return; end

            for c = 1:numel(obj.filter_list)

                if (~isempty(regexp(fn, obj.filter_list{c}, 'once')))
                    yes_no = 1; % yes
                    return;
                end

            end

        end        

    end
end