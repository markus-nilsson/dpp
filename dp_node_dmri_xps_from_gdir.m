classdef dp_node_dmri_xps_from_gdir < dp_node_dmri_xps

    methods

        function obj = dp_node_dmri_xps_from_gdir()
            obj.input_test = {'dmri_fn'};
        end

        function po = po2i(~, po)

            if (~isfield(po, 'gdir_fn'))
                po.gdir_fn = mdm_fn_nii2gdir(po.dmri_fn);
            end
        end

        function output = execute(~, input, output)

            xps = mdm_xps_from_gdir(input.gdir_fn);

            mdm_xps_save(xps, output.xps_fn);

        end
    end
end