classdef dp_node_mrtrix_dwigradcheck < dp_node_mrtrix

    methods

        function obj = dp_node_mrtrix_dwigradcheck()


        end

        function input = po2i(obj, po)
            
            % transfer all
            input = po;

            % make sure we have an explicit xps
            if (~isfield(po, 'xps_fn'))
                input.xps_fn = mdm_xps_fn_from_nii_fn(po.dmri_fn);
            end


        end        

        function output = i2o(obj, input)

            % this node will copy the dwi volume without doing anything
            % about it, because we want to maintain the tight coupling
            % with the xps and the dwi - thus, it is recommended that this
            % node is only used in a temporary folder, ideally coupled
            % with other preprocessing steps

            
            % this is wasteful in terms of storage
            output.dmri_fn = dp.new_fn(input.op, input.dmri_fn, '_gc');
            output.xps_fn = mdm_xps_fn_from_nii_fn(output.dmri_fn);

            output.tmp.bp = msf_tmp_path();
            output.tmp.do_delete = 1;

        end

        function output = execute(obj, input, output)

            % write out bval/bvec files
            grad_fn = fullfile(output.tmp.bp, 'gradfile.txt');

            xps = mdm_xps_load(input.xps_fn);

            if (isfield(xps, 'b_delta')) && ...
                    (any((xps.b_delta <= 0.99) & (xps.b > 0)))
                error('not defined for b-tensor encoding')
            end

            txt = cell(1, xps.n);
            for c = 1:xps.n
                txt{c} = sprintf('%1.6f %1.6f %1.6f %1.1f', ...
                    xps.u(c,1), xps.u(c,2), xps.u(c,3), xps.b(c) * 1e-6);
            end

            mdm_txt_write(txt, grad_fn);


            % run gradcheck
            grad_fn2 = fullfile(output.tmp.bp, 'gradfile2.txt');
            
            cmd = sprintf('dwigradcheck %s -grad %s -export_grad_mrtrix %s', ...
                input.dmri_fn, grad_fn, grad_fn2);
            obj.system(cmd);

            % prepare output
            msf_mkdir(fileparts(output.xps_fn));

            % edit the file (to allow it to be read by mdm scripts)
            txt = mdm_txt_read(grad_fn2);
            mdm_txt_write(txt(2:end), grad_fn2);

            % load the xps
            xps = mdm_xps_from_gdir(grad_fn2);
            mdm_xps_save(xps, output.xps_fn);
    
            % load and save the image data 
            fid = fopen(input.dmri_fn, 'r');
            data = fread(fid, inf, 'uint8');
            fclose(fid);

            fid = fopen(output.dmri_fn, 'w');
            fwrite(fid, data, 'uint8');
            fclose(fid);
           
        end
    end
end
