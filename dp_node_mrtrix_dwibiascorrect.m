classdef dp_node_mrtrix_dwibiascorrect < dp_node_mrtrix & dp_node_dmri

    methods

        function output = i2o(~, input)
            output.dmri_fn = dp.new_fn(input.op, input.dmri_fn, '_n4');
        end

        function output = execute(obj, input, output)

            % execute it
            msf_delete(output.dmri_fn);
            msf_mkdir(fileparts(output.dmri_fn));
            cmd = sprintf('dwibiascorrect ants %s %s -fslgrad %s %s', ...
                input.dmri_fn, ...
                output.dmri_fn, ...
                input.bvec_fn, ...
                input.bval_fn);

            obj.system(cmd);

            mdm_xps_save(xps, output.xps_fn);


        end
    end
end
