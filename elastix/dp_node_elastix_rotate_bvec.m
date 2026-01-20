classdef dp_node_elastix_rotate_bvec < dp_node

    properties
        do_tmp = 0
    end


    methods

        function obj = dp_node_elastix_rotate_bvec(do_tmp)

            if (nargin > 0), obj.do_tmp = do_tmp; end
             
            obj.input_spec.add('dmri_fn', 'file', 1, 1, 'Target dMRI file');
            obj.input_spec.add('xps_fn', 'file', 1, 1, 'File to transform (xps)');
            obj.input_spec.add('elastix_t_fn', 'file', 1, 1, 'Transform parameter file (txt)');

            obj.output_spec.add('xps_fn', 'file', 1, 1, 'Experimental parameter structure');
            
        end

        function output = i2o(obj, input, output)

            xps_fn = mdm_xps_fn_from_nii_fn(input.dmri_fn);
            output.xps_fn = dp.new_fn(input.op, xps_fn);
            
        end

        function output = execute(obj, input, output)

            xps = mdm_xps_load(input.xps_fn);

            % First check that affine dti transform was used
            p = elastix_p_read(input.elastix_p_fn);

            if (~strcmp(p.Transform, '"AffineDTITransform"'))
                error('Expected AffineDTITransform to be used');
            end

            % Get the transform parameters
            t = elastix_p_read(input.elastix_t_fn);

            tpm = t.TransformParameters;

            % Compute rotation matrix
            tmp = reshape(tpm, 3, 4)';
            tmp(2,:) = 0; % translation
            tmp(3,:) = 1; % scales
            tmp(4,:) = 0; % shears

            % Deal with nifti header rotations
            A_mov = cat(1, reshape(t.A_mov, 4, 3)', [0 0 0 1]); A_mov(1:3,4) = 0;
            A_ref = cat(1, reshape(t.A_ref, 4, 3)', [0 0 0 1]); A_ref(1:3,4) = 0;
            A_rot = cat(1, reshape(t.MatrixTranslation, 3, 4), [0 0 0 1]); A_rot(1:3,4) = 0;

            % Remove scalings and shears
            A_mov = A_mov * (A_mov' * A_mov)^(-1/2);
            A_ref = A_ref * (A_ref' * A_ref)^(-1/2);
            A_rot = A_rot * (A_rot' * A_rot)^(-1/2);

            % Incorporate the rotations of the two volumes by their
            % header info
            R = A_mov * A_ref' * A_rot;

            R = R(1:3,1:3);

            if (obj.do_tmp) % experimental options

                if (0) % if using unrotated data

                    R = A_rot(1:3,1:3);

                elseif (0) % this is what works best

                    % incorporate the rotations of the two volumes by their
                    % header info
                    R = A_mov * A_ref'  * A_rot;

                    R = R(1:3,1:3);

                else % should give same as first option above

                    % flip rotation around x (not sure why,
                    % check headers, experimental code)

                    tmp(1,1) = -tmp(1,1);
                    tmp(1,2) = -tmp(1,2);
                    % tmp(1,3) = -tmp(1,3); % verifably worse (cc asym)

                    tmp_tmat = elastix_param2tmat(tmp);
                    tmp_M = tmp_tmat(1:3,1:3); % removes translations

                    % tmp * tmp' = eye, unless there are problem
                    R = ((tmp_M * tmp_M')^(-1/2)) * tmp_M;

                end

            end
            
            % save 
            output.execute.angles = tmp(1,:);
            
            % Prepare for matrix rotation
            for c = 1:xps.n

                % Apply
                if (isfield(xps, 'u'))
                    xps.u(c,:) = (R * xps.u(c,:)')';
                end

                if (isfield(xps, 'bt'))
                    xps.bt(c,:) = tm_3x3_to_1x6( R * tm_1x6_to_3x3(xps.bt(c,:)) * R' );
                end

            end

            msf_mkdir(fileparts(output.xps_fn));
            mdm_xps_save(xps, output.xps_fn);


        end

        function outputs = process_outputs(obj, outputs)
            1;

            a = [];
            for c = 1:numel(outputs)
                try
                    o = outputs{c};
                    disp(sprintf('%s: %1.1f\t%1.1f\t%1.1f', ...
                        o.id, ...
                        o.execute.angles(1)*180/pi, ...
                        o.execute.angles(2)*180/pi, ...
                        o.execute.angles(3)*180/pi));
                catch
                end
            end
            disp(a)
        end

    end
end