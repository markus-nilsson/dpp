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
        end

    end
end