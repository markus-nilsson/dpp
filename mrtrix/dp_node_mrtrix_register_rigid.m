classdef dp_node_mrtrix_register_rigid < dp_node_mrtrix & dp_node_dmri

    properties
        template_fn;

        registration_type = 'rigid';
        
        % for later implementations
        % affine_init_translation = 'geometric';
        % rigid_init_translation = 'mass';
        % rigid_init_rotation = 'none';
        % rigid_init_matrix = '../src/my_nodes/rigid_init_matrix.txt'
    end

    methods

        function obj = dp_node_mrtrix_register_rigid(template_fn)
            obj.template_fn = template_fn;

            obj.input_test = {'nii_fn', 'mask_fn'};
            obj.output_test = {'nii_fn', 'affine_fn'};

        end

        function output = i2o(obj, input)
            output.nii_fn = dp.new_fn(input.op, input.nii_fn, '_mrtreg');
            output.rigid_fn = dp.new_fn(input.op, input.nii_fn, '_mrtreg', '.txt');
            output.template_fn = obj.template_fn;
            output.input_fn = input.nii_fn;
        end

        function output = execute(obj, input, output)

            cmd = cat(2, 'mrregister ', ...
                sprintf('%s ', input.nii_fn), ...
                sprintf('%s ', obj.template_fn), ...
                sprintf('-type %s ', obj.registration_type), ...
                sprintf('-rigid %s ', output.rigid_fn), ...
                sprintf('-transformed %s ', output.nii_fn));

            % execute it
            msf_delete(output.nii_fn);
            msf_delete(output.rigid_fn);
            msf_mkdir(fileparts(output.nii_fn));

            obj.syscmd(cmd);

        end
    end
end
