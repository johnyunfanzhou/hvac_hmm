function [M,S,H,W] = extrac_num(num)
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here
num = num - 1;
[M,num] = quorem(sym(num),sym(48*2*3));
[S,num] = quorem(sym(num),sym(48*2));
[H,W] = quorem(sym(num),sym(2));
end

