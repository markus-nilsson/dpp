classdef dp_node_primary < dp_node_base

    methods (Abstract)
        get_iterable(obj) % need to be declared to work differently from core
    end

    methods

        function obj = dp_node_primary()
            obj.dpm_list = {...
                dpm_iter(obj), ...
                dpm_report(obj)};

            obj.input_spec.remove('op');

        end

    end

end