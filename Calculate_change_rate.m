% Calculate the change rate of area to determine whether the stopping
% condition is satisfied
function residual_change_rate = Calculate_change_rate(pre_phi,phi,varepsilon,eta)

pre_inter_Hphi = Heaviside(-varepsilon - pre_phi, eta);
pre_mid_Hphi = Heaviside(varepsilon^2 - pre_phi.^2, eta);
pre_outer_Hphi = Heaviside(-varepsilon + pre_phi, eta);
current_inter_Hphi = Heaviside(-varepsilon - phi, eta);
current_mid_Hphi = Heaviside(varepsilon^2 - phi.^2, eta);
current_outer_Hphi = Heaviside(-varepsilon + phi, eta);

abs_diff_inter_Hphi = abs(sum(pre_inter_Hphi(:)) - sum(current_inter_Hphi(:)));
abs_diff_mid_Hphi = abs(sum(pre_mid_Hphi(:)) - sum(current_mid_Hphi(:)));
abs_diff_outer_Hphi = abs(sum(pre_outer_Hphi(:)) - sum(current_outer_Hphi(:)));
% residual_change_rate = sum(abs_diff_inter_Hphi(:))/sum(pre_inter_Hphi(:)) + sum(abs_diff_mid_Hphi(:))/sum(pre_mid_Hphi(:));% + sum(abs_diff_outer_Hphi(:))/sum(pre_outer_Hphi(:));
residual_change_rate = sum(abs_diff_inter_Hphi(:))/sum(pre_inter_Hphi(:))+sum(abs_diff_mid_Hphi(:))/sum(pre_mid_Hphi(:))+sum(abs_diff_outer_Hphi(:))/sum(pre_outer_Hphi(:));

function H = Heaviside(phi,eta) 
H = 0.5*(1 + (2/pi)*atan(phi./eta));


