% Dynamic Fusion of Mueller Matrix Images for Medical Image Segmentation with Ring-shaped Active Contour Model
% Author: Dongdong Ma
% 2021/02/14
clc;
close all;
clear;

choice_polar_or_MMI = 2;
Polar_Cell_mat_path = 'H:\RingACM分割文章修改\new_data\cell\preprocessed_polarization_img\';
MMI_Cell_mat_path = 'H:\RingACM分割文章修改\new_data\cell\preprocessed_MMI\';
img_num_set = [30,16,30,16];

HE_mask_path = 'H:\RingACM分割文章修改\new_data\HE_stained\mask\';
cell_mask_path = 'H:\RingACM分割文章修改\new_data\cell\mask\';
BDCIS_mask_path = 'H:\RingACM分割文章修改\new_data\BDCIS\mask\';

ext_cls_name_set = {'0000231', '00bt474', '000mcf7', 'sk-br-3'};
cls_name_set = {'231', 'bt474', 'mcf7', 'sk-br-3'};
MM_name_set = { 'FinalM11','FinalM12','FinalM13','FinalM14','FinalM21','FinalM22','FinalM23','FinalM24',...
                'FinalM31','FinalM32','FinalM33','FinalM34','FinalM41','FinalM42','FinalM43','FinalM44'};
sample_Num = 30;      % number polarization images of each sample
Img_Num_per_sample = img_num_set(choice_polar_or_MMI);

numIter = 500;
max_Iter = 20;
inner_Iter = 5;    
timestep = 1;
eta = 0.1;                     % parameter in impulse function

varepsilon = 1;                % determin the width of ring
alpha = 0.001;                 % parameter of E_region
beta = 0.8;                    % parameter of E_area
gamma = 0.1/timestep;          % parameter of E_reg
smooth_rate = 0.001;
thred = 0.0001;

c0 = 5;                        % 
lambda = 1;                    % control the magnitude of standard deviation map

