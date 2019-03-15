function pprint(str,length)

if nargin < 2
    fprintf(str);
else
    spacing_arg = ['%-', num2str(length),'s'];
    padded_string = sprintf(spacing_arg, str);
    fprintf(padded_string);
end

end