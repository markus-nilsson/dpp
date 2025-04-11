classdef dp_node_core_tmp < handle

    % works in progress
    % 
    % helps managing temporary files 
    %
    % run clean should not be here, but somewhere else, where it calls
    % functions registered to be executed

    methods

        function tmp = make_tmp(~)
            tmp.bp = msf_tmp_path(1);
            tmp.do_delete = 1;
        end   

        function output = run_clean(~, output)

            % clean up temporary directory if asked to do so
            if (~isstruct(output)), return; end
            
            if (isfield(output, 'tmp')) && ...
                    (isfield(output.tmp, 'do_delete')) && ...
                    (output.tmp.do_delete)

                msf_delete(output.tmp.bp);

            end
            
        end        
       
        
    end   

end