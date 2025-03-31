classdef dp_node_core_syscmd < dp_node_core_log & handle

    properties
        conda_env = '';
    end

    methods

        function obj = dp_node_core_syscmd()

            % test if the convda environment exists
            if (~isempty(obj.conda_env))
                1;
            end

        end

        function [status, result, cmd_full] = syscmd(obj, cmd)

            if (ismac)

                [status, result, cmd_full] = obj.mac_cmd(cmd);

            elseif (isunix)

                [status, result, cmd_full] = obj.linux_cmd(cmd);

            else % assume windows

                [status, result, cmd_full] = obj.win_cmd(cmd);

            end

            % xxx: turn off the error if the node wants to deal with 
            %      this itself
            if (status ~= 0)
                error(result); 
            end

            obj.log(2, result);

        end



    end

    methods (Hidden)

        % linux call, use conda if asked for
        function [status, result, cmd] = linux_cmd(obj, cmd)

            if (~isempty(obj.conda_env))

                cmd = cat(2, sprintf('conda run -n %s ', obj.conda_env), ...
                    sprintf('--cwd %s ', pwd), cmd);

            end

            cmd_full = [getenv('SHELL') ' --login -c '' ' cmd ' '' '];

            [status, result] = system(cmd_full);

        end
        
        % windows call
        % may be improvd to use linux subsystem when called for
        function [status, result, cmd] = win_cmd(obj, cmd)
            [status, result] = system(cmd_full);
        end

        % mac call
        function [status, result, cmd] = mac_cmd(obj, cmd)

            cmd_full = [getenv('SHELL') ' --login -c '' ' cmd ' '' '];

            [status, result] = system(cmd_full);
        end


    end


end