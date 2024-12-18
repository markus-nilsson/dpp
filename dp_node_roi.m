classdef dp_node_roi < dp_node & dp_node_core_roi

    % implements method by which we compile information from an ROI 

    methods

        function obj = dp_node_roi(name, bp, roi_names)
            obj = obj@dp_node();
            obj.name = name;
            obj.roi_bp = bp;
            obj.roi_names = roi_names;
            obj.roi_ids = ones(size(roi_names)); 
            % field names too

            obj.output_test = {'roi_stats_fn'};
        end

        function output = i2o(obj, input)
            output.roi_stats_fn = fullfile(input.op, 'roi', [obj.name '.mat']);
        end

        function output = execute(obj, input, output)

            % save descriptive statistics to a .mat file

            % init outputs
            info.now = datetime('now');
            info.roi_names = obj.roi_names;            

            % Get which files that can be analyzed
            %   all that ends with _fn
            %   except label_fn
            f = fieldnames(input);

            for c = 1:numel(f)
                ind(c) = ...
                    strcmp(f{c}(max(1, end-2):end), '_fn') & ...
                    ~strcmp(f{c}, 'labels_fn');
            end

            f = f(ind);

            % For each file
            for c = 1:numel(f)

                [I,h_I] = mdm_nii_read(input.(f{c}));

                if (size(I,4) > 1)
                    error('Cannot deal with 4D volumes at present');
                end

                % For each ROI
                for c_roi = 1:numel(obj.roi_names)

                    % now we use input not output here... which is 
                    % a bit nasty...
                    [R, h_R] = obj.roi_get_volume(input, f{c}, c_roi);

                    % check that h_I and h_R are similar

                    % extract values
                    V = I(R(:) > 0);

                    % This allows the ROI size to be different across 
                    % contrasts
                    tmp.n = sum(R(:) > 0);

                    tmp.mean = mean(V);
                    tmp.std = std(V, 1);

                    tmp.median = median(V);
                    tmp.mad    = mad(V, 1);

                    tmp.quantile_1st = quantile(V, 0.01);
                    tmp.quantile_5th = quantile(V, 0.05);
                    tmp.quantile_10th = quantile(V, 0.10);
                    tmp.quantile_25th = quantile(V, 0.25);
                    tmp.quantile_50th = quantile(V, 0.50);
                    tmp.quantile_75th = quantile(V, 0.75);
                    tmp.quantile_90th = quantile(V, 0.90);
                    tmp.quantile_95th = quantile(V, 0.95);
                    tmp.quantile_99th = quantile(V, 0.99);

                    info.roi_stats(c_roi).(f{c}) = tmp;

                end

            end

            msf_mkdir(fileparts(output.roi_stats_fn));
            msf_delete(output.roi_stats_fn);
            save(output.roi_stats_fn, 'info');

        end

        function [R,h_R] = roi_get_volume(obj, output, f, c_roi)
            % note: this function is overloaded 

            roi_fn = obj.roi_get_fn(output, f, c_roi);
            [R,h_R] = mdm_nii_read(roi_fn);

        end

    end

end