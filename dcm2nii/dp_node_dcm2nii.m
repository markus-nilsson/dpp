classdef dp_node_dcm2nii < dp_node

    properties 
        dcm2niix_path;
    end

    methods

        function obj = dp_node_dcm2nii()

            obj.output_test = {'nii_fn', 'json_fn'};

            % Path to dcm2niix
            if (ismac)
                obj.dcm2niix_path = '/Applications/dcm2niix';
            elseif (isunix)
                obj.dcm2niix_path = '/usr/bin/dcm2niix';
            else
                error('not implemented yet');
            end

            if (~exist(obj.dcm2niix_path, 'file'))
                error('dcm2niix not found at expected location (%s)', ...
                    obj.dcm2niix_path);
            end


        end

        % % expecing this to be overloaded
        % function input = po2i(obj, po)            
        %     input.dcm_folder = po.dcm_folder;
        %     input.dcm_name = po.dcm_name;
        % end

        function output = i2o(obj, input)

            x = input.dcm_name; 

            f = @(y) fullfile(input.op, sprintf(['%s.' y], x));
            output.nii_fn  = f('nii.gz');
            output.json_fn = f('json');
            output.bval_fn = f('bval');
            output.bvec_fn = f('bvec');

            % convert in temporary folder
            output.tmp.bp = msf_tmp_path(0);
            output.tmp.do_delete = 1;

        end        

        function output = execute(obj, input, output)

            % working path
            wp = output.tmp.bp; 
            msf_mkdir(wp);

            % dicom to nifti
            cmd = sprintf('%s -z i -f Serie_%%s_%%p -o ''%s'' ''%s'' ', obj.dcm2niix_path, ...
                wp, input.dcm_folder);
            [s,m] = system(cmd);

            if (s ~= 0)
                disp(m);
                return; % graceful exit, should help with cleaning
            end

            % copy output
            f = {'nii_fn', 'json_fn' , 'bval_fn', 'bvec_fn'};
            for c = 1:numel(f)

                % skip if file not requested
                if (isempty(output.(f{c})))
                    continue;
                end

                % search for the output
                [~,~,t_ext] = msf_fileparts(output.(f{c}));

                d2 = dir(fullfile(wp, sprintf('*%s', t_ext)));

                if (numel(d2) < 1)
                    switch (f{c})
                        case 'nii_fn'
                            error('nii file missing');
                        case 'json_fn'
                            error('json missing');
                    end

                    continue; 
                end

                % verify the output
                source_fn = fullfile(wp, d2(1).name);

                [~,~, s_ext] = msf_fileparts(source_fn);

                if (~strcmp(s_ext, t_ext))
                    warning('check this');
                    continue;
                end

                target_fn = output.(f{c});
                msf_mkdir(fileparts(target_fn));
                copyfile(source_fn, target_fn);

                % if there are more files, like for gradient echo, copy
                % these too, but these are not declared outputs...
                for c2 = 2:numel(d2)

                    % just pull the source file name now
                    source_fn = fullfile(wp, d2(c2).name);
                    
                    % auto build target
                    [~,name,ext] = msf_fileparts(source_fn);
                    target_fn = fullfile(input.op, cat(2, name, ext));
                    
                    % copy!
                    copyfile(source_fn, target_fn);
                end
                
            end

            % deal with bval bvec fn – assume they should not exist
            % if they do not exist
            if (~exist(output.bvec_fn, 'file'))
                output.bvec_fn = '';
            end

            if (~exist(output.bval_fn, 'file'))
                output.bval_fn = '';
            end

        end
    end
end