% 计算True positive(TP)指数
% 输入I_Out和I_Mask都是二值图像
% 输入必须都是logical，否则下面的减号不成立
function DC_rate = DC_calculation(I_Out,I_Mask)

cross_region = I_Out & I_Mask;
numerator = sum(sum(cross_region));
denominator = sum(sum(I_Out)) + sum(sum(I_Mask));
DC_rate = 2*numerator/denominator;


% TP_rate
% test_end = 1;