classdef dpm_csv < dpm

    methods

        function dp_opt()
                                opt.verbose = 0; 
        end


        function process_outputs(outputs, opt)


            % create file with time stamp
            % txt_fn = msf_append_fn(output.csv.csv_fn,
            % 'current_date_and_time');

            % collect and save outputs
            txt = cat(2, ...
                outputs{1}.csv.header_str, ...
                cellfun(@(x) x.csv.data_str, outputs, 'uniformoutput', false));
            mdm_txt_write(txt, txt_fn);



        end

    end

end