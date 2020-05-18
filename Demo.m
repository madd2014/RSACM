% Unsupervised breast cancer cell segmentation with Ring-shape active
% contour model on polarization images.
% The dataset can be downloaded on website:
% Date: 2020/05/18
% Author: Dongdong Ma

clc;
close all;

mask_path = 'H:\data_code\Mask_mat\';
data_path = 'H:\data_code\fused_data\';
cls_name_set = {'MM231', 'BT474', 'MCF7', 'SK-BR-3'};
sample_Num = 30;

numIter = 1200;
timestep = 1;
lambda1 = 9;
lambda2 = 3;
lambda3 = 0.2/timestep;
lambda4 = 3;
lambda5 = 0.00001;

epsilon = 1;
margin_a = 2;
c0 = 5;

All_Accuracy = [];
for ii = 1:length(cls_name_set)
    for jj = 1:sample_Num
        
        %**************************** load images ******************************
        mat_name = strcat(data_path,cls_name_set{1,ii},'\','fuse_',cls_name_set{1,ii},'_',num2str(jj),'.mat');
        temp = load(mat_name);
        Img = temp.normalized_fused_Img;  

        block_width = 3;
        
        % std img
        ext_Img_data = padarray(Img,[(block_width-1)/2,(block_width-1)/2],'symmetric','both');
        block_Img_data = im2col(ext_Img_data,[block_width,block_width],'sliding');
        std_Img_data = std(block_Img_data);
        std_Img = reshape(std_Img_data,size(Img,1),size(Img,2));
        normlized_std_Img = std_Img - min(std_Img(:));
        std_Img = normlized_std_Img/max(normlized_std_Img(:)); 
        
        test = Img*255;
        [hist_vector,hist_pos] = imhist(uint8(test));
        csum_hist_vector = cumsum(hist_vector/sum(hist_vector));
        beta = 0.97;
        [~,target_ind] = min(abs(csum_hist_vector-beta));
        mask_img = test > target_ind - 1;
        test(mask_img) = target_ind - 1;
        test = test - min(test(:));
        test = test./max(test(:));
        
        % mean filter
        h = fspecial('average',[5,5]);
        test = filter2(h,test);
        Img = test*255;
        
        initialLSF = c0*ones(size(Img));
        initialLSF(25:end-25,25:end-25) = 0;
        initialLSF(45:end-45,45:end-45) = -c0;
        u = initialLSF;
        
        figure(jj);
        imagesc(Img,[0 255]);colormap(gray)
        hold on;
        contour(u,[0 0],'r');

        sigma = 2;                            % scale parameter in Gaussian kernel
        G = fspecial('gaussian',5,sigma);     % Caussian kernel
        Img_smooth = conv2(Img,G,'same');     % smooth image by Gaussian convolution
        
        [Ix,Iy] = gradient(Img_smooth);
        f = Ix.^2 + Iy.^2;
        g = 1./(1 + f);                       % edge indicator function.

        for k = 1:numIter
            u = Ring_Seg_EVOL(margin_a, g,std_Img, u,lambda1,lambda2, lambda3, lambda4, lambda5, timestep, epsilon, 1);   % update level set function
            if mod(k,10) == 0
                pause(.1);
                figure(jj),imagesc(Img,[0 255]);colormap(gray)
                title(num2str(k));
                hold on;
                contour(u,[-margin_a -margin_a],'r');
                contour(u,[margin_a margin_a],'g');
            end    
        end  
        u1 = u;
        result_bmap1 = u1 < 0;
        result_bmap1 = Non_main_component_delete(result_bmap1,8);
%         figure(2),imshow(result_bmap1);
        result_bmap1 = imfill(result_bmap1,'holes');
        figure(3),imshow(result_bmap1);
        
        % calculate accuracy
        mask_name = strcat(mask_path,cls_name_set{1,ii},'\',cls_name_set{1,ii},'_',num2str(jj),'_1_mask.mat');
        mask_data = load(mask_name);
        mask_data = mask_data.cutted_mask;
        
        fuse1_DC_rate = DC_calculation(result_bmap1,mask_data)
        
    end
end




