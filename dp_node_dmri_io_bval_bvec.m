classdef dp_node_dmri_io_bval_bvec < dp_node_io_append

    % Builds an input structure suitable for dmri operations
    % with outputs as follows
    %
    % dmri_fn
    % bval_fn
    % bvec_fn
    
    methods

        function obj = dp_node_dmri_io_bval_bvec(input_field_name)
            
            obj = obj@dp_node_io_append({...
                {'dmri_fn', input_field_name}, ...
                {'bval_fn', @(x) dp_node_dmri_io_bval_bvec.bval_fn(x.(input_field_name))}, ...
                {'bvec_fn', @(x) dp_node_dmri_io_bval_bvec.bvec_fn(x.(input_field_name))}});
        
        end      
    end

    methods (Static)

        function fn = bval_fn(dmri_fn)
            fn = mdm_fn_nii2bvalbvec(dmri_fn);
        end

        function fn = bvec_fn(dmri_fn)
            [~,fn] = mdm_fn_nii2bvalbvec(dmri_fn);
        end
        
    end

end