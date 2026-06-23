classdef dp_node_ants_transform < dp_node
    
    methods

        function obj = dp_node_ants_transform()
            obj.input_test  = {'nii_fn', 'affine_fn', 'warp_fn', 'target_fn'};
            obj.output_test = {'nii_fn'};
            obj.conda_env = 'mrtrix-env'; % dual use of that environment
            
        end

        function output = i2o(obj, input)
            output.nii_fn = dp.new_fn(input.op, input.nii_fn, '_antswarp');
        end

        function output = execute(obj, input, output)

            msf_delete(output.nii_fn);
            msf_mkdir(fileparts(output.nii_fn));

            cmd = sprintf([ ...
                'antsApplyTransforms ' ...
                '-d 3 ' ...
                '-i %s ' ...
                '-r %s ' ...
                '-o %s ' ...
                '-n Linear ' ...
                '-t %s ' ...
                '-t %s'], ...
                input.nii_fn, ...
                input.target_fn, ...
                output.nii_fn, ...
                input.warp_fn, ...
                input.affine_fn);

            [a,b] = obj.syscmd(cmd);

            1;

        end

    end

end