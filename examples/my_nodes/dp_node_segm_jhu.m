classdef dp_node_segm_jhu < dp_node_segm

    methods (Hidden)
        function [labels, ids] = segm_info(obj)

            % /usr/local/fsl/data/atlases/JHU-labels.xml

            txt = { ...
                '0: Unclassified', ...       % Unclassified
                '1: MCP', ...        % Middle cerebellar peduncle
                '2: PCT', ...        % Pontine crossing tract (a part of MCP)
                '3: GCC', ...        % Genu of corpus callosum
                '4: CCB', ...        % Body of corpus callosum
                '5: SCC', ...        % Splenium of corpus callosum
                '6: FX', ...         % Fornix (column and body of fornix)
                '7: CST_R', ...      % Corticospinal tract R
                '8: CST_L', ...      % Corticospinal tract L
                '9: ML_R', ...       % Medial lemniscus R
                '10: ML_L', ...      % Medial lemniscus L
                '11: ICP_R', ...     % Inferior cerebellar peduncle R
                '12: ICP_L', ...     % Inferior cerebellar peduncle L
                '13: SCP_R', ...     % Superior cerebellar peduncle R
                '14: SCP_L', ...     % Superior cerebellar peduncle L
                '15: CP_R', ...      % Cerebral peduncle R
                '16: CP_L', ...      % Cerebral peduncle L
                '17: ALIC_R', ...    % Anterior limb of internal capsule R
                '18: ALIC_L', ...    % Anterior limb of internal capsule L
                '19: PLIC_R', ...    % Posterior limb of internal capsule R
                '20: PLIC_L', ...    % Posterior limb of internal capsule L
                '21: RLIC_R', ...    % Retrolenticular part of internal capsule R
                '22: RLIC_L', ...    % Retrolenticular part of internal capsule L
                '23: ACR_R', ...     % Anterior corona radiata R
                '24: ACR_L', ...     % Anterior corona radiata L
                '25: SCR_R', ...     % Superior corona radiata R
                '26: SCR_L', ...     % Superior corona radiata L
                '27: PCR_R', ...     % Posterior corona radiata R
                '28: PCR_L', ...     % Posterior corona radiata L
                '29: PTR_R', ...     % Posterior thalamic radiation (include optic radiation) R
                '30: PTR_L', ...     % Posterior thalamic radiation (include optic radiation) L
                '31: SS_R', ...      % Sagittal stratum (incl ILF and IFOF) R
                '32: SS_L', ...      % Sagittal stratum (incl ILF and IFOF) L
                '33: EC_R', ...      % External capsule R
                '34: EC_L', ...      % External capsule L
                '35: CGC_R', ...     % Cingulum (cingulate gyrus) R
                '36: CGC_L', ...     % Cingulum (cingulate gyrus) L
                '37: CGH_R', ...     % Cingulum (hippocampus) R
                '38: CGH_L', ...     % Cingulum (hippocampus) L
                '39: FST_R', ...     % Fornix (crus) / Stria terminalis R
                '40: FST_L', ...     % Fornix (crus) / Stria terminalis L
                '41: SLF_R', ...     % Superior longitudinal fasciculus R
                '42: SLF_L', ...     % Superior longitudinal fasciculus L
                '43: SFOF_R', ...    % Superior fronto-occipital fasciculus R
                '44: SFOF_L', ...    % Superior fronto-occipital fasciculus L
                '45: UF_R', ...      % Uncinate fasciculus R
                '46: UF_L', ...      % Uncinate fasciculus L
                '47: TAP_R', ...     % Tapetum R
                '48: TAP_L' ...      % Tapetum L
                };




            a = @(x) strsplit(x, ' ');
            b = @(x,i) x{i};
            c = @(x) str2num(x(1:(end-1)));

            labels = cellfun(@(x) b(a(x),2), txt, 'UniformOutput', false);
            ids = cellfun(@(x) c(b(a(x),1)), txt, 'UniformOutput', false);
        end
    end
end
