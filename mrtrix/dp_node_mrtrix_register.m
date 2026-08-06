classdef dp_node_mrtrix_register < dp_node_mrtrix & dp_node_dmri


    % this is a preliminary implemntation, later this will be holding
    % the execute method, and specific sub-classes the different types

    properties
        template_fn;

        registration_type = 'rigid_nonlinear';

        % for later 
        % affine_init_translation = 'geometric';
        % rigid_init_translation = 'mass';
        % rigid_init_rotation = 'none';
        % rigid_init_matrix = '../src/my_nodes/rigid_init_matrix.txt'
    end

    methods

        function obj = dp_node_mrtrix_register(template_fn)
            obj.template_fn = template_fn;

            obj.input_test = {'nii_fn'};
            obj.output_test = {'nii_fn', 'affine_fn', 'rigid_fn', 'nonlinearwarp_fn'};

        end

        function output = i2o(obj, input)
            output.nii_fn = dp.new_fn(input.op, input.nii_fn, '_mrtreg');
            output.rigid_fn = dp.new_fn(input.op, input.nii_fn, '_mrtrigid', '.txt');
            output.affine_fn = dp.new_fn(input.op, input.nii_fn, '_mrtaffine', '.txt');
            output.nonlinearwarp_fn = dp.new_fn(input.op, input.nii_fn, '_mrtnonlin', '.mif');
            output.template_fn = obj.template_fn;
        end

        function output = execute(obj, input, output)

            cmd = cat(2, 'mrregister ', ...
                sprintf('%s ', input.nii_fn), ...
                sprintf('%s ', obj.template_fn), ...
                sprintf('-type %s ', obj.registration_type), ...
                sprintf('-rigid %s ', output.rigid_fn), ...
                sprintf('-transformed %s ', output.nii_fn), ...
                sprintf('-nl_warp_full %s ', output.nonlinearwarp_fn));

                % sprintf('-affine %s ', output.affine_fn), ...


            % execute it
            msf_delete(output.nii_fn);
            msf_delete(output.rigid_fn);
            msf_delete(output.affine_fn);
            msf_delete(output.nonlinearwarp_fn);
            msf_mkdir(fileparts(output.nii_fn));

            obj.syscmd(cmd);

        end
    end
end
