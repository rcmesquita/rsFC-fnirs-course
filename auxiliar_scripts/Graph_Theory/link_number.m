function [n] = link_number(A)

n = sum(sum(A)); 
n = n/2;
end