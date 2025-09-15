classdef dp_node_unzip < dp_node

    % unzippes a file input.zip_fn to the input.op + [name _unzipped]
    % folder

    methods

        function output = i2o(obj, input)

            [~, name] = msf_fileparts(input.zip_fn);
            output.unzipped_folder = fullfile(input.op, [name '_unzipped']);

            output.zip_name = name;

        end

        function output = execute(obj, input, output)

            msf_mkdir(output.unzipped_folder);

            cmd = sprintf('unzip -o -j "%s" -d "%s"', input.zip_fn, ...
                output.unzipped_folder);

            system(cmd);

        end

    end

end