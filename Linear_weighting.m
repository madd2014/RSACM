% Linear weighting function
% Date: 1/12/2021
function fused_Img = Linear_weighting(multiple_imgs,initial_weight_vec) 

fused_Img = zeros(size(multiple_imgs,1),size(multiple_imgs,2));
for ii = 1:size(multiple_imgs,3)
    fused_Img = multiple_imgs(:,:,ii)*initial_weight_vec(ii);
end
end