% maximum filter, remain the maximum value in block
% 1/8/2021
function filted_Img = max_filter(input_Img, block_width)


ext_Img_data = padarray(input_Img,[(block_width-1)/2,(block_width-1)/2],'symmetric','both');
block_Img_data = im2col(ext_Img_data,[block_width,block_width],'sliding');

max_Img_data = max(block_Img_data,[],1);
max_Img_data = reshape(max_Img_data,size(input_Img,1),size(input_Img,2));

normlized_max_Img_data = max_Img_data - min(max_Img_data(:));
filted_Img = normlized_max_Img_data/max(normlized_max_Img_data(:));