classdef dp_node_mrtrix < dp_node

    % helper functions for mrtrix

    methods

        function obj = dp_node_mrtrix()
            1;
        end

    end


    methods (Static)

        % implement a system call, allowing custom variables to be set
        function [s,r] = system(cmd)
            [s,r] = msf_system(cmd); 

            if (s > 0)
                error(r);
            end
            
        end

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