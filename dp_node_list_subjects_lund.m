classdef dp_node_list_subjects_lund < dp_node_primary

    % This class provides outputs that list subjects, which 
    % are structured on the Lund pipeline format:
    %
    % Subject_ID/Exam_date_1/

    properties
        bp;
        project_prefix
    end
    
    methods

        function obj = dp_node_list_subjects_lund(bp, project_prefix)
            obj.bp = bp;
            obj.project_prefix = project_prefix;
        end

        function outputs = get_iterable(obj)

            tmp = fullfile(obj.bp, sprintf('%s_*', obj.project_prefix));

            d = dir(tmp);

            outputs = {};

            % find folders
            for c = 1:numel(d)

                d2 = dir(fullfile(obj.bp, d(c).name, '20*'));

                for c2 = 1:numel(d2)

                    output.bp = obj.bp;
                    output.id = fullfile(d(c).name, d2(c2).name);

                    outputs{end+1} = output;
                end
            end

        end
    end
end



