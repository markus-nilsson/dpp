classdef dp_node_unzip < dp_node

    methods

        function output = i2o(obj, input)

            output.bp = input.bp;

            [~, name] = msf_fileparts(input.zip_fn);
            output.unzipped_folder = fullfile(output.bp, [name '_unzipped']);

            output.zip_name = name;

        end

        function output = execute(obj, input, output)

            cmd = sprintf('unzip -o -j %s -d %s', input.zip_fn, ...
                output.unzipped_folder);

            system(cmd);

        end

    end

end