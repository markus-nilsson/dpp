classdef dp_node_dmri_io_xps_to_bval_bvec < dp_node_dmri

    
    methods

        function output = i2o(obj, input)

            output.dmri_fn = input.dmri_fn;
            output.xps_fn = input.xps_fn;

            output.bval_fn = dp.new_fn(input.op, input.dmri_fn, '', '.bval');
            output.bvec_fn = dp.new_fn(input.op, input.dmri_fn, '', '.bvec');

        end

        function output = execute(obj, input, output)

            xps = mdm_xps_load(input.xps_fn);

            % we may need additional rounding here
            b = round(xps.b * 1e-6);

            mdm_txt_write({num2str(b')}, output.bval_fn);

            f = @(x) round(x * 1e5) / 1e5;
            mdm_txt_write({num2str(f(xps.u(:,1)')), ...
                num2str(f(xps.u(:,2)')), num2str(f(xps.u(:,3)'))}, output.bvec_fn);

        end

    end

end

