clear;
clc;
close all;


%Plot the l and e index of the RGS orbit and verify with analytical
%expressions

nmin=3;
nmax=7;

for k=nmin:nmax
    
    Adj = create_RGS(k,1:2*k,k,'Adjacency');
    Adj = double(Adj);
    l_numer(k-nmin+1)=count_l_Bouchet(Adj);
    l_anal(k-nmin+1) = (1+3^(k-1)*(3+2*k))/2;
    
    e_numer(k-nmin+1)=count_e_Bouchet(Adj);
    e_anal(k-nmin+1)=6^(k-1)*(3+2*k)+2^(k-1);
    
end





figure(1)
subplot(2,1,1)
plot(nmin:nmax,l_numer,'linewidth',2)
hold on
plot(nmin:nmax,l_anal,'--','linewidth',2,'color','k','marker','*')
legend('Bouchet Alg.','Analytical','color','none',...
    'edgecolor','none','location','best')
set(gcf,'color','w')
set(gca,'fontsize',22,'fontname','Microsoft Sans Serif')
xlabel('$n$','interpreter','latex')
ylabel('$l(K_n^n)$','interpreter','latex')
set(gca,'yscale','log')
xlim([nmin,nmax])

subplot(2,1,2)
plot(nmin:nmax,e_numer,'linewidth',2)
hold on
plot(nmin:nmax,e_anal,'--','linewidth',2,'color','k','marker','*')
legend('Bouchet Alg.','Analytical','color','none',...
    'edgecolor','none','location','best')
set(gcf,'color','w')
set(gca,'fontsize',22,'fontname','Microsoft Sans Serif')
xlabel('$n$','interpreter','latex')
ylabel('$e(K_n^n)$','interpreter','latex')
set(gca,'yscale','log')
xlim([nmin,nmax])

