classdef dp_node_primary_list_lund < dp_node_primary

    % This class provides outputs that list subjects, which 
    % are structured on the Lund pipeline format:
    %
    % output{c}.id = 'Subject_ID/Exam_date_1/'

    properties
        bp;
        project_prefix
    end
    
    methods

        function obj = dp_node_primary_list_lund(bp, project_prefix)
            obj.bp = bp;
            obj.project_prefix = project_prefix;

            if (project_prefix(end) == '_')
                warning('Prefix should not end with underscore');
            end
        end

        function outputs = get_iterable(obj)

            tmp = fullfile(obj.bp, sprintf('%s_*', obj.project_prefix));
            
            obj.log(0, '%tSearching for subjects: %s', tmp);
            d = dir(tmp);

            if (numel(d) == 0)
                obj.log(0, '%t  Found nothing');
            end

            outputs = {};

            % find folders
            for c = 1:numel(d)
                
                if (d(c).name(1) == '_')
                    continue; % exclude folders starting with _
                end

                d2 = dir(fullfile(obj.bp, d(c).name, '20*'));

                for c2 = 1:numel(d2)

                    output.bp = obj.bp;
                    output.id = fullfile(d(c).name, d2(c2).name);

                    outputs{end+1} = output; %#ok<AGROW>

                end
            end
        end
    end
end



