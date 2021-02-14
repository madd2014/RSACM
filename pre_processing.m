% Main preprocessing function
% Function£ºto enhance the gray intensities of cell region and suppress the gray intensities of background
% Date: 2021/01/08

function pre_processed_Img = pre_processing(input_Img)

block_width_set = {3,5,7};
[rows,cols] = size(input_Img);
pyramid_std_Img = zeros(rows, cols, length(block_width_set));
for ii = 1:length(block_width_set)
    block_width = block_width_set{1,ii};
    
    ext_Img_data = padarray(input_Img,[(block_width-1)/2,(block_width-1)/2],'symmetric','both');
    block_Img_data = im2col(ext_Img_data,[block_width,block_width],'sliding');
    std_Img_data = std(block_Img_data);
    std_Img = reshape(std_Img_data,size(input_Img,1),size(input_Img,2));
    normlized_std_Img = std_Img - min(std_Img(:));
    std_Img = normlized_std_Img/max(normlized_std_Img(:));
    
    pyramid_std_Img(:,:,ii) = std_Img;
end

mid_processed_Img = max(pyramid_std_Img,[],3);

% enhanced image
enhanced_Img = mid_processed_Img*255;
[hist_vector,~] = imhist(uint8(enhanced_Img));
csum_hist_vector = cumsum(hist_vector/sum(hist_vector));
beta = 0.97;
[~,target_ind] = min(abs(csum_hist_vector-beta));
mask_img = enhanced_Img > target_ind - 1;
enhanced_Img(mask_img) = target_ind - 1;
enhanced_Img = enhanced_Img - min(enhanced_Img(:));
enhanced_Img = enhanced_Img./max(enhanced_Img(:));

pre_processed_Img = enhanced_Img;

test_end = 1;












