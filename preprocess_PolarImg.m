% Preprocessing for polarization images
% Related sub-function：pre_processing.m
% Date: 2021/01/12
function preprocess_PolarImg()

clc;
close all;

Polar_mat_path = 'H:\RingACM分割文章修改\new_data\cell\polarization_img\';
Preprocessed_Polar_mat_path = 'H:\RingACM分割文章修改\new_data\cell\preprocessed_polarization_img\';

ext_cls_name_set = {'0000231', '00bt474', '000mcf7', 'sk-br-3'};
cls_name_set = {'231', 'bt474', 'mcf7', 'sk-br-3'};
MM_name_set = { 'FinalM11','FinalM12','FinalM13','FinalM14','FinalM21','FinalM22','FinalM23','FinalM24',...
                'FinalM31','FinalM32','FinalM33','FinalM34','FinalM41','FinalM42','FinalM43','FinalM44'};
sample_Num = 30;

for ii = 1:length(ext_cls_name_set)
    for jj = 1:sample_Num
 
        % 在细胞图像上测试
        mat_name = strcat(Polar_mat_path,ext_cls_name_set{1,ii},'\',ext_cls_name_set{1,ii},'_',num2str(jj),'.mat');
        Img = load(mat_name);
        polarization_imgs = Img.polarization_imgs;
        for kk = 1:size(polarization_imgs,3)
            polarization_imgs(:,:,kk) = pre_processing(polarization_imgs(:,:,kk));
%             figure(1);
%             imshow(polarization_imgs(:,:,kk));
            
        end

        save_mat_name = strcat(Preprocessed_Polar_mat_path,ext_cls_name_set{1,ii},'\',ext_cls_name_set{1,ii},'_',num2str(jj),'.mat');
        save(save_mat_name,'polarization_imgs');
    end
end

test_end  = 1;




