function opt = dp_opt(opt, node)

opt = msf_ensure_field(opt, 'verbose', 0);
opt = msf_ensure_field(opt, 'do_try_catch', 1);
opt = msf_ensure_field(opt, 'id_filter', {});
opt = msf_ensure_field(opt, 'iter_mode', 'iter');

opt = msf_ensure_field(opt, 'c_level', 0);
opt.c_level = opt.c_level + 1;


opt.indent = zeros(1, 2*(opt.c_level - 1)) + ' ';
opt.log = @(varargin) fprintf(cat(2, '%s', varargin{1}, '\n'), opt.indent, varargin{2:end});


opt = msf_ensure_field(opt, 'id_filter', {});

if (ischar(opt.id_filter))
    opt.id_filder = {opt.id_filter};
end


end