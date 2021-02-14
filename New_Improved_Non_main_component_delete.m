% Delete the non-connected components, remain m maximum connected components
% Author: Dongdong ma
% Date: 2020/03/10

function main_component = New_Improved_Non_main_component_delete(bw_Img,n,m)

[L,num] = bwlabel(bw_Img,n);
pixel_count = zeros(1,num);
for ii = 1:num
    temp = L == ii;
    pixel_count(ii) = sum(temp(:));
end
[~,sorted_ind] = sort(pixel_count,'descend');
main_component = zeros(size(bw_Img));
for ii = 1:length(m)
    key_ind = m(ii);
    main_component = main_component | (L == sorted_ind(key_ind));
end
