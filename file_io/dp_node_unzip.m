classdef dp_node_unzip < dp_node

    % unzippes a file input.zip_fn to the input.op + [name _unzipped]
    % folder

    properties
        unzip_opts = '-o -j'; 
        % -o overwrites existing files without asking.
        % -j “junks” the paths, meaning it ignores folder structure 
        %    and dumps all files into the current directory.
    end

    methods

        function output = i2o(obj, input)

            [~, name] = msf_fileparts(input.zip_fn);
            output.unzipped_folder = fullfile(input.op, [name '_unzipped']);

            output.zip_name = name;

        end

        function [status, f, age] = output_exist(obj, output)

            d = dir(output.unzipped_folder);

            status = exist(output.unzipped_folder, 'dir') == 7;
            f = {'unzipped_folder'};

            if (numel(d) == 3)
                age = d(3).datenum;
            else
                age = NaN;
            end

            % [status, f, age] = obj.output_spec.exist(output);
        end

        function output = execute(obj, input, output)

            msf_mkdir(output.unzipped_folder);

            cmd = sprintf('unzip %s "%s" -d "%s" > /dev/null', ...
                obj.unzip_opts, ...
                input.zip_fn, ...
                output.unzipped_folder);

            system(cmd);

        end

    end

end