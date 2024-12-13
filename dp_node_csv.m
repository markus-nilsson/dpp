classdef dp_node_csv < dp_node

    % takes information from an dp_node_roi node and writes it to 
    % a csv file (or text file, really)

    properties
        bp_csv; 
        vars; % e.g. mean, std, median, mad et cetera
    end


    methods

        function obj = dp_node_csv(name, bp_csv, vars)
            % meaningful name needed, as this becomes the file name
            obj.name = name; 
            
            % csv collection for all subjects  
            obj.bp_csv = bp_csv;
            
            % which variables to export to the csv
            obj.vars = vars;
        end

        function output = i2o(obj, input)
            output.csv_fn = fullfile(input.op, 'csv', cat(2, obj.name, '.txt'));
        end

        function output = execute(obj, input, output)

            % verify that previous node is of the right type
            if (~isa(obj.previous_node, 'dp_node_roi'))
                error('need previous node to be an roi type')
            end
            
            % load the output
            info = load(input.roi_stats_fn);
            info = info.info;

            h_str = 'id, '; % header string 
            d_str = sprintf('%s, ', input.id); % data string
            for c_roi = 1:numel(info.roi_stats)

                roi_stat = info.roi_stats(c_roi);

                f = fieldnames(roi_stat);

                for c_field = 1:numel(f) % contrast, e.g. md, fa

                    for c_var = 1:numel(obj.vars) % stat, e.g, mean, median

                        % construct header string
                        tmp = cat(2, ...
                            info.roi_names{c_roi}, '_', ...
                            f{c_field}, '_', ...
                            obj.vars{c_var});

                        h_str = cat(2, h_str, tmp, ', ');

                        % construct data string
                        tmp = sprintf('%1.4f', roi_stat.(f{c_field}).(obj.vars{c_var}));
                        d_str = cat(2, d_str, tmp, ', ');

                    end

                end

            end

            h_str = h_str(1:(end-2)); % delete the last ', '
            d_str = d_str(1:(end-2)); % delete the last ', '
            

            txt = {h_str, d_str};

            msf_mkdir(fileparts(output.csv_fn));
            mdm_txt_write(txt, output.csv_fn);

        end

        function outputs = execute_on_outputs(obj, outputs)

            % create file with time stamp
            date_time_str = char(datetime('now', 'format', 'yyyy-MM-dd--HH-mm'));
            txt_fn = fullfile(obj.bp_csv, cat(2, obj.name, '_', ...
                date_time_str, '.txt'));

            % collect and save outputs
            txt = {};
            for c = 1:numel(outputs)
                tmp = mdm_txt_read(outputs{c}.csv_fn);
                if (c == 1)
                    txt = tmp(1);
                end
                txt = cat(1, txt, tmp(2));
            end

            msf_mkdir(msf_fileparts(txt_fn));
            mdm_txt_write(txt, txt_fn);

        end

    end
end