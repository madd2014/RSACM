% Delete the non-connected components
% Author: Dongdong ma
% Date: 2/14/2021

function main_component = Non_main_component_delete(bw_Img,n)

[L,num] = bwlabel(bw_Img,n);
max_count = 0;
max_ind = 0;
for ii = 1:num
    temp = L == ii;
    count = sum(temp(:));
    if count > max_count
        max_count = count;
        max_ind = ii;
    end
end
main_component = L == max_ind;