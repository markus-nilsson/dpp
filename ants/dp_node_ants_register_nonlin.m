classdef dp_node_ants_register_nonlin < dp_node

    properties
        template_fn
        use_quick = 1;
    end

    methods

        function obj = dp_node_ants_register_nonlin(template_fn)

            obj.template_fn = template_fn;

            obj.input_test = {'nii_fn'};
            obj.output_test = {'nii_fn', ...
                               'affine_fn', ...
                               'warp_fn'};

            obj.conda_env = 'mrtrix-env'; % dual use of that environment
        end

        function output = i2o(obj,input)

            output.nii_fn    = dp.new_fn(input.op,input.nii_fn,'_Warped');
            output.affine_fn = dp.new_fn(input.op,input.nii_fn,'_0GenericAffine', '.mat');
            output.warp_fn   = dp.new_fn(input.op,input.nii_fn,'_1Warp');
            output.target_fn = obj.template_fn;

        end

        function output = execute(obj,input,output)

            msf_delete(output.nii_fn);
            msf_delete(output.affine_fn);
            msf_delete(output.warp_fn);

            msf_mkdir(fileparts(output.nii_fn));


            prefix = erase(output.affine_fn,'0GenericAffine.mat');            

            if obj.use_quick

                cmd = sprintf([ ...
                    'antsRegistrationSyNQuick.sh ' ...
                    '-d 3 ' ...
                    '-f %s ' ...
                    '-m %s ' ...
                    '-o %s'], ...
                    obj.template_fn, ...
                    input.nii_fn, ...
                    prefix);

            else

                cmd = sprintf([ ...
                    'antsRegistrationSyN.sh ' ...
                    '-d 3 ' ...
                    '-f "%s" ' ...
                    '-m "%s" ' ...
                    '-o %s'], ...
                    obj.template_fn, ...
                    input.nii_fn, ...
                    prefix);

            end

            [a,b] = obj.syscmd(cmd);

            1;

        end

    end

end