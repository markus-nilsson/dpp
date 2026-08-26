classdef dp_node_io_mem_retrieve < dp_node_io_parent

   
    properties
        fields_to_retrieve = {}
        do_select = 0; % 0 - fields are added, 1 - fields selected, other fields discarded
    end
    
    methods

        function obj = dp_node_io_mem_retrieve(varargin)
            obj.fields_to_retrieve = varargin(:);
            obj.input_test = {};
            obj.output_test = {};

            obj.get_dpm('execute').do_run = 0;

        end        

        function output = i2o_transfer_mem(obj, input, output)

            if (~isfield(input, 'mem'))
                error('no memories stored');
            end

            % Remove all fields but those that are necessary
            if (obj.do_select)
                output = struct('id', input.id);

                if (isfield(input, 'bp')), output.bp = input.bp; end
                if (isfield(input, 'ip')), output.ip = input.ip; end
                if (isfield(input, 'op')), output.op = input.op; end
                if (isfield(input, 'mem')), output.mem = input.mem; end
                
            end
            
            fields = obj.fields_to_retrieve;

            for c = 1:numel(fields)
                f = obj.fields_to_retrieve{c};

                output.(f) = input.mem.(f);

            end

        end
     
    end

end