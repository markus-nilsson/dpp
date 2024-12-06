classdef dp_node_segm_synthseg < dp_node

    % brain extraction HD BET

    properties

        n_threads = 3;
        synthseg_ex = '~/Software/SynthSeg/scripts/commands/SynthSeg_predict.py';

    end
    
    methods

        function obj = dp_node_segm_synthseg()
            obj.output_test = {'labels_fn'};
        end
    
        function output = i2o(obj, input)
            output.labels_fn = dp.new_fn(input.op, input.nii_fn, '_labels');
            output.labels1mm_fn = dp.new_fn(input.op, input.nii_fn, '_labels1mm');
            output.qc_fn = dp.new_fn(input.op, input.nii_fn, '_qc', '.csv');
            output.vol_fn = dp.new_fn(input.op, input.nii_fn, '_vol', '.csv');
        end

        function output = execute(obj, input, output)

            % Build the flirt command 
            synthseg_cmd = cat(2, ...
                sprintf('conda run -n synthseg_38 '), ...
                sprintf('--cwd %s ', pwd), ...
                sprintf('python %s ', obj.synthseg_ex), ...
                sprintf('--i %s ', input.nii_fn), ...
                sprintf('--o %s ', output.labels1mm_fn), ...
                sprintf('--threads %i ', obj.n_threads), ...
                sprintf('--qc %s ', output.qc_fn), ...
                sprintf('--vol %s ', output.vol_fn), ...
                '--cpu ', ...
                '--parc ', ...
                '');

            msf_mkdir(fileparts(output.labels_fn));
            [status, result] = msf_system(synthseg_cmd); % Execute the command

            if (status > 0)
                error(result);
            end
           
        end
    end
end