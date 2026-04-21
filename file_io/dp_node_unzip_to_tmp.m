classdef dp_node_unzip_to_tmp < dp_node_unzip

    methods

        function output = i2o(obj, input)

            % Put the unzipped files in a temporary folder
            tmp = obj.make_tmp(); 

            tmp_input = input;
            tmp_input.op = tmp.bp;
            tmp_input.bp = tmp.bp;

            output = i2o@dp_node_unzip(obj, tmp_input);

            output.tmp = tmp;
            output.op = input.op;
            output.bp = input.bp;

        end

        function output = run_clean(obj, output)
            output = run_clean@dp_node_unzip(obj, output);
        end

    end

end