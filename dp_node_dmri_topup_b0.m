classdef dp_node_dmri_topup_b0 < dp_node

    % Estimate b0 using topup

    methods

        function obj = dp_node_dmri_topup_b0()
            obj.output_test = {'fieldmap_fn'};
        end
        
        % construct names of output files
        function output = i2o(obj, input)

            % pass on the input
            output = input;

            % other files
            output.topup_data_path = fullfile(input.op, 'topup_data');
            output.fieldmap_fn   = fullfile(input.op, 'fieldmap.nii.gz');
            

            % input management of options
            if (~isfield(input, 'topup_cnf'))
                input.topup_cnf = 'b02bo'; 
            end

            if (isfield(input, 'topup_opt'))
                input.topup_cnf = 'custom';
            end

            switch (input.topup_cnf)

                case 'b02bo' % replicating b02bo.cnf
                    % https://github.com/ahheckel/FSL-scripts/blob/master/rsc/fsl/fsl4/topup/b02b0.cnf
                    topt.warpres = [20,16,14,12,10,6,4,4,4];
                    topt.subsamp = [2,2,2,2,2,1,1,1,1];
                    topt.fwhm    = [8,6,4,3,3,2,1,0,0];
                    topt.miter   = [5,5,5,5,5,10,10,20,20];
                    topt.lambda  = [0.005,0.001,0.0001,0.000015,0.000005,0.0000005,0.00000005,0.0000000005,0.00000000001];                    
                    topt.estmov  = [1,1,1,1,1,0,0,0,0];
                    topt.minmet  = [0,0,0,0,0,1,1,1,1];

                case 'none'
                    topt = struct();

                case 'custom'
                    topt = input.topup_opt;
            end

            output.topt = topt;            

        end

        function output = execute(obj, input, output)

            % run topup ( all input files need to be present already)

            f = @(x,y) sprintf(['--' x ' '], y);
            
            cmd = {...
                'topup ', ...
                f('imain=%s',  input.topup_nii_fn), ...
                f('datain=%s', input.topup_spec_fn), ...
                f('out=%s',    output.topup_data_path), ...
                f('fout=%s',   output.fieldmap_fn) ...
                };

            % integer fields
            opt_fields = {...
                'warpres', ...
                'subsamp', ...
                'fwhm', ...
                'miter', ...                
                'estmov', ...
                'minmet', ...
                'ssqlambda', ...
                'splineorder', ...
                'scale', ...
                'nthr'};

            h = @(x) [x(1:(end-1))];
            p = @(x) h(sprintf('%i,',x));
            g = @(y,z) sprintf('--%s=%s ', y,z);
  
            for c = 1:numel(opt_fields)
                if (~isfield(output.topt, opt_fields{c})), continue; end
                cmd{end+1} = g(...
                    opt_fields{c}, ...
                    p(output.topt.(opt_fields{c})));
            end

            % float field
            p = @(x) h(sprintf('%1.12f,',x));
            if (isfield(output.topt, 'lambda')) 
                cmd{end+1} = g(...
                    'lambda', ...
                    p(output.topt.lambda));
            end

            % strings
            opt_fields = {...
                'regmod', ...
                'numprec', ...
                'intrep'};

            for c = 1:numel(opt_fields)
                if (~isfield(output.topt, opt_fields{c})), continue; end
                cmd{end+1} = g(...
                    opt_fields{c}, ...
                    output.topt.(opt_fields{c}));
            end

            % verbose
            if (obj.opt.verbose > 1)
                cmd{end+1} = '--verbose ';
            end

            % now run it
            cmd = sprintf('bash --login -c ''%s'' ', [cmd{:}]);

            [status,cmdout] = system(cmd);

            if (status > 0)
                disp(cmd);
                error(cmdout);
            end


        end
    end
end
