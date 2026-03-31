classdef dp_node_dmri_xps_make_v2 < dp_node_dmri_xps

    % Creates experimental parameter sets (XPS) based on sequence name and
    % additional information from dicoms


    % inputs
    % dmri_fn - nifti file
    % csa_fn - siemens csa header
    % json_fn - from dcm2niix

    methods

        function obj = dp_node_dmri_xps_make_v2()
            obj.input_test = {'dmri_fn', 'csa_fn', 'json_fn'};
        end


        function output = execute(obj, input, output)

            % Try to find a json
            json = do_json(input.json_fn);
            csa = mdm_txt_read(input.csa_fn);

            f = @(y) csa(cell2mat(cellfun(@(x) ~isempty(strfind(x, y)), csa, 'UniformOutput', false)));
            g = @(x) strrep(strtrim(extractAfter(x{1}, '=')), '""', '');

            seq_name = g(f('tSequenceFileName'));

            switch (seq_name)
                case '%CustomerSeq%\cmrr_mbep2d_diff'
                    xps = mdm_xps_from_bval_bvec(input.bval_fn, input.bvec_fn, 1);
                case '%SiemensSeq%\ep2d_diff'
                    xps = mdm_xps_from_bval_bvec(input.bval_fn, input.bvec_fn, 1);
                case '%CustomerSeq%\ep2d_diff_mwf'

                    % Risky move, using another node's execute without
                    % verification - think about another solution                    
                    output = dp_node_dmri_xps_from_mwf.static_execute([], input, output);
                    return;
                otherwise
                    disp(seq_name);
            end

            mdm_xps_save(xps, output.xps_fn);

        end
    end
end