classdef p0_list_subjects < dp_node_primary

    properties
        bp;
    end
    
    methods

        function obj = p0_list_subjects(bp)

            if (nargin < 1) || (isempty(bp))
                bp = '/media/fuji/MyBook1/BOF130_APTw/data/nii/NII';

            end

            obj.bp = bp;

        end

        function outputs = get_iterable(obj, opt)

            d = dir(fullfile(obj.bp, 'BoF130_APTw_*'));

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



