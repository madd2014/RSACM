% Date: 2020/03/06
% Description: a new fuse algorithm, which firstly get the gradient image of each polar
% image, then fuse theml according their gradient amplitude
% Author: Dongdong Ma

function Image_fuse()

clc;

data_path = '/data/';
base_save_path = '/data/fused_Img_mat/';
cls_name_set = {'231', 'bt474', 'mcf7', 'sk-br-3'};
sample_Num = 50;
polar_Num = 30;
block_width = 8;

for ii = 2:length(cls_name_set)
    cls_path = strcat(data_path,cls_name_set{1,ii},'/');
    for jj = 1:sample_Num
        
        % Step1: calculate the gradient image for each polar image
        All_normalized_gradient_Img_data = [];
        for kk = 1:polar_Num
            csv_name = strcat(cls_path,num2str(jj),'/',num2str(kk),'.csv');
            Img_data = importdata(csv_name)/4095;
            [Ix,Iy] = gradient(Img_data);
            f = Ix.^2 + Iy.^2;
            gradient_Img_data = 1./(1 + f); 
            normalized_gradient_Img_data = gradient_Img_data - min(gradient_Img_data(:));
            normalized_gradient_Img_data = normalized_gradient_Img_data/max(normalized_gradient_Img_data(:));
            
            All_normalized_gradient_Img_data(:,:,kk) = 1-normalized_gradient_Img_data;
        end
  
        sum_normalized_gradient_Img_data = sum(All_normalized_gradient_Img_data,3);
        normalized_fused_Img = sum_normalized_gradient_Img_data - min(sum_normalized_gradient_Img_data(:));
        normalized_fused_Img = normalized_fused_Img/max(normalized_fused_Img(:));
        
        save_path = strcat(base_save_path,cls_name_set{1,ii});
        if ~exist(save_path)
            mkdir(save_path);
        end
        save_name = strcat(save_path,'/fuse_',cls_name_set{1,ii},'_',num2str(jj),'.mat');
        save(save_name,'normalized_fused_Img');
        
    end
end

test_end = 1;


