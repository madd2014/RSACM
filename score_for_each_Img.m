% 为每一幅图像进行打分的函数
% 2021年1月12日晚

function updated_weight_vec = score_for_each_Img(refined_segmented_binary_map,multiple_imgs,varepsilon)

c1 = 0.75;
c2 = 0.25;
score_vec = zeros(size(multiple_imgs,3),1);
inner_binary_map = refined_segmented_binary_map < -varepsilon;
mid_binary_map = refined_segmented_binary_map < varepsilon & refined_segmented_binary_map > -varepsilon;
outer_binary_map = refined_segmented_binary_map > varepsilon;

[gx,gy] = gradient(mid_binary_map);
gmap_mid_binary_map = gx.^2 + gy.^2;
positive_g_point = gmap_mid_binary_map > 0;
boundary_point_num = sum(positive_g_point(:));
for ii = 1:size(multiple_imgs,3)
    this_Img = multiple_imgs(:,:,ii);
    % 首先计算灰度一致性
    inner_pixel_values = this_Img(inner_binary_map);
    mid_pixel_values = this_Img(mid_binary_map);
    outer_pixel_values = this_Img(outer_binary_map);
    
    mean_inner_pixel = mean(inner_pixel_values);
    mean_mid_pixel = mean(mid_pixel_values);
    mean_outer_pixel = mean(outer_pixel_values);
    gray_consistence = ((mean_inner_pixel-mean_mid_pixel)^2 + (mean_inner_pixel-mean_outer_pixel)^2 + (mean_mid_pixel-mean_outer_pixel)^2);
    
    std_inner_pixel = std(inner_pixel_values);
    std_mid_pixel = std(mid_pixel_values);
    std_outer_pixel = std(outer_pixel_values);
    std_consistence = (std_inner_pixel+ std_mid_pixel + std_outer_pixel);     % 最大为3
    
%     figure(3); imshow(this_Img);
    % 然后计算边界所在像素的梯度值
    [Ix,Iy] = gradient(this_Img);
    gmap_this_Img = Ix.^2 + Iy.^2;
    gmap_this_Img = gmap_this_Img - min(gmap_this_Img(:));
    gmap_this_Img = gmap_this_Img/max(gmap_this_Img(:));                   % 归一化
    boundary_gradient_map = positive_g_point.*gmap_this_Img/boundary_point_num;
    gradient_consistence = sum(boundary_gradient_map(:));
    
%     score_vec(ii) = c1*(3-std_consistence) + c2*gradient_consistence;
%     score_vec(ii) = c1*(gray_consistence+3-std_consistence) + c2*gradient_consistence;
%     score_vec(ii) = c1*(std_consistence) + c2*gradient_consistence;
%     score_vec(ii) = c1*gray_consistence + c2*gradient_consistence;
%     score_vec(ii) = (std_consistence)/(gray_consistence + exp(-10));
%     score_vec(ii) = (gray_consistence)/(std_consistence + exp(-10));
%     score_vec(ii) = gray_consistence + (1 - std_consistence);    
%       score_vec(ii) = gray_consistence + (3 - std_consistence);   


    score_vec(ii) = c1*gray_consistence + c2*gradient_consistence;
%       score_vec(ii) = (gray_consistence)/(std_consistence + exp(-10));
end
updated_weight_vec = score_vec/sum(score_vec);
test_end = 1;




