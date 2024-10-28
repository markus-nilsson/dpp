classdef dp_node_dmri_disco < dp_node_workflow

    methods

        function obj = dp_node_dmri_disco()

            error('need better topup config options');

            if (0)

                nodes = {...
                    dp_node_append({...
                        {'original_op', 'op'}, ...
                        {'op', @(x) x.tmp.bp}}, 0), ...
                    dp_node_dmri_disco_synb0(), ...
                    dp_node_dmri_topup_b0(), ...
                    dp_node_append({...
                        {'op', 'original_op'}}, 1), ...
                    dp_node_dmri_topup_apply()};

            else % keep output, debug like workflow

                nodes = {...
                    dp_node_dmri_disco_synb0(), ...
                    dp_node_dmri_topup_b0(), ...
                    dp_node_dmri_topup_apply()};

            end

            obj = obj@dp_node_workflow(nodes);

        end

        function input = po2i(obj, po)

            input = po;

            % This will become a part of the output of the second
            % node above, so it will be properly cleaned
            input.tmp.bp = msf_tmp_path();
            input.tmp.do_delete = 1;

        end

    end
end