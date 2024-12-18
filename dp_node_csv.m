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

            % put down the basic info
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

    methods (Static)

        function plot_csv(csv_fn)

            txt = mdm_txt_read(csv_fn);

            header = strsplit(txt{1}, ', ');
            header = header(2:end); % remove ID column

            data = []; id = {};
            for c = 2:numel(txt)
                tmp = txt{c};
                tmp = strsplit(tmp, ', ');
                
                % deal with ID separately fro the rest
                tmp_id = tmp{1};
                tmp = tmp(2:end);

                % convert to numbers
                tmp = cellfun(@(x) str2num(x), tmp, 'UniformOutput',false);
                tmp = cell2mat(tmp);

                % verify we have all numbers
                if (numel(tmp) ~= numel(header))
                    error('bad data');
                end

                % store
                data = cat(1, data, tmp);
                id   = cat(1, id, tmp_id);

            end

            msf_clf;

            n_extreme = zeros(size(id)); % count number of times min/max
            for c = 2:numel(header)

                if (all(isnan(data(:,c))))
                    continue; 
                end

                subplot(1,2,1); cla; 
                x = 1:size(data, 1);
                plot(x, data(:,c), 'ko', 'markerfacecolor', 'red');
                title(strrep(header{c}, '_', ' '));

                % compute median pm mad
                u_median = median(data(:,c));
                u_mad    = mad(data(:,c), 1);

                th = 3;
                hold on;
                z = zeros(size(x));
                plot(x, z + u_median, 'k--');
                plot(x, z + u_median + th * u_mad * 3/2, 'r--');
                plot(x, z + u_median - th * u_mad * 3/2, 'r--');
                
                ind_extreme = abs(data(:,c) - u_median) > th * u_mad;
                n_extreme(ind_extreme) = n_extreme(ind_extreme) + 1;


                [~,min_ind] = nanmin(data(:,c));
                [~,max_ind] = nanmax(data(:,c));

                g = @(id) strrep(id, '_', ' ');
                f = @(id) g(strrep(id, '\', '/'));

                ind_nan = isnan(data(:,c));

                subplot(2,2,2); cla; 
                tmp = cat(2, ...
                    sprintf('Min: %1.3f (%s)\n', data(min_ind,c), f(id{min_ind})), ...
                    sprintf('Max: %1.3f (%s)\n', data(max_ind,c), f(id{max_ind})), ...
                    sprintf('#Nan: %i', sum(ind_nan)), ...
                    []);

                text(0, 0, 0, tmp);
                box off; 
                axis off;
                ylim([-1 1]);


                subplot(2,2,4);
                plot(x, n_extreme, 'ko');
             

                pause(0.05);
            end

            [~,ind] = sort(n_extreme, 'descend');

            for c = 1:numel(ind)
                disp(sprintf('%s: %i', id{ind(c)}, n_extreme(ind(c))));
            end
        end

    end
end