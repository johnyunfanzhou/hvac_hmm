function normed_res = norm_seq(seq)
%Normalize over a sequence into an average day result
%   INPUT: sequence
%   OUTPUT: normalized sequence
normed_res = zeros(1,48);
for i = 1:size(normed_res,2)
    j = i;
    while j <= size(seq,2)
        normed_res(i) = normed_res(i) + seq(j);
        j = j + 48;
    end
end
normed_res = normed_res ./ (size(seq,2)/48);
end
