classdef dp_node_mrtrix_dwibiascorrect < dp_node_mrtrix & dp_node_dmri

    methods

        function output = i2o(obj, input)

            output.dmri_fn = dp.new_fn(input.op, input.dmri_fn, '_n4');
            output.xps_fn = mdm_xps_fn_from_nii_fn(output.dmri_fn);

            output.tmp.bp = msf_tmp_path();
            output.tmp.do_delete = 1;

        end

        function output = execute(obj, input, output)

            % i believe we can do this for a tensor-valued file too
            % but haven't checked extensively
            xps = mdm_xps_load(input.xps_fn);

            grad_fn = obj.write_grad_file(fullfile(output.tmp.bp, 'grad.txt'), xps);

            % execute it
            msf_delete(output.dmri_fn);
            msf_mkdir(fileparts(output.dmri_fn));
            cmd = sprintf('dwibiascorrect ants %s %s -grad %s', ...
                input.dmri_fn, ...
                output.dmri_fn, ...
                grad_fn);

            obj.system(cmd);


            mdm_xps_save(xps, output.xps_fn);


        end
    end
end
