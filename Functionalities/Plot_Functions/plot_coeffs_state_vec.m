function plot_coeffs_state_vec(psi,fignum)
%--------------------------------------------------------------------------
%Created by Eva Takou
%Last modified: May 19, 2024
%--------------------------------------------------------------------------
%
%Function to make a bar plot of the real and imaginary values of the state
%vector coefficients.
%Input: psi: n-qubit state
%       fignum: number of figure to plot

figure(fignum)
subplot(2,1,1)
   
bar(real(psi))
    
ylabel('$\Re(c_j)$','interpreter','latex')
xlabel('coeff index')
set(gca,'fontsize',20,'fontname','Microsoft Sans Serif')

subplot(2,1,2)
   
bar(imag(psi))
ylabel('$\Im(c_j)$','interpreter','latex')
xlabel('coeff index')
set(gca,'fontsize',20,'fontname','Microsoft Sans Serif')

set(gcf,'color','w')

end