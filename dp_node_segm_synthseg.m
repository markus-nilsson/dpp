classdef dp_node_segm_synthseg < dp_node_segm


    % brain segmentation using SynthSeg++ (or 2.0)
    %    https://github.com/BBillot/SynthSeg
    %
    % input
    % 
    % nii_fn
    %
    % output
    %
    % label_fn (in orig space, not working now)
    % labels1mm_fn
    % qc_vn
    % vol_fn

    properties

        n_threads = 3;
        synthseg_path = '/usr/local/SynthSeg';

    end

    methods

        function obj = dp_node_segm_synthseg(n_threads)
            obj.input_test = {'nii_fn'};
            obj.output_test = {'labels_fn'};

            if (nargin > 0), obj.n_threads = n_threads; end

        end

        function output = i2o(obj, input)
            output.resampled_fn    = dp.new_fn(input.op, input.nii_fn, '_rs');
            output.labels_fn = dp.new_fn(input.op, input.nii_fn, '_labels1mm');
            output.qc_fn        = dp.new_fn(input.op, input.nii_fn, '_qc', '.csv');
            output.vol_fn       = dp.new_fn(input.op, input.nii_fn, '_vol', '.csv');
        end

        function output = execute(obj, input, output)

            synthseg_ex = fullfile(obj.synthseg_path, 'scripts/commands/SynthSeg_predict.py');

            % Build the flirt command
            synthseg_cmd = cat(2, ...
                sprintf('conda run -n synthseg_38 '), ...
                sprintf('--cwd %s ', pwd), ...
                sprintf('python %s ', synthseg_ex), ...
                sprintf('--i %s ', input.nii_fn), ...
                sprintf('--o %s ', output.labels_fn), ...
                sprintf('--threads %i ', obj.n_threads), ...
                sprintf('--qc %s ', output.qc_fn), ...
                sprintf('--vol %s ', output.vol_fn), ...
                sprintf('--resample %s ', output.resampled_fn), ...
                '--parc ', ...
                '--cpu', ...
                '');

            msf_mkdir(fileparts(output.labels_fn));
            [status, result] = msf_system(synthseg_cmd); % Execute the command

            if (status > 0)
                error(result);
            end

        end

    end

    methods (Hidden)


        function [labels, ids] = segm_info(obj)

            txt = {...
                '0  Unknown                            	   0    0    0     0', ...
                '2  Left-Cerebral-White-Matter         	 245  245  245     0', ...
                '3  Left-(Cerebral-Cortex               	 205   62   78     0', ...
                '4  Left-Lateral-Ventricle             	 120   18  134     0', ...
                '5  Left-Inf-Lat-Vent                      196   58  250     0', ...
                '7  Left-Cerebellum-White-Matter           220  248  164     0', ...
                '8  Left-Cerebellum-Cortex                 230  148   34     0', ...
                '10  Left-Thalamus-Proper                     0  118   14     0', ...
                '11  Left-Caudate                           122  186  220    0', ...
                '12  Left-Putamen                           236   13  176    0', ...
                '13  Left-Pallidum                           12   48  255    0', ...
                '14  3rd-Ventricle                          204  182  142    0', ...
                '15  4th-Ventricle                           42  204  164    0', ...
                '16  Brain-Stem                             119  159  176    0', ...
                '17  Left-Hippocampus                       220  216   20     0', ...
                '18  Left-Amygdala                          103  255  255    0', ...
                '24  CSF                                     60   60   60     0', ...
                '26  Left-Accumbens-area                    255  165    0    0', ...
                '28  Left-VentralDC                         165   42   42    0', ...
                '41  Right-Cerebral-White-Matter              0  225    0     0', ...
                '42  Right-Cerebral-Cortex                  205   62   78      0', ...
                '43  Right-Lateral-Ventricle                120   18  134     0', ...
                '44  Right-Inf-Lat-Vent                     196   58  250     0', ...
                '46  Right-Cerebellum-White-Matter          220  248  164     0', ...
                '47  Right-Cerebellum-Cortex                230  148   34      0', ...
                '49  Right-Thalamus-Proper                    0  118   14      0', ...
                '50  Right-Caudate                          122  186  220     0', ...
                '51  Right-Putamen                          236   13  176     0', ...
                '52  Right-Pallidum                          13   48  255    0', ...
                '53  Right-Hippocampus                      220  216   20      0', ...
                '54  Right-Amygdala                         103  255  255     0', ...
                '58  Right-Accumbens-area                   255  165    0     0', ...
                '60  Right-VentralDC                        165   42   42     0', ...
                '1000 ctx-lh-unknown 25 5 25 0', ...
                '1001 ctx-lh-bankssts 25 100 40 0', ...
                '1002 ctx-lh-caudalanteriorcingulate 125 100 160 0', ...
                '1003 ctx-lh-caudalmiddlefrontal 100 25 0 0', ...
                '1004 ctx-lh-corpuscallosum 120 70 50 0', ...
                '1005 ctx-lh-cuneus 220 20 100 0', ...
                '1006 ctx-lh-entorhinal 220 20 10 0', ...
                '1007 ctx-lh-fusiform 180 220 140 0', ...
                '1008 ctx-lh-inferiorparietal 220 60 220 0', ...
                '1009 ctx-lh-inferiortemporal 180 40 120 0', ...
                '1010 ctx-lh-isthmuscingulate 140 20 140 0', ...
                '1011 ctx-lh-lateraloccipital 20 30 140 0', ...
                '1012 ctx-lh-lateralorbitofrontal 35 75 50 0', ...
                '1013 ctx-lh-lingual 225 140 140 0', ...
                '1014 ctx-lh-medialorbitofrontal 200 35 75 0', ...
                '1015 ctx-lh-middletemporal 160 100 50 0', ...
                '1016 ctx-lh-parahippocampal 20 220 60 0', ...
                '1017 ctx-lh-paracentral 60 220 60 0', ...
                '1018 ctx-lh-parsopercularis 220 180 140 0', ...
                '1019 ctx-lh-parsorbitalis 20 100 50 0', ...
                '1020 ctx-lh-parstriangularis 220 60 20 0', ...
                '1021 ctx-lh-pericalcarine 120 100 60 0', ...
                '1022 ctx-lh-postcentral 220 20 20 0', ...
                '1023 ctx-lh-posteriorcingulate 220 180 220 0', ...
                '1024 ctx-lh-precentral 60 20 220 0', ...
                '1025 ctx-lh-precuneus 160 140 180 0', ...
                '1026 ctx-lh-rostralanteriorcingulate 80 20 140 0', ...
                '1027 ctx-lh-rostralmiddlefrontal 75 50 125 0', ...
                '1028 ctx-lh-superiorfrontal 20 220 160 0', ...
                '1029 ctx-lh-superiorparietal 20 180 140 0', ...
                '1030 ctx-lh-superiortemporal 140 220 220 0', ...
                '1031 ctx-lh-supramarginal 80 160 20 0', ...
                '1032 ctx-lh-frontalpole 100 0 100 0', ...
                '1033 ctx-lh-temporalpole 70 70 70 0', ...
                '1034 ctx-lh-transversetemporal 150 150 200 0', ...
                '1035 ctx-lh-insula 255 192 32  0', ...
                '2000 ctx-rh-unknown 25 5 25 0', ...
                '2001 ctx-rh-bankssts 25 100 40 0', ...
                '2002 ctx-rh-caudalanteriorcingulate 125 100 160 0', ...
                '2003 ctx-rh-caudalmiddlefrontal 100 25 0 0', ...
                '2004 ctx-rh-corpuscallosum 120 70 50 0', ...
                '2005 ctx-rh-cuneus 220 20 100 0', ...
                '2006 ctx-rh-entorhinal 220 20 10 0', ...
                '2007 ctx-rh-fusiform 180 220 140 0', ...
                '2008 ctx-rh-inferiorparietal 220 60 220 0', ...
                '2009 ctx-rh-inferiortemporal 180 40 120 0', ...
                '2010 ctx-rh-isthmuscingulate 140 20 140 0', ...
                '2011 ctx-rh-lateraloccipital 20 30 140 0', ...
                '2012 ctx-rh-lateralorbitofrontal 35 75 50 0', ...
                '2013 ctx-rh-lingual 225 140 140 0', ...
                '2014 ctx-rh-medialorbitofrontal 200 35 75 0', ...
                '2015 ctx-rh-middletemporal 160 100 50 0', ...
                '2016 ctx-rh-parahippocampal 20 220 60 0', ...
                '2017 ctx-rh-paracentral 60 220 60 0', ...
                '2018 ctx-rh-parsopercularis 220 180 140 0', ...
                '2019 ctx-rh-parsorbitalis 20 100 50 0', ...
                '2020 ctx-rh-parstriangularis 220 60 20 0', ...
                '2021 ctx-rh-pericalcarine 120 100 60 0', ...
                '2022 ctx-rh-postcentral 220 20 20 0', ...
                '2023 ctx-rh-posteriorcingulate 220 180 220 0', ...
                '2024 ctx-rh-precentral 60 20 220 0', ...
                '2025 ctx-rh-precuneus 160 140 180 0', ...
                '2026 ctx-rh-rostralanteriorcingulate 80 20 140 0', ...
                '2027 ctx-rh-rostralmiddlefrontal 75 50 125 0', ...
                '2028 ctx-rh-superiorfrontal 20 220 160 0', ...
                '2029 ctx-rh-superiorparietal 20 180 140 0', ...
                '2030 ctx-rh-superiortemporal 140 220 220 0', ...
                '2031 ctx-rh-supramarginal 80 160 20 0', ...
                '2032 ctx-rh-frontalpole 100 0 100 0', ...
                '2033 ctx-rh-temporalpole 70 70 70 0', ...
                '2034 ctx-rh-transversetemporal 150 150 200 0', ...
                '2035 ctx-rh-insula 255 192 32  0'};

            
            a = @(x) strsplit(x, ' ');
            b = @(x,i) x{i};
            c = @(x) str2num(x);

            labels = cellfun(@(x) b(a(x),2), txt, 'UniformOutput', false);
            ids = cellfun(@(x) c(b(a(x),1)), txt, 'UniformOutput', false);


        end




    end

end