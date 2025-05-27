classdef dp_node_dmri_io_xps_to_bval_bvec < dp_node_dmri

    
    methods

        function output = i2o(obj, input)

            output = input;

            output.xps_fn  = input.xps_fn;
            output.bval_fn = dp.new_fn(input.op, input.dmri_fn, '', '.bval');
            output.bvec_fn = dp.new_fn(input.op, input.dmri_fn, '', '.bvec');

        end

        function output = execute(obj, input, output)

            xps = mdm_xps_load(input.xps_fn);

            % we may need additional rounding here
            b = round(xps.b * 1e-6);

            msf_mkdir(fileparts(output.bval_fn));
            mdm_txt_write({num2str(b')}, output.bval_fn);

            % fudge a bvec for STE
            if (~isfield(xps, 'u')) && (all(abs(xps.b_delta) < 0.02))
                xps.u = repmat([1 0 0], xps.n, 1);
            end

            f = @(x) round(x * 1e5) / 1e5;
            mdm_txt_write({num2str(f(xps.u(:,1)')), ...
                num2str(f(xps.u(:,2)')), num2str(f(xps.u(:,3)'))}, output.bvec_fn);

        end

    end

end

