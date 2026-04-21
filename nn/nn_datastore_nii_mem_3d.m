classdef nn_datastore_nii_mem_3d < matlab.io.Datastore & ...
                           matlab.io.datastore.MiniBatchable
    properties
        Volumes
        CurrentIdx
        MiniBatchSize
    end

    properties (SetAccess = protected)
        NumObservations
    end

    methods
        function ds = nn_datastore_nii_mem_3d(fileList)
            ds.CurrentIdx = 1;
            ds.MiniBatchSize = 1;
            ds.Volumes = cell(1, numel(fileList));

            for i = 1:numel(fileList)
                vol = single(niftiread(fileList{i}));

                if ndims(vol) == 3
                    vol = reshape(vol, size(vol,1), size(vol,2), size(vol,3), 1);
                end

                % normalize
                vol = vol / quantile(vol(:), 0.99);
                vol(vol < 0) = 0;
                vol(isnan(vol)) = 0;
                vol(isinf(vol)) = 0;

                ds.Volumes{i} = vol;
            end

            ds.NumObservations = numel(ds.Volumes);
        end

        function tf = hasdata(ds)
            tf = ds.CurrentIdx <= ds.NumObservations;
        end

        function [data, info] = read(ds)
            idx = ds.CurrentIdx;
            data = ds.Volumes{idx};
            info = struct('Index', idx);
            ds.CurrentIdx = ds.CurrentIdx + 1;
        end

        function reset(ds)
            ds.CurrentIdx = 1;
        end

        function dsNew = partition(ds, ~, indices)
            dsNew = copy(ds);
            dsNew.Volumes = ds.Volumes(indices);
            dsNew.NumObservations = numel(indices);
        end

        function tf = isPartitionable(~)
            tf = true;
        end

        function ds = shuffle(ds)
            idx = randperm(ds.NumObservations);
            ds.Volumes = ds.Volumes(idx);
        end

        function data = readByIndex(ds, index)
            data = ds.Volumes{index};
        end

        function tbl = preview(ds)
            tbl = table((1:ds.NumObservations)', 'VariableNames', {'Index'});
        end
    end
end
