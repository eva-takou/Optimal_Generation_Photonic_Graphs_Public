%--------------------------------------------------------------------------
%Created by Eva Takou
%Last modified: June 21, 2024
%--------------------------------------------------------------------------

close all

load('optimized_data_heu1.mat')


clearvars -except CNOT_Best CNOT_Naive

INDX=18;


[~,order]=sort(CNOT_Naive(:,INDX));

bar(CNOT_Naive(order,INDX),'k')
hold on
bar(CNOT_Best(order,INDX))


clearvars -except order INDX CNOT_Naive


load('opt_data_heu_2.mat')
hold on
bar(CNOT_Best(order,INDX),'c')

xlabel('Graph index')
ylabel('$\#$ of emitter CNOTs','interpreter','latex')
set(gca,'fontsize',25,'fontname','microsoft sans serif')
set(gcf,'color','w')

ylim([min(CNOT_Best(order,INDX))-3,max(CNOT_Naive(order,INDX))+2])

legend('Naive','Heuristics $\#1$','Heuristics $\#2$','interpreter','latex','color','none',...
    'edgecolor','none','location','best')

title(['$n_p=$',num2str(INDX)],'interpreter','latex')