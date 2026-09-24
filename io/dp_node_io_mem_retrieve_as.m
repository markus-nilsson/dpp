classdef dp_node_io_mem_retrieve_as < dp_node_io_mem_retrieve
    % Retrieve field from memory, put into selected output field 

   
    properties
        field_out_name;
    end
    
    methods

        function obj = dp_node_io_mem_retrieve_as(field_to_retrieve, field_out_name)
            obj = obj@dp_node_io_mem_retrieve(field_to_retrieve);
            obj.field_out_name = field_out_name;
        end        

        function output = i2o_transfer_mem(obj, input, output)

            output = i2o_transfer_mem@dp_node_io_mem_retrieve(obj, input, output);

            f_mem = obj.fields_to_retrieve{1};
            f_out = obj.field_out_name;

            % Assign to desired output name
            output.(f_out) = output.(f_mem);

            % The parent function replaced output.(f_mem) with something
            % from memory. Restore value from input if it exists,
            % otherwise, delete it. 
            if (isfield(input, f_mem))
                output.(f_mem) = f_mem;
            else
                output = rmfield(output, f_mem);
            end
               

        end
     
    end

end