classdef dp_node_identify_sequences < dp_node

    % searches for files according to pattern in input.nii_path
    %
    % pattern is given as { {field_name, this_pattern} } where
    % this_pattern is a regular expression

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

                output.(f{c}{1}) = msf_find_fn(input.nii_path, f{c}{2}, -1);

                if (isempty(output.(f{c}{1})))
                    obj.log(0, 'File not found for field %s pattern %s', f{c}{1}, f{c}{2});
                    
                    % allow some granularity here, sometimes ok not to
                    % find data
                    error('file not found');
                end

            end
            
        end

    end

end



