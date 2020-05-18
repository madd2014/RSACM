% Evolution function
function phi = Ring_Seg_EVOL(margin_a, g,std_Img, phi0, lambda1, lambda2, lambda3, lambda4, lambda5, timestep, epsilon, numIter)

phi = phi0;
[vx, vy] = gradient(g);
for k = 1:numIter
    phi = NeumannBoundCond(phi);
    
    [phi_x,phi_y] = gradient(phi);
    s = sqrt(phi_x.^2 + phi_y.^2);
    smallNumber = 1e-10;  
    Nx = phi_x./(s + smallNumber); 
    Ny = phi_y./(s + smallNumber);
    curvature = div(Nx,Ny);
        
    diracPhi1 = Delta1(margin_a,phi,epsilon);
    diracPhi2 = Delta2(margin_a,phi,epsilon);
    diracPhi3 = Delta3(margin_a,phi,epsilon);

    edgeTerm1 = diracPhi1.*(vx.*Nx + vy.*Ny) + diracPhi1.*g.*curvature;         % dirac*div(g*d_phi/abs(d_phi)),div (u A ) =u div A+ A grad u
    edgeTerm2 = diracPhi2.*(vx.*Nx + vy.*Ny) + diracPhi2.*g.*curvature; 
    
    distRegTerm = 4*del2(phi) - curvature;
    areaTerm1 = diracPhi1.*g;

    inter_Hphi = Heaviside(-margin_a - phi, epsilon);
    C1 = self_binaryfit(std_Img,inter_Hphi);
    mid_Hphi = Heaviside(margin_a^2 - phi.^2, epsilon);
    C2 = self_binaryfit(std_Img,mid_Hphi);    
    outer_Hphi = Heaviside(-margin_a + phi, epsilon);
    C3 = self_binaryfit(std_Img,outer_Hphi);
    
    my_energy = -(diracPhi2.*(std_Img-C1).^2 - diracPhi1.*(std_Img-C3).^2 - 2*(std_Img-C2).^2.*diracPhi3.*phi);
    phi = phi + timestep*(lambda1*edgeTerm1 + lambda2*edgeTerm2 + lambda3*distRegTerm + lambda4*areaTerm1 + lambda5*my_energy);  
end

function f = div(nx,ny)                    % ��ȡɢ��
[nxx,~] = gradient(nx);  
[~,nyy] = gradient(ny);
f = nxx + nyy;

function H = Heaviside(phi,epsilon) 
H = 0.5*(1 + (2/pi)*atan(phi./epsilon));

function Delta_h = Delta1(margin_a, phi, epsilon)
move_phi = -phi-margin_a;
Delta_h = (epsilon/pi)./(epsilon^2+ move_phi.^2);

function Delta_h = Delta2(margin_a, phi, epsilon)
move_phi = phi-margin_a;
Delta_h = (epsilon/pi)./(epsilon^2+ move_phi.^2);

function Delta_h = Delta3(margin_a, phi, epsilon)
move_phi = margin_a.^2 - phi.^2;
Delta_h = (epsilon/pi)./(epsilon^2+ move_phi.^2);

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



