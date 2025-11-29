classdef my_primary_node < dp_node_primary

    properties
        bp;
        pattern = '*';
    end

    methods

        function obj = my_primary_node(bp, pattern)
            obj.bp = bp;
            obj.pattern = pattern;
        end

        function outputs = get_iterable(obj)

            d = dir(fullfile(obj.bp, obj.pattern));

            outputs = {};

            % find folders
            for c = 1:numel(d)

                if (d(c).name(1) == '.')
                    continue;
                end

                d2 = dir(fullfile(obj.bp, d(c).name, '2*'));

                if (numel(d2) > 1)
                    1;
                end

                for c2 = 1:numel(d2)

                    output.bp = obj.bp;
                    output.id = fullfile(d(c).name, d2(c2).name);

                    outputs{end+1} = output; 
                end
            end
        end
    end
end