% Create date: 1/5/2021£¬main function for ring-shaped active contour model
% Author: Dongdong Ma
% Modified date: 2/14/2021

function [phi,sigma_map_x,lambda] = self_new_Ring_Seg_EVOL_v5(smooth_rate,sigma_map_x,varepsilon, g, Img, u, alpha, beta, gamma,lambda, timestep, eta, numIter)

phi = u;
[vx, vy] = gradient(g);
smallNumber = 1e-10;  
for k = 1:numIter
    phi = NeumannBoundCond(phi);
        
    diracPhi_inner = Delta_inner(varepsilon,phi,eta);          % Delta function is symmetrical£¬Delta(-phi-margin_a) = Delta(phi+margin_a)
    diracPhi_ringregion = Delta_ringregion(varepsilon,phi,eta);
    diracPhi_outer = Delta_outer(varepsilon,phi,eta);
    
    % Calculate curvature_inner
    [phi_x_inner,phi_y_inner] = gradient(-phi-varepsilon);
    s = sqrt(phi_x_inner.^2 + phi_y_inner.^2);
    Nx_inner = phi_x_inner./(s + smallNumber); % add a small positive number to avoid division by zero
    Ny_inner = phi_y_inner./(s + smallNumber);
    curvature_inner = div(Nx_inner, Ny_inner);
  
    % Calculate curvature_outer
    [phi_x_outer,phi_y_outer] = gradient(phi-varepsilon);
    s = sqrt(phi_x_outer.^2 + phi_y_outer.^2); 
    Nx_outer = phi_x_outer./(s + smallNumber); % add a small positive number to avoid division by zero
    Ny_outer = phi_y_outer./(s + smallNumber);
    curvature_outer = div(Nx_outer, Ny_outer);
    
    edgeTerm1 = diracPhi_inner.*(vx.*Nx_inner + vy.*Ny_inner) + diracPhi_inner.*g.*curvature_inner;         % dirac*div(g*d_phi/abs(d_phi)),div (u A ) =u div A+ A grad u,uÎªï¿½ï¿½ï¿½ï¿½
    edgeTerm2 = diracPhi_outer.*(vx.*Nx_outer + vy.*Ny_outer) + diracPhi_outer.*g.*curvature_outer; 
    edgeTerm = - edgeTerm1 + edgeTerm2;
    
    % Calculate curvature
    [phi_x,phi_y] = gradient(phi);
    s = sqrt(phi_x.^2 + phi_y.^2);
    Nx = phi_x./(s + smallNumber); % add a small positive number to avoid division by zero
    Ny = phi_y./(s + smallNumber);
    curvature = div(Nx, Ny);
    
    distRegTerm = 4*del2(phi) - curvature;
    areaTerm = -diracPhi_inner + diracPhi_outer;

    % Calculate region energy
    inter_Hphi = Heaviside(-varepsilon - phi, eta);
    C1 = self_binaryfit(Img - lambda*sigma_map_x,inter_Hphi);
    mid_Hphi = Heaviside(varepsilon^2 - phi.^2, eta);
    C2 = self_binaryfit(Img - lambda*sigma_map_x,mid_Hphi);    
    outer_Hphi = Heaviside(-varepsilon + phi, eta);
    C3 = self_binaryfit(Img - lambda*sigma_map_x,outer_Hphi);
    regionTerm = diracPhi_inner.*(Img-C1).^2 + 2*phi.*(Img-C2).^2.*diracPhi_ringregion - diracPhi_outer.*(Img-C3).^2;
    
    % To get the mean gray value and update lambda
    numerator_img = (Img-C1).*inter_Hphi + (Img-C2).*mid_Hphi + (Img-C3).*outer_Hphi;
    denominator_img = (inter_Hphi + mid_Hphi + outer_Hphi).*sigma_map_x;
    lambda = sum(numerator_img(:))/(sum(denominator_img(:)) + smallNumber);
    
    phi = phi + timestep*(edgeTerm + alpha*regionTerm + beta*areaTerm + gamma*distRegTerm);  
    
    % update the standard deviation map
    inner_binary_mask = phi < -varepsilon;
    ring_binary_mask = phi < varepsilon & phi > -varepsilon;
    outer_binary_mask = phi > varepsilon;
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

end

function f = div(nx,ny)                  
[nxx,~] = gradient(nx);  
[~,nyy] = gradient(ny);
f = nxx + nyy;

function H = Heaviside(phi,eta) 
H = 0.5*(1 + (2/pi)*atan(phi./eta));

function Delta_h = Delta_inner(margin_a, phi, eta)
move_phi = -phi-margin_a;
Delta_h = (eta/pi)./(eta^2+ move_phi.^2);

function Delta_h = Delta_ringregion(margin_a, phi, eta)
move_phi = margin_a.^2 - phi.^2;
Delta_h = (eta/pi)./(eta^2+ move_phi.^2);

function Delta_h = Delta_outer(margin_a, phi, eta)
move_phi = phi-margin_a;
Delta_h = (eta/pi)./(eta^2+ move_phi.^2);

function g = NeumannBoundCond(f)
% Make a function satisfy Neumann boundary condition
[nrow,ncol] = size(f);
g = f;
g([1 nrow],[1 ncol]) = g([3 nrow-2],[3 ncol-2]);  
g([1 nrow],2:end-1) = g([3 nrow-2],2:end-1);          
g(2:end-1,[1 ncol]) = g(2:end-1,[3 ncol-2]);  

function C = self_binaryfit(Img,Hphi) 
a = Hphi.*Img;
numer_1=sum(a(:)); 
denom_1=sum(Hphi(:));
C = numer_1/denom_1;








