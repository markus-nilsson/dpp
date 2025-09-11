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

        %  not implemented yet
        function [status, f, age] = input_exist(obj, input)
            status = [];
            f = [];
            age = [];
        end

        function [status, f, age] = output_exist(obj, input)
            status = [];
            f = [];
            age = [];
        end

    end

end