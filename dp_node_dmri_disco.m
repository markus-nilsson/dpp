classdef dp_node_dmri_disco < dp_node_workflow

    methods

        function obj = dp_node_dmri_disco(license_fn)
            
            % input: freesurfer license file

            nodes = {...
                dp_node_dmri_disco_synb0(license_fn), ...
                dp_node_io('topup_opt', dp_node_dmri_disco.topup_opt()), ...
                dp_node_dmri_topup_b0(), ...
                dp_node_dmri_topup_apply()};

            obj = obj@dp_node_workflow(nodes);

        end

    end

    methods (Static)

        function topt = topup_opt()

            % Topup options from 
            % https://github.com/MASILab/Synb0-DISCO/blob/master/src/synb0.cnf

            % Resolution (knot-spacing) of warps in mm
            topt.warpres = [20,16,14,12,10,6,4];
            
            % Subsampling level (a value of 2 indicates that a 2x2x2 neighbourhood is collapsed to 1 voxel)
            topt.subsamp = [2,2,2,2,2,1,1];
            
            % FWHM of gaussian smoothing
            topt.fwhm = [8,6,4,3,3,2,1];
            
            % Maximum number of iterations
            topt.miter = [5,5,5,5,5,15,15];
            
            % Relative weight of regularisation
            topt.lambda = [0.005,0.001,0.0001,0.000015,0.000005,0.0000005,0.00000005];
            
            % If set to 1 lambda is multiplied by the current average squared difference
            topt.ssqlambda = 1;
            
            % Regularisation model
            topt.regmod= 'bending_energy';
            
            % If set to 1 movements are estimated along with the field
            topt.estmov = [1,1,1,1,1,0,0];
            
            % 0=Levenberg-Marquardt, 1=Scaled Conjugate Gradient
            topt.minmet = [0,0,0,0,0,1,1];
            
            % Quadratic or cubic splines
            topt.splineorder = 3;
            
            % Precision for calculation and storage of Hessian
            topt.numprec = 'double';
            
            % Linear or spline interpolation
            topt.interp = 'spline';
            
            % If set to 1 the images are individually scaled to a common mean intensity
            topt.scale = 1 ;
            
        end
    end
end