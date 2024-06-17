function plot_slice_np(np)

close all;

load('500_graphs_per_np.mat')


[~,indx_sort]=sort(CNOT_Naive(:,np));


bar(CNOT_Naive(indx_sort,np),'k')


hold on
bar(CNOT_Best(indx_sort,np),'facecolor',[0.8500 0.3250 0.0980])
legend('Naive','Heuristics $\#$1','interpreter','latex','color',...
    'none','edgecolor','none','location','best')
xlabel('Graph index')
ylabel('$\#$ of emitter CNOTs','interpreter','latex')
set(gcf,'color','w')
set(gca,'fontsize',22)
ylim([min(CNOT_Best(indx_sort,np))-1,...
      max(CNOT_Naive(indx_sort,np))+10])

title(['$n_p=$',num2str(np)],'interpreter','latex')  


end