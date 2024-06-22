function [CNOT_Naive,CNOT_Best,MeanReduction,MaxReduction,nrange]=Heuristics_1_CNOTs_Edge_Density(p,iterMax)
%--------------------------------------------------------------------------
%Created by Eva Takou
%Last modified: June 22, 2024
%--------------------------------------------------------------------------
%
%Script to find the optimal CNOT counts using the Heuristics 1 optimizer
%for different edge probabilities.
%
%Inputs:      p: edge probability for each graph
%       iterMax: # of samples per np
%Output: CNOT_Naive: CNOT counts obtained from Naive method
%        CNOT_Best: CNOT counts obtained from Heuristics #1
%        MeanReduction: Mean reduction % across np
%        MeanReduction: Max reduction % across np
%        nrange: range of np values

close all;

nmin = 5;               %Min # of photons in the graph
nmax = 20;              %Max # of photons in the graph
nrange = nmin:1:nmax;

Store_Graphs   = false;
Store_Gates    = false;
Verify_Circuit = false;

parfor n=nmin:nmax

    for k=1:iterMax

        Adj  = full(create_ER_Graph(n,p));
        temp = Tableau_Class(Adj,'Adjacency');

        %-------------- Naive ---------------------------------------------
        BackSubsOption = false;
        return_cond    = true;

        temp = temp.Generation_Circuit(1:n,Store_Graphs,Store_Gates,BackSubsOption,Verify_Circuit,return_cond);
        temp = temp.Count_emitter_CNOTs;
        CNOT_Naive(n,k) = temp.Emitter_CNOT_count;

        %-------------- 1st version of Heuristics #1 ---------------------
        BackSubsOption = false;
        return_cond    = false;
        
        temp = temp.Generation_Circuit_Heu1(1:n,Store_Graphs,Store_Gates,BackSubsOption,Verify_Circuit,return_cond);
        temp = temp.Count_emitter_CNOTs;
        CNOT_Heu1_V1(n,k) = temp.Emitter_CNOT_count;

        %-------------- 2nd version of Heuristics #1 ---------------------
        BackSubsOption = false;
        return_cond    = true;
        
        temp = temp.Generation_Circuit_Heu1(1:n,Store_Graphs,Store_Gates,BackSubsOption,Verify_Circuit,return_cond);
        temp = temp.Count_emitter_CNOTs;
        CNOT_Heu1_V2(n,k) = temp.Emitter_CNOT_count;        

        %-------------- 3rd version of Heuristics #1 ---------------------
        BackSubsOption = true;
        return_cond    = false;
        
        temp = temp.Generation_Circuit_Heu1(1:n,Store_Graphs,Store_Gates,BackSubsOption,Verify_Circuit,return_cond);
        temp = temp.Count_emitter_CNOTs;
        CNOT_Heu1_V3(n,k) = temp.Emitter_CNOT_count;        
        
    end

end

CNOT_Best = zeros(nmax,iterMax);

for n=nmin:nmax
    
   for k=1:iterMax
       
      CNOT_Best(n,k) = min([CNOT_Heu1_V1(n,k),CNOT_Heu1_V2(n,k),CNOT_Heu1_V3(n,k)]);
       
   end
    
end

Mean_Naive     = mean(CNOT_Naive(nmin:nmax,:),2);
Mean_CNOT_Best = mean(CNOT_Best(nmin:nmax,:),2);

for n=nmin:nmax
    
    MeanReduction(n) = mean( (CNOT_Naive(n,:)-CNOT_Best(n,:))./CNOT_Naive(n,:)*100,"omitnan");
    MaxReduction(n)  = max( (CNOT_Naive(n,:)-CNOT_Best(n,:))./CNOT_Naive(n,:)*100 );
    
end

%--------- Plot the results -----------------------------------------------

subplot(2,1,1)
plot(nrange,Mean_Naive,'color','k','marker','o','linewidth',2)
hold on
plot(nrange,Mean_CNOT_Best,'color',[0.8500 0.3250 0.0980],'marker','p','linewidth',2)

set(gca,'fontsize',20,'fontname','Microsoft Sans Serif')
set(gcf,'color','w')

xlabel('$n_p$','interpreter','latex')
ylabel('Averages')
title(['$p=$',num2str(p),', $\#$ of samples:',num2str(iterMax)],'interpreter','latex')
legend('Naive','Heuristics $\#1$','interpreter','latex','location','best',...
    'color','none','edgecolor','none')

subplot(2,1,2)
plot(nrange,MeanReduction(nrange),'color','k','marker','o','markerfacecolor','r','markeredgecolor','k','linewidth',2)
hold on
plot(nrange,MaxReduction(nrange),'color','k','marker','o','markerfacecolor','b','markeredgecolor','k','linewidth',2)

set(gca,'fontsize',20,'fontname','Microsoft Sans Serif')
set(gcf,'color','w')

xlabel('$n_p$','interpreter','latex')
ylabel('Reduction $\%$','interpreter','latex')
title(['$p=$',num2str(p),', $\#$ of samples:',num2str(iterMax)],'interpreter','latex')
legend('Mean','Max','location','best',...
    'color','none','edgecolor','none')

end