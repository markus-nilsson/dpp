classdef dp_node_mrtrix_dwigradcheck < dp_node_mrtrix & dp_node_dmri

    methods

        function obj = dp_node_mrtrix_dwigradcheck()


        end

        function output = i2o(obj, input)

            % this node will copy the dwi volume without doing anything
            % about it, because we want to maintain the tight coupling
            % with the xps and the dwi - thus, it is recommended that this
            % node is only used in a temporary folder, ideally coupled
            % with other preprocessing steps
            
            % this is wasteful in terms of storage
            output.dmri_fn = dp.new_fn(input.op, input.dmri_fn, '_gc');
            output.bval_fn = dp.new_fn(input.op, input.dmri_fn, '_gc', '.bval');
            output.bvec_fn = dp.new_fn(input.op, input.dmri_fn, '_gc', '.bvec');
            output.xps_fn = mdm_xps_fn_from_nii_fn(output.dmri_fn);

            output.tmp.bp = msf_tmp_path();
            output.tmp.do_delete = 1;

        end

        function output = execute(obj, input, output)

            % test the xps
            xps = mdm_xps_load(input.xps_fn);

            if (isfield(xps, 'b_delta')) && ...
                    (any((xps.b_delta <= 0.99) & (xps.b > 0)))
                error('not defined for b-tensor encoding')
            end

            % prepare output
            msf_mkdir(fileparts(output.bvec_fn));

            msf_delete(output.bval_fn);
            msf_delete(output.bvec_fn);
            
            cmd = sprintf('dwigradcheck "%s" -fslgrad "%s" "%s" -export_grad_fsl "%s" "%s"', ...
                input.dmri_fn, ...
                input.bvec_fn, input.bval_fn, ....
                output.bvec_fn, output.bval_fn);
            obj.syscmd(cmd);

            % write an xps too
            xps = mdm_xps_from_bval_bvec(output.bval_fn, output.bvec_fn);
            mdm_xps_save(xps, output.xps_fn);
    
            % copy the image data: load and save to create new dates
            fid = fopen(input.dmri_fn, 'r');
            data = fread(fid, inf, 'uint8');
            fclose(fid);

            fid = fopen(output.dmri_fn, 'w');
            fwrite(fid, data, 'uint8');
            fclose(fid);
           
        end
    end
end
