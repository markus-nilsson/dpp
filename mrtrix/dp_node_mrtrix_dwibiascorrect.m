classdef dp_node_mrtrix_dwibiascorrect < dp_node_mrtrix & dp_node_dmri

    methods

        function obj = dp_node_mrtrix_dwibiascorrect()

            obj.input_spec.add('dmri_fn', 'file', 1, 1, 'dMRI data');
            obj.input_spec.add('bvec_fn', 'file', 1, 1, 'bvec-file');
            obj.input_spec.add('bval_fn', 'file', 1, 1, 'bval-file');

            obj.output_spec.add('dmri_fn', 'file', 1, 1, 'dMRI data');

        end

        function output = i2o(obj, input)
            output = i2o@dp_node_mrtrix(obj, input);

            output.dmri_fn = dp.new_fn(input.op, input.dmri_fn, '_n4');
            output.bias_fn = dp.new_fn(input.op, input.dmri_fn, '_n4bias');

        end

        function output = execute(obj, input, output)

            % execute it
            msf_delete(output.dmri_fn);
            msf_mkdir(fileparts(output.dmri_fn));
            cmd = sprintf('dwibiascorrect ants %s %s -fslgrad %s %s -bias %s -force', ...
                input.dmri_fn, ...
                output.dmri_fn, ...
                input.bvec_fn, ...
                input.bval_fn, ...
                output.bias_fn);

            [a,b] = obj.syscmd(cmd);

        end
    end
end
