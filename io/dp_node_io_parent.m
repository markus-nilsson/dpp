classdef dp_node_io_parent < dp_node

    methods

        function obj = dp_node_io_parent()
            obj.input_spec.remove('op');

            % to not test input/output
            obj.get_dpm('execute').do_run = 0;
            
        end

    end


end