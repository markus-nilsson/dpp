classdef p11_compile < dp_node

    methods

        function obj = p11_compile()
            obj.previous_node = {px_identify_sequences, p9_mdt, p10_md, p7_powder_averaging, r2_seg2roi};
        end

        function input = po2i(obj, prev_output)
            input = prev_output;
            input.bp = prev_output.mdt_bp;
        end

        function output = i2o(obj, input)

            output.bp = fullfile(input.mdt_bp);
            output.op = fullfile(output.bp, '..', 'reports');

            img_fn = [strrep(input.id, '/', '_') '.png'];
            output.img_fn = fullfile(output.op, img_fn);

            output.t1c_fn = input.identify_sequences_t1c_fn;

            output.roi.names = {'ce', 'edema', 'tum'};
            output.roi.roi_fns = {...
                input.seg2roi_ce_fn, ...
                input.seg2roi_edema_fn, ...
                input.seg2roi_tum_fn};

        end

        function roi_fn = eg_roi_fn(obj, ref, c_roi)
            roi_fn = ref.output.roi.roi_fns{c_roi};
        end


        function output = execute(obj, input, output)


            % make nice figure
            MDT = mdm_nii_read(input.mdt_nii_fn);
            MD = mdm_nii_read(input.md_md_fn);
            T1 = mdm_nii_read(input.identify_sequences_t1c_fn);
            FLA = mdm_nii_read(input.identify_sequences_flair_fn);
            DWI_PA = mdm_nii_read(input.powder_averaging_nii_fn);

            RA = mdm_nii_read(input.seg2roi_ce_fn);
            RB = mdm_nii_read(input.seg2roi_tum_fn);

            % Focus on centre of contrast enhancement and tumor
            tmp = squeeze(sum(sum( (RA == 1) + (RB == 1),1),2));
            [~,k] = max(tmp);

            % zoom
            [ir,jr] = mio_mask_find_ranges(MDT > 0);

            irr = [min(ir) max(ir)] + [-5 5];
            jrr = [min(jr) max(jr)] + [-5 5];

            % mini_id = input.id( (0:2) + 19);
            % switch (mini_id)
            %     case '101' % interesting stroke
            %         k = 8;
            %     case '102' % interesting stroke
            %         k = 6;
            %     case '104' % interesting glioma
            %         k = 3;
            %     case '119'
            %         k = 7;
            %     case '126'
            %         k = 8;
            %     case '127'
            %         k = 9;
            %     case '130'
            %         k = 6;
            % 
            %     otherwise
            %         error('no slice defined');
            % 
            % end


            msf_clf;
            for c = 1:7

                w = 0.9 / 7;

                axes('position', ...
                    [0.05 + (c-1) * w, 0.3, w, 0.7]);

                cax = [];
                switch (c)

                    case 1
                        X = T1;

                    case 2
                        X = FLA;

                    case 3 % b0
                        X = mean(DWI_PA(:,:,:,1:2), 4);
                        
                    case 4 % b low
                        X = mean(DWI_PA(:,:,:,5:3:6), 4);

                    case 5 % b high ste
                        X = mean(DWI_PA(:,:,:,8), 4);

                    case 6
                        X = MD;
                        cax = [0.0 2.0];

                    case 7
                        X = MDT;
                        cax = [0.4 1.2];


                end

                tmp = fliplr(X(irr(1):irr(2), jrr(1):jrr(2),:));
                msf_imagesc(tmp, 3, k);

                if (~isempty(cax))
                    caxis(cax); 
                    %colorbar; 
                end


            end

            axes('position', [0.1 0.85 0.8 0.1]);
            axis off
            title(strrep(input.id, '_', ' '));

            1;



            colormap gray;
            msf_mkdir(fileparts(output.img_fn));
            msf_delete(output.img_fn);
            print(output.img_fn, '-dpng');
            
            

        end
        

    end
end



