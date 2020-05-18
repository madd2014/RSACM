% 计算True positive(TP)指数
% 输入I_Out和I_Mask都是二值图像
% 输入必须都是logical，否则下面的减号不成立
function FP_rate = FP_calculation(I_Out,I_Mask)

% I_Out = ones(10,10) > 0;
% I_Mask = (randi(2,10,10)-1) > 0;
unit_region = I_Out | I_Mask;
numerator = sum(sum(unit_region - I_Mask));
denominator = sum(sum(I_Mask));
FP_rate = numerator/denominator;



% TP_rate
% test_end = 1;