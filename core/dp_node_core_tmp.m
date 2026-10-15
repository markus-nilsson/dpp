classdef dp_node_core_tmp < handle

    % works in progress
    % 
    % helps managing temporary files 
    %
    % run clean should not be here, but somewhere else, where it calls
    % functions registered to be executed

    methods

        function tmp = make_tmp(obj, do_mkdir)
            if (nargin < 2)
                do_mkdir = 1;
            end
            tmp.bp = msf_tmp_path(do_mkdir);
            tmp.do_delete = 1;
        end   

        function output = run_clean(obj, output)

            % clean up temporary directory if asked to do so
            if (~isstruct(output)), return; end
            
            if (~isfield(output, 'tmp')), return; end
            
            if (~isfield(output.tmp, 'do_delete')), return; end
            
            if (~output.tmp.do_delete), return; end

            msf_delete(output.tmp.bp);
            
        end        
       
        
    end   

end