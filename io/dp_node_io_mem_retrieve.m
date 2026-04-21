classdef dp_node_io_mem_retrieve < dp_node_io_parent

   
    properties
        fields_to_retrieve = {}
    end
    
    methods

        function obj = dp_node_io_mem_retrieve(varargin)
            obj.fields_to_retrieve = varargin(:);
        end        

        function output = i2o_transfer_mem(obj, input, output)

            if (~isfield(input, 'mem'))
                error('no memories stored');
            end

            for c = 1:numel(obj.fields_to_retrieve)
                f = obj.fields_to_retrieve{c};

                output.(f) = input.mem.(f);

            end

        end
     
    end

end