function change_name()

clc;
close all;

mask_path = 'H:\Mask_mat\';
data_path = 'H:\fused_data\';
cls_name_set = {'231', 'bt474', 'mcf7', 'sk-br-3'};
new_cls_name_set = {'MM231', 'BT474', 'MCF7', 'SK-BR-3'};
sample_Num = 30;

for ii = 2:length(cls_name_set)
    for jj = 1:sample_Num
        orig_data_mat_name = strcat(data_path,new_cls_name_set{1,ii},'\','fuse2_',new_cls_name_set{1,ii},'_',num2str(jj),'.mat');
        new_data_mat_name = strcat(data_path,new_cls_name_set{1,ii},'\','fuse_',new_cls_name_set{1,ii},'_',num2str(jj),'.mat');
        movefile(orig_data_mat_name,new_data_mat_name);
%         orig_mat_name = strcat(mask_path,new_cls_name_set{1,ii},'\',cls_name_set{1,ii},'_',num2str(jj),'_1_mask.mat');
%         new_mat_name = strcat(mask_path,new_cls_name_set{1,ii},'\',new_cls_name_set{1,ii},'_',num2str(jj),'_mask.mat');
%         movefile(orig_mat_name,new_mat_name);
    ii
        
    end
end

test = 1;