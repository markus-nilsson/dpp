classdef dp_node_core_dpm < handle

    % implements use of data processing modes for nodes

    properties
        mode;
        dpm_list;

        % not sure this is on the right level
        input_fields = {}; % part of testing to make life easier

        input_test = [];  % field that will be tested by input_exists
        output_test = []; % field that will be tested by output_exists
        
    end

    methods (Abstract)
        input_exist(obj, input);
        output_exist(obj, output);
    end    

    properties (Hidden)
        do_dpm_passthrough = 0;
    end

    methods

        function obj = dp_node_core_dpm()

            obj.dpm_list = {...
                dpm_iter(obj), ...
                dpm_execute(obj), ...
                dpm_debug(obj)};

        end

        function modes = get_supported_modes(obj)
            modes = cellfun(@(x) x.get_mode_name(), obj.dpm_list, 'UniformOutput', false);
        end

        % dpm - data processing mode (e.g. report, iter, debug, execute...)
        function dpm = get_dpm(obj, mode)

            if (nargin < 2), mode = obj.mode; end
            
            ind = cellfun(@(x) strcmp(mode, x.get_mode_name()), obj.dpm_list);

            ind = find(ind);

            if (numel(ind) > 0)
            
                dpm = obj.dpm_list{ind};
            
            else % dpm not supported, but allow passthrough for workflows
                
                if (obj.do_dpm_passthrough)
                    dpm = dpm_passthrough(obj);
                else
                    error('mode (%s) not supported', obj.mode);
                end

            end

        end

        function ages = input_age(~, ~)
            ages = [];
        end

        function ages = output_age(~, ~)
            ages = [];
        end        

    end

end


    