classdef dp_node_list_subjects_in_folder < dp_node_list_subjects

    properties
        pattern = '*';
    end

    methods

        function obj = dp_node_list_subjects_in_folder(bp, pattern)
            obj.bp = bp;
            obj.pattern = pattern;
        end

        function outputs = get_outputs(obj)

            d = dir(fullfile(obj.bp, obj.pattern));

            outputs = {};

            % find folders
            for c = 1:numel(d)

                if (d(c).name(1) == '.')
                    continue;
                end

                output.bp = obj.bp;
                output.id = fullfile(d(c).name);

                outputs{end+1} = output; %#ok<AGROW>

            end
        end
    end
end