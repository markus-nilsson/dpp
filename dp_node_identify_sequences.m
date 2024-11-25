classdef dp_node_identify_sequences < dp_node

    % searches for files according to pattern in input.nii_path
    %
    % pattern is given as { {field_name, this_pattern} } where
    % this_pattern is an expression going into 'dir'

    % xxx: improvements needed, errors here leads to a drop of the 
    %      subject in the reporting, check this

    properties
        patterns;

        multiple_hit_strategy = 'error'; % alt: first, last
    end

    methods 

        function obj = dp_node_identify_sequences(patterns)

            if (~iscell(patterns)) || (~iscell(patterns{1}))
                error('expected input: {{field_name, pattern}_i}'); 
            end

            obj.patterns = patterns;
        end

        function output = i2o(obj, input)

            % make a pass-through to keep all info
            output = input;

            if (~exist(input.nii_path, 'dir'))
                error('nii path does not exist');
            end

            f = obj.patterns;
            for c = 1:numel(f)

                me = [];
                try 
                    tmp = msf_find_fns(input.nii_path, f{c}{2}, 1);

                    if (numel(tmp) == 0)
                        error('No file found');
                    elseif (numel(tmp) == 1) %#ok<ISCL>
                        tmp = tmp{1};
                    else

                        switch (obj.multiple_hit_strategy)

                            case 'error'
                                error('Multiple files found');

                            case 'first'
                                tmp = tmp{1};
                            case 'last'
                                tmp = tmp{end};
                            otherwise
                                error('Undefined multiple hit strategy');

                        end

                    end

                catch me 
                    tmp = [];
                end

                output.(f{c}{1}) = tmp;

                if (isempty(output.(f{c}{1})))
                    obj.log(1, '%s: File not found for field %s pattern %s', ...
                        input.id, ...
                        f{c}{1}, formattedDisplayText(f{c}{2}));

                    obj.log(1, '%s:   Was searching in: %s', input.id, input.nii_path);

                    if (~isempty(me))
                        obj.log(1, '%s:   Search error: %s', input.id, me.message);   
                        obj.log(1, '%s:   Listing nii files in %s', input.id, input.nii_path);
                        d2 = dir(fullfile(input.nii_path, '*.nii*'));
                        for c2 = 1:numel(d2)
                            obj.log(1, '%s:     %s', input.id, d2(c2).name);
                            
                        end
                    end
                    
                    % allow some granularity here, sometimes ok not to
                    % find data
                    error('file not found');
                end

            end
            
        end

    end

end



