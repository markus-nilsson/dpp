classdef dp_node_mrtrix < dp_node

    % helper functions for mrtrix

    methods

        function obj = dp_node_mrtrix()
            obj.conda_env = 'mrtrix-env';

            % xps pass through
            obj.input_spec.add('xps_fn', 'file', 0, 0, 'bval-file');
            obj.output_spec.add('xps_fn', 'file', 0, 0, 'bval-file');

        end

        function output = i2o(obj, input)

            if (isfield(input, 'xps_fn'))
                output.xps_fn = input.xps_fn;
            end

        end

    end


    methods (Static)

        function grad_fn = write_grad_file(grad_fn, xps)

            txt = cell(1, xps.n);
            for c = 1:xps.n
                txt{c} = sprintf('%1.6f %1.6f %1.6f %1.1f', ...
                    xps.u(c,1), xps.u(c,2), xps.u(c,3), xps.b(c) * 1e-6);
            end

            mdm_txt_write(txt, grad_fn);
            
        end

    end
end