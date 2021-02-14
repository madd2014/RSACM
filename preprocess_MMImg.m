% Preprocessing for MMI
% Related sub-function：pre_processing.m
% Date: 2021/01/12
function preprocess_MMImg()

clc;
close all;

MMI_Cell_mat_path = 'H:\RingACM分割文章修改\new_data\cell\MMI\';
Preprocessed_MMI_Cell_mat_path = 'H:\RingACM分割文章修改\new_data\cell\preprocessed_MMI\';

ext_cls_name_set = {'0000231', '00bt474', '000mcf7', 'sk-br-3'};
cls_name_set = {'231', 'bt474', 'mcf7', 'sk-br-3'};
MM_name_set = { 'FinalM11','FinalM12','FinalM13','FinalM14','FinalM21','FinalM22','FinalM23','FinalM24',...
                'FinalM31','FinalM32','FinalM33','FinalM34','FinalM41','FinalM42','FinalM43','FinalM44'};
sample_Num = 30;

for ii = 1:length(ext_cls_name_set)
    for jj = 1:sample_Num
        % 在细胞图像上测试
        mat_name = strcat(MMI_Cell_mat_path,ext_cls_name_set{1,ii},'\',ext_cls_name_set{1,ii},'_',num2str(jj),'_FinalMM.mat');
        Img = load(mat_name);
        FinalM11 = Img.FinalM11;
        FinalMM = zeros(size(FinalM11,1),size(FinalM11,2),16);

        for kk = 1:16
            FinalMM(:,:,kk) = pre_processing(getfield(Img,MM_name_set{1,kk}));
%             figure(1);
%             imshow(FinalMM(:,:,kk));
            
        end

        save_mat_name = strcat(Preprocessed_MMI_Cell_mat_path,ext_cls_name_set{1,ii},'\',ext_cls_name_set{1,ii},'_',num2str(jj),'.mat');
        save(save_mat_name,'FinalMM');

    end
end

test_end  = 1;




