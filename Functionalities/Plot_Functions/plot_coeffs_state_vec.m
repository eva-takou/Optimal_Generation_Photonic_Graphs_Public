function plot_coeffs_state_vec(psi,fignum)

%NQ=log2(length(psi)); %Number of qubits

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