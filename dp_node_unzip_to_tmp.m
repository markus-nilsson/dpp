classdef dp_node_unzip_to_tmp < dp_node_unzip

    methods

        function output = i2o(obj, input)

            % Put the unzipped files in a temporary folder
            tmp.bp = msf_tmp_path();
            tmp.do_delete = 1;

            tmp_input = input;
            tmp_input.op = tmp.bp;    

            output = i2o@dp_node_unzip(obj, tmp_input);

            output.tmp = tmp;
            output.op = input.op;

        end

    end

end