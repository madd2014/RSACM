% ÏÔÊ¾30·ùÆ«ÕñÍ¼Ïñ

function polarImgShow()

clc;

data_path = 'H:\ÈéÏÙ°©×éÖ¯ºÍÏ¸°û·Ö¸î\data\cell_data\cutted_30\';
base_save_path = 'H:\ÈéÏÙ°©×éÖ¯ºÍÏ¸°û·Ö¸î\data\cell_data\fused_Img_mat\mean\';
cls_name_set = {'231', 'bt474', 'mcf7', 'sk-br-3'};
sample_Num = 50;
polar_Num = 30;

for ii = 4:4
    cls_path = strcat(data_path,cls_name_set{1,ii},'\');
    for jj = 1:sample_Num
        All_Img_data = [];
        for kk = 1:polar_Num
            csv_name = strcat(cls_path,num2str(jj),'\',num2str(kk),'.csv');
            Img_data1 = importdata(csv_name)/4095;
            csv_name = strcat(cls_path,num2str(jj),'\',num2str(kk+1),'.csv');
            Img_data2 = importdata(csv_name)/4095;
%             All_Img_data(:,:,kk) = Img_data;
            

            diff_data = Img_data1 - Img_data2;
            diff_data = diff_data - min(diff_data(:));
            diff_data = diff_data/max(diff_data(:));
            figure(1); imshow(diff_data);
            figure(2); imshow(Img_data1);
            figure(3); imshow(Img_data2);
            
        end
  
        Mean_Img_data = mean(All_Img_data,3);
        
        normalized_fused_Img = Mean_Img_data - min(Mean_Img_data(:));
        normalized_fused_Img = normalized_fused_Img/max(normalized_fused_Img(:));  
        
        save_path = strcat(base_save_path,cls_name_set{1,ii});
        if ~exist(save_path)
            mkdir(save_path);
        end
        save_name = strcat(save_path,'\fuse_',cls_name_set{1,ii},'_',num2str(jj),'.mat');
        save(save_name,'normalized_fused_Img');
        
    end
end

test_end = 1;