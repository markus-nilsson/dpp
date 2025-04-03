classdef dp_node_dmri_topup_apply < dp_node

    % apply topup to volume
    %
    % assume we do not have full ap/pa data, but only in ap

    properties

        output_name = [];
        output_suffix = '_topup';
    end

    methods

        function obj = dp_node_dmri_topup_apply(name, suffix)

            if (nargin > 0)

                [~,~,ext] = msf_fileparts(name);

                switch (ext)
                    case {'.nii', '.nii.gz'}
                        1; % ok
                    otherwise
                        error('need name to end with .nii.gz');
                end
            
                obj.output_name = name; 

            end

            if (nargin > 1), obj.output_suffix = suffix; end

        end
        
        % construct names of output files
        function output = i2o(obj, input)

            output.op = input.op;

            % xxx: better naming warranted
            if (isempty(obj.output_name))
                output_name = input.nii_ap_fn; %#ok<PROPLC>
            else
                output_name = obj.output_name; %#ok<PROPLC>
            end

            output.dmri_fn = dp.new_fn(output.op, ...
                output_name, obj.output_suffix); %#ok<PROPLC>
            
            output.xps_fn = mdm_xps_fn_from_nii_fn(output.dmri_fn);

            % add a temporary path
            output.tmp.bp = msf_tmp_path();
            output.tmp.do_delete = 1;
        end

        function output = execute(obj, input, output)

            % Connect to data
            if (~isempty(input.nii_ap_fn))
                s_ap = mdm_s_from_nii(input.nii_ap_fn);
                if (s_ap.xps.n == 0), error('xps.n == 0'); end
            else
                s_ap.nii_fn = fullfile(output.tmp.bp, 'DMRI_AP_zeros.nii.gz');                
                s_ap.xps.n = 0;                
            end
            
            if (~isempty(input.nii_pa_fn))
                s_pa = mdm_s_from_nii(input.nii_pa_fn);
                if (s_pa.xps.n == 0), error('xps.n == 0'); end                
            else
                s_pa.nii_fn = fullfile(output.tmp.bp, 'DMRI_PA_zeros.nii.gz');
                s_pa.xps.n = 0;
            end

            
            % Check and fix
            if (s_ap.xps.n > 0) && (s_pa.xps.n == 0)
                [I,h] = mdm_nii_read(s_ap.nii_fn);
                mdm_nii_write(zeros(size(I)), s_pa.nii_fn, h);
                s_pa.xps = s_ap.xps;                
            end
            
            if (s_pa.xps.n > 0) && (s_ap.xps.n == 0)
                [I,h] = mdm_nii_read(s_pa.nii_fn);
                mdm_nii_write(zeros(size(I)), s_ap.nii_fn, h);
                s_ap.xps = s_pa.xps;
            end


            % Now we should be all set, but check just in case
            if (s_ap.xps.n ~= s_pa.xps.n)
                error('fix this in your pipeline, set non-desired one to empty')
            end


            % Define command
            msf_mkdir(fileparts(output.dmri_fn));

            cmd = sprintf(['applytopup ' ...
                '--imain="%s","%s" ' ...
                '--inindex=1,2 ' ...
                '--topup="%s" ' ...
                '--datain="%s" ' ...
                '--out="%s"'], ...
                s_ap.nii_fn, ...                % imain_1 
                s_pa.nii_fn, ...                % imain_2
                input.topup_data_path, ...      % topup
                input.topup_spec_fn, ...        % spec
                output.dmri_fn);                % output_fn
            
            obj.syscmd(cmd);

            % Save the xps too
            mdm_xps_save(s_ap.xps, output.xps_fn);

        end
    end
end

