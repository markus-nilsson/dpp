classdef dp_node_dcm2nii < dp_node

    properties(Constant)
        dcm2niix_path = '/Applications/dcm2niix';
    end

    methods

        function obj = dp_node_dcm2nii()

            if (~exist(obj.dcm2niix_path, 'file'))
                error('dcm2niix not found at expected location (%s)', ...
                    obj.dcm2niix_path);
            end

        end

        % expecing this to be overloaded
        function input = po2i(obj, po)
            input.bp = po.bp;
            input.op = fullfile(input.bp, 'nii');
            input.dcm_zip_fn = po.dcm_zip_fn;

        end

        function output = i2o(obj, input)

            output.bp = input.op;

            [~,x] = msf_fileparts(input.dcm_zip_fn);

            f = @(y) fullfile(output.bp, sprintf(['%s.' y], x));
            output.nii_fn  = f('nii.gz');
            output.json_fn = f('json');
            output.bval_fn = f('bval');
            output.bvec_fn = f('bvec');

            % unzip and convert in temporary folder
            output.tmp = obj.make_tmp();

        end

        function [status, f] = output_exist(obj, output)

            % just check the nifti file
            status = exist(output.nii_fn, 'file') == 2;
            f = 'nii_fn';

        end

        function output = execute(obj, input, output)

            % working path
            wp = output.tmp.bp; 

            % unzip
            cmd = sprintf('unzip -j %s -d %s', input.dcm_zip_fn, wp);
            system(cmd);

            % dicom to nifti
            cmd = sprintf('%s -z i -o %s %s', obj.dcm2niix_path, wp, wp);
            system(cmd);

            % copy output
            f = {'nii_fn', 'json_fn' , 'bval_fn', 'bvec_fn'};
            for c = 1:numel(f)

                % search for the output
                [~,~,t_ext] = msf_fileparts(output.(f{c}));

                d2 = dir(fullfile(wp, sprintf('*%s', t_ext)));

                if (numel(d2) ~= 1)
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
            end
        end


    end

end