classdef dp_node_identify_sequences < dp_node

    properties
        patterns;
    end

    methods 

        function obj = dp_node_identify_sequences(patterns)
            obj.patterns = patterns;
        end

        function output = i2o(obj, input)

            % make a pass-through to keep all info
            output = input; 

            f = obj.patterns;
            for c = 1:numel(f)
                output.(f{c}{1}) = msf_find_fn(input.nii_path, f{c}{2}, 0);

                if (isempty(output.(f{c}{1})))
                    1;
                end

            end
            
        end

    end

end



