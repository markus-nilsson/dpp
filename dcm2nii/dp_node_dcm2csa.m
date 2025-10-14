classdef dp_node_dcm2csa < dp_node

    methods

        function obj = dp_node_dcm2csa()
        end

        function output = i2o(obj, input)

            output = input; 

            output.csa_fn = dp.new_fn(output.op, input.dcm_name, '_csa', '.txt');

        end        

        function output = execute(obj, input, output)

            d = dir(fullfile(input.dcm_folder, '*.dcm'));

            if (numel(d) == 0)
                return;
            end

            fid = fopen(fullfile(input.dcm_folder, d(1).name), 'r');
            txt = fread(fid, d(1).bytes, 'char')';
            fclose(fid);

            ind_start = strfind(txt, 'ASCCONV BEGIN');
            ind_end = strfind(txt, '### ASCCONV END') + 14;

            if (isempty(ind_start))
                return;
            end

            if (isempty(ind_end))
                return;
            end
            
            mdm_txt_write({char(txt(ind_start:ind_end))}, output.csa_fn);

        end
    end
end