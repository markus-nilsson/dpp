classdef dp_node_mrtrix_degibbs < dp_node_mrtrix & dp_node_dmri

    methods

        function obj = dp_node_mrtrix_degibbs()

        end

        function output = i2o(obj, input)

            % mrdegibbs operates directly on the DWI volume, so the
            % associated xps remain unchanged.

            output.dmri_fn = dp.new_fn(input.op, input.dmri_fn, '_degibbs');
            output.xps_fn = mdm_xps_fn_from_nii_fn(output.dmri_fn);

        end

        function output = execute(obj, input, output)

            cmd = sprintf('mrdegibbs "%s" "%s"', ...
                input.dmri_fn, ...
                output.dmri_fn);

            [a,b] = obj.syscmd(cmd);

            copyfile(input.xps_fn, output.xps_fn);

        end

    end
end