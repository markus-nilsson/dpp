classdef nn_datastore_nii_mem_2d < matlab.io.Datastore & ...
                                    matlab.io.datastore.MiniBatchable
    properties
        Slices           % Cell array of 2D slices
        CurrentIdx
        MiniBatchSize
        Orientation      % 'tra', 'sag', or 'cor'
    end

    properties (SetAccess = protected)
        NumObservations
    end

    methods
        function ds = nn_datastore_nii_mem_2d(fileList, orientation)
            arguments
                fileList cell
                orientation (1,:) char {mustBeMember(orientation, {'tra','sag','cor'})} = 'tra'
            end

            ds.CurrentIdx = 1;
            ds.MiniBatchSize = 1;
            ds.Orientation = orientation;

            ds.Slices = {};

            for i = 1:numel(fileList)
                vol = single(niftiread(fileList{i}));

                % if (sum(vol(:)) > 10)
                % 
                % % Normalize
                % vol = vol / quantile(vol(:), 0.99);
                % vol(vol < 0) = 0;
                % vol(isnan(vol)) = 0;
                % vol(isinf(vol)) = 0;
                % 
                % end

                % Extract slices based on orientation
                % 2do: preallocate

                % for now, reshape all into seemingly transverse slices
                g = @(x) reshape(x, size(x,1), size(x,2), 1, size(x,3));
                f = @(x) g(squeeze(x));
                
                switch orientation
                    case 'tra' % axial
                        for z = 1:size(vol, 3)
                            ds.Slices{end+1} = f(vol(:, :, z, :));
                        end
                    case 'cor' % coronal
                        for y = 1:size(vol, 2)
                            ds.Slices{end+1} = f(vol(:, y, :, :));
                        end
                    case 'sag' % sagittal
                        for x = 1:size(vol, 1)
                            ds.Slices{end+1} = f(vol(x, :, :, :));
                        end
                end
            end

            ds.NumObservations = numel(ds.Slices);
        end

        function tf = hasdata(ds)
            tf = ds.CurrentIdx <= ds.NumObservations;
        end

        function [data, info] = read(ds)
            idx = ds.CurrentIdx;
            data = ds.Slices{idx};
            info = struct('Index', idx);
            ds.CurrentIdx = ds.CurrentIdx + 1;
        end

        function reset(ds)
            ds.CurrentIdx = 1;
        end

        function dsNew = partition(ds, ~, indices)
            dsNew = copy(ds);
            dsNew.Slices = ds.Slices(indices);
            dsNew.NumObservations = numel(indices);
            dsNew.reset();
        end

        function tf = isPartitionable(~)
            tf = true;
        end

        function ds = shuffle(ds)
            idx = randperm(ds.NumObservations);
            ds.Slices = ds.Slices(idx);
        end

        function data = readByIndex(ds, index)
            data = ds.Slices{index};
        end

        function tbl = preview(ds)
            tbl = table((1:ds.NumObservations)', 'VariableNames', {'Index'});
        end
    end
end