All_Accuracy = zeros(length(ext_cls_name_set),sample_Num);
Change_rate_curve = zeros(length(ext_cls_name_set),sample_Num,numIter);
All_weight_vec = zeros(length(ext_cls_name_set),sample_Num,numIter,Img_Num_per_sample);
for ii = 1:length(ext_cls_name_set)
    for jj = 1:sample_Num
        if choice_polar_or_MMI == 1
            mat_name = strcat(Polar_Cell_mat_path,ext_cls_name_set{1,ii},'\',ext_cls_name_set{1,ii},'_',num2str(jj),'.mat');
            Img_struct = load(mat_name);
            multiple_imgs = Img_struct.polarization_imgs;         
        elseif choice_polar_or_MMI == 2
            mat_name = strcat(MMI_Cell_mat_path,ext_cls_name_set{1,ii},'\',ext_cls_name_set{1,ii},'_',num2str(jj),'.mat');
            Img_struct = load(mat_name);
            multiple_imgs = Img_struct.FinalMM;
        elseif choice_polar_or_MMI == 3
            mat_name = strcat(Polar_BDCIS_mat_path,ext_cls_name_set{1,ii},'\',ext_cls_name_set{1,ii},'_',num2str(jj),'.mat');
            Img_struct = load(mat_name);
            multiple_imgs = Img_struct.polarization_imgs;  
        else
            mat_name = strcat(MMI_BDCIS_mat_path,ext_cls_name_set{1,ii},'\',ext_cls_name_set{1,ii},'_',num2str(jj),'.mat');
            Img_struct = load(mat_name);
            multiple_imgs = Img_struct.FinalMM;           
        end

        %************************** Linear weighting to fuse the 30 images *************************
        initial_weight_vec = ones(Img_Num_per_sample,1)*1/Img_Num_per_sample;   % initial weight vector
        fused_Img = Linear_weighting(multiple_imgs,initial_weight_vec);
        % normalize
        fused_Img = fused_Img - min(min(fused_Img));
        fused_Img = fused_Img/max(max(fused_Img));
%         figure(1); imshow(fused_Img);

        Img = fused_Img*255;         
        initialLSF = c0*ones(size(Img));
        initialLSF(45:end-45,45:end-45) = 0;
        initialLSF(85:end-85,85:end-85) = -c0;
        u = initialLSF;

%         figure(1);
%         imshow((initialLSF+c0)/(2*c0));
%         figure(2);
%         imagesc(Img,[0 255]);colormap(gray)
%         hold on;
%         contour(u,[-varepsilon -varepsilon],'r');
%         contour(u,[varepsilon varepsilon],'g');

        sigma = 2;                                % scale parameter in Gaussian kernel
        G = fspecial('gaussian',5, sigma);        % Caussian kernel
        Img_smooth = conv2(Img, G, 'same');       % smooth image by Gaussian convolution
        [Ix,Iy] = gradient(Img_smooth);
        f = Ix.^2 + Iy.^2;
        g = 1./(1 + f);                           % edge indicator function.

        u1 = u;
        u2 = u;
        % 计算初始时的sigma_map_x
        inner_binary_mask = u1 < -varepsilon;
        ring_binary_mask = u1 < varepsilon & u1 > -varepsilon;
        outer_binary_mask = u1 > varepsilon;
        inner_region = Img(inner_binary_mask);
        ring_region = Img(ring_binary_mask);
        outer_region = Img(outer_binary_mask);
        inner_C = mean(inner_region);
        ring_C = mean(ring_region);
        outer_C = mean(outer_region);
        sigma_map_x = Img;
        sigma_map_x(inner_binary_mask) = inner_region - inner_C;
        sigma_map_x(ring_binary_mask) = ring_region - ring_C;
        sigma_map_x(outer_binary_mask) = outer_region - outer_C;
        sigma_map_x = smooth_rate*sigma_map_x;

        for k = 1:numIter
            pre_u1 = u1;
            [u1,sigma_map_x,lambda] = Ring_Seg_EVOL(smooth_rate,sigma_map_x,varepsilon, g, Img, u1, alpha, beta, gamma,lambda, timestep, eta, inner_Iter);   % update level set function
%             if mod(k,10) == 0
%                 pause(.1);
%                 figure(2),imagesc(Img,[0 255]); colormap(gray);
%                 title(num2str(k));
%                 hold on;
%                 contour(u1,[-varepsilon -varepsilon],'r');
%                 contour(u1,[varepsilon varepsilon],'g');
%             end 

            % Determine whether the stopping condition is satisfied
            residual_change_rate = Calculate_change_rate(pre_u1,u1,varepsilon,eta);
            Change_rate_curve(ii,jj,k) = residual_change_rate;
            if (k >= max_Iter || residual_change_rate < thred)
%                 pause(.1);
%                 figure(2),imagesc(Img,[0 255]); colormap(gray);
%                 title(num2str(k));
%                 hold on;
%                 contour(u1,[-varepsilon -varepsilon],'r');
%                 contour(u1,[varepsilon varepsilon],'g');
                break;
            else
                % scoring each image to get the updated weighting vector
                updated_weight_vec = score_for_each_Img(u1,multiple_imgs,varepsilon); 

                All_weight_vec(ii,jj,k,:) = updated_weight_vec;
                fused_Img = Linear_weighting(multiple_imgs,updated_weight_vec);  
                fused_Img = fused_Img - min(min(fused_Img));
                fused_Img = fused_Img/max(max(fused_Img));
                Img = fused_Img*255;        
            end
        end  
        final_u = u1;
        result_bmap = u1 < 0;        % Get the binary map with the threshold 0
        result_bmap = New_Improved_Non_main_component_delete(result_bmap,8,1);      % Delete the irrelevant regions
%         figure(4),imshow(result_bmap);
        result_bmap = imfill(result_bmap,'holes');
%         figure(5),imshow(result_bmap);

        % Load the ground truth and calculate Dice index value
        mask_name = strcat(cell_mask_path,ext_cls_name_set{1,ii},'\',cls_name_set{1,ii},'_',num2str(jj),'_1_mask.mat');
        mask_data = load(mask_name);
        mask_data = mask_data.cutted_mask;

        DC_rate = DC_calculation(result_bmap,mask_data);
        All_Accuracy(ii,jj) = DC_rate;

    end
end

% Save the accracy, weighting vector, and change rate curve
% save_path = 'H:\RingACM分割文章修改\code\最新算法\result_mat_save_for_cell\self_method';
% if choice_polar_or_MMI == 2 || choice_polar_or_MMI == 4
%     save(strcat(save_path,'MMI_All_Accuracy.mat'),'All_Accuracy');
%     save(strcat(save_path,'MMI_All_weight_vec.mat'),'All_weight_vec');
%     save(strcat(save_path,'MMI_Change_rate_curve.mat'),'Change_rate_curve');
% else
%     save(strcat(save_path,'Polar_All_Accuracy.mat'),'All_Accuracy');
%     save(strcat(save_path,'Polar_All_weight_vec.mat'),'All_weight_vec');
%     save(strcat(save_path,'Polar_Change_rate_curve.mat'),'Change_rate_curve');    
% end
mean(mean(All_Accuracy))

test_end = 1;








