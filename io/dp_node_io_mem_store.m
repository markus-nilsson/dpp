classdef dp_node_io_mem_store < dp_node_io_parent

   
    properties
        fields_to_store = {}
    end
    
    methods

        function obj = dp_node_io_mem_store(varargin)
            obj.fields_to_store = varargin(:);
        end        

        function output = i2o_transfer_mem(obj, input, output)

            for c = 1:numel(obj.fields_to_store)
                f = obj.fields_to_store{c};

                if (isfield(output, 'mem')) && (isfield(output.mem, f))
                    error('memory already holds that field (%s)', f);
                end

                output.mem.(f) = input.(f);

            end


        end

    end

end