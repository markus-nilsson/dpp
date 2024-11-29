classdef dp_node_dmri_io_bval_bvec < dp_node_io_append

    % Quick way to append fields (will write over existing field)
    
    methods

        function obj = dp_node_dmri_io_bval_bvec(input_field_name)

            obj = obj@dp_node_io_append({...
                {input_field_name, 'dmri_fn'}, ...
                'bval_fn', });
        end        

    end

    methods (Static)
    end

end