classdef dp_node_fsl_eddy_prepare < dp_node

    % this assumes we are working on a single data set without topup
    % and without ap/pa data

    methods

        function input = po2i(obj, po)

            input = po;

            % assume we're working on raw data where we can find
            % bval bvec files 
            if (~isfield(po, 'bval_fn'))
                [input.bval_fn, input.bvec_fn] = ...
                    mdm_fn_nii2bvalbvec(po.dmri_fn);
            end

            if (~isfield(po, 'xps_fn'))
                input.xps_fn = mdm_xps_fn_from_nii_fn(po.dmri_fn);
            end
            
            
        end

        function output = i2o(obj, input)
        
            output.dmri_fn = input.dmri_fn;
            output.mask_fn = input.mask_fn;

            output.xps_fn = input.xps_fn;

            output.acqp_fn = dp.new_fn(input.op, input.dmri_fn, '_acqp', '.txt');
            output.index_fn = dp.new_fn(input.op, input.dmri_fn, '_index', '.txt');
            
            output.bval_fn = dp.new_fn(input.op, input.dmri_fn, '_adjusted', '.txt');
            output.bvec_fn = input.bvec_fn;
            
        end

        function output = execute(obj, input, output)

            % replace with better info e.g. from json later
            mdm_txt_write({'0 -1 0 0.0646', '0 1 0 0.0646'}, output.acqp_fn);

            h = mdm_nii_read_header(input.dmri_fn);
            mdm_txt_write(num2cell(zeros(1, h.dim(5)) + '1'), output.index_fn);

            % group b-values
            txt = mdm_txt_read(input.bval_fn);

            if (numel(txt) == 1)
                txt = txt{1};
            else 
                error('not implemented');
            end

            tmp = str2num(txt);

            % for tensor-valued encoding, force different b-values for the
            % shells, to make eddy run
            xps = mdm_xps_load(input.xps_fn);

            b_delta = xps.b_delta;
            b_delta = round(b_delta * 10) / 10;
            
            ind = xps.b < 10e6; % assign b=0 to most max b_delta
            b_delta(ind) = max(b_delta(~ind)); 

            b_delta_unique = unique(b_delta);
            
            if (numel(b_delta_unique) > 1) % we have b-tensor encoding

                % add max-b plus 500 to each new b_delta, but let 
                % lte be as it is
                db = 500;
                for c = 1:numel(b_delta_unique)
            
                    if (b_delta_unique(c) == 1), continue; end

                    ind = b_delta == b_delta_unique(c);

                    tmp(ind) = tmp(ind) + max(tmp) + db;

                end
                
            end

            % Store the output
            mdm_txt_write({num2str(tmp)}, output.bval_fn);

            1;
                       
        end

    end

end


