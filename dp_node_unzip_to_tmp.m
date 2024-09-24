classdef dp_node_unzip_to_tmp < dp_node_unzip

    methods

        function output = i2o(obj, input)

            tmp.bp = msf_tmp_path();
            tmp.do_delete = 1;

            tmp_input = input;
            tmp_input.bp = tmp.bp;            
            output = i2o@dp_node_unzip(obj, tmp_input);

            output.tmp = tmp;
            output.bp = input.bp;

        end

    end

end