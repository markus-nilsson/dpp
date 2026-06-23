classdef dp_node_io_mem_store < dp_node_io_parent

   
    properties
        fields_to_store = {}
        do_warn = 1;
    end
    
    methods

        function obj = dp_node_io_mem_store(varargin)
            obj.fields_to_store = varargin(:);

            if (numel(varargin) == 1) && (iscell(varargin{1})) 
                obj.fields_to_store = varargin{1};
            end

            obj.input_test = {};
            obj.output_test = {};
        end        

        function output = i2o_transfer_mem(obj, input, output)

            for c = 1:numel(obj.fields_to_store)
                f = obj.fields_to_store{c};

                if (obj.do_warn) && (isfield(output, 'mem')) && (isfield(output.mem, f))
                    obj.log(2, 'memory already holds that field (%s), overwriting it', f);
                end

                output.mem.(f) = input.(f);

            end

        end

    end

end