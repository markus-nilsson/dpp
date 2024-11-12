classdef dp % data processor

    % we are working with input and output structures, with some rules
    % embedded here

    % fields that are expected of the input and output structures
    %
    % id - uniquely defines a subject or subject/date
    % bp - base path
    % *_fn - filenames, will be checked if they exist
    %
    % in addition, it could have these field(s):
    %
    % tmp - temporary info, with fields
    %   bp - base path
    %   do_delete - determines whether the path will be deleted after
    %   execution


    methods (Static)


        function node = setup_node(name, prev, node)
            warning('use node.setup instead')
            node.name = name;
            node.previous_node = prev;

        end

        function fn = new_fn(op, fn, suffix, ext_in)
            
            if (nargin < 3), suffix = ''; end
            if (nargin < 4), ext_in = ''; end

            [~, name, ext] = msf_fileparts(fn);

            if (~isempty(ext_in))
                ext = ext_in; 
            end

            fn = fullfile(op, cat(2, name, suffix, ext));

        end

    end
end