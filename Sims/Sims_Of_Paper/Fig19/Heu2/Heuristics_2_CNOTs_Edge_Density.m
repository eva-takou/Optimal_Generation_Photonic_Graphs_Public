function [CNOT_Naive,CNOT_Best,MeanReduction,MaxReduction,nrange,Adj_Store]=Heuristics_2_CNOTs_Edge_Density(p,iterMax)
%--------------------------------------------------------------------------
%Created by Eva Takou
%Last modified: June 23, 2024
%--------------------------------------------------------------------------
%
%Script to find the optimal CNOT counts using the Heuristics 2 optimizer
%for different edge probabilities.
%
%Inputs:      p: edge probability for each graph
%       iterMax: # of samples per np
%Output: CNOT_Naive: CNOT counts obtained from Naive method
%        CNOT_Best: CNOT counts obtained from Heuristics #2
%        MeanReduction: Mean reduction % across np
%        MeanReduction: Max reduction % across np
%        nrange: range of np values

close all;

nmin   = 6;               %Min # of photons in the graph
nstep  = 2;               %Stepsize for np
nmax   = 20;              %Max # of photons in the graph
nrange = nmin:nstep:nmax;


Store_Graphs    = false;
Store_Gates     = false;
Verify_Circuit  = false;
EXTRA_OPT_LEVEL = true;
emitter_cutoff0 = 4;       
future_step     = 2;       
recurse_further = false;   


parfor l=1:length(nrange) 

    n = nrange(l);
    
    for k=1:iterMax
        

        Adj  = full(create_ER_Graph(n,p));
        Adj_Store{l,k} = Adj;
        temp = Tableau_Class(Adj,'Adjacency');

        %------------ Naive -----------------------------------------------
        
        BackSubsOption = false;
        return_cond    = true;

        temp = temp.Generation_Circuit(1:n,Store_Graphs,Store_Gates,BackSubsOption,Verify_Circuit,return_cond);
        
        temp = temp.Count_emitter_CNOTs;
        CNOT_Naive(l,k) = temp.Emitter_CNOT_count;

        %------------ Heuristics # 2 --------------------------------------
        
        BackSubsOption = false;
        return_cond    = false;
        
        temp = temp.Generation_Circuit_Heu2(1:n,Store_Graphs,Store_Gates,BackSubsOption,Verify_Circuit,...
                                                              EXTRA_OPT_LEVEL,return_cond,...
                                                              emitter_cutoff0,future_step,recurse_further);
        temp              = temp.Count_emitter_CNOTs;
        CNOT_Heu2_V1(l,k) = temp.Emitter_CNOT_count;

        %------------ Heuristics # 2 --------------------------------------
        
        BackSubsOption = false;
        return_cond    = true;
        
        temp = temp.Generation_Circuit_Heu2(1:n,Store_Graphs,Store_Gates,BackSubsOption,Verify_Circuit,...
                                                              EXTRA_OPT_LEVEL,return_cond,...
                                                              emitter_cutoff0,future_step,recurse_further);
        temp              = temp.Count_emitter_CNOTs;
        CNOT_Heu2_V2(l,k) = temp.Emitter_CNOT_count;        

        %------------ Heuristics # 2 --------------------------------------
        BackSubsOption = true;
        return_cond    = false;
        
        temp = temp.Generation_Circuit_Heu2(1:n,Store_Graphs,Store_Gates,BackSubsOption,Verify_Circuit,...
                                                              EXTRA_OPT_LEVEL,return_cond,...
                                                              emitter_cutoff0,future_step,recurse_further);
        temp              = temp.Count_emitter_CNOTs;
        CNOT_Heu2_V3(l,k) = temp.Emitter_CNOT_count;        
        
    end

end

CNOT_Best=zeros(length(nrange),iterMax);

for l=1:length(nrange)
    
   for k=1:iterMax
       
      CNOT_Best(l,k) = min([CNOT_Heu2_V1(l,k),CNOT_Heu2_V2(l,k),CNOT_Heu2_V3(l,k)]);
       
   end
    
end

Mean_Naive     = mean(CNOT_Naive,2);
Mean_CNOT_Best = mean(CNOT_Best,2);


for l=1:length(nrange)
    
    MeanReduction(l) = mean( (CNOT_Naive(l,:)-CNOT_Best(l,:))./CNOT_Naive(l,:)*100,"omitnan");
    MaxReduction(l) = max( (CNOT_Naive(l,:)-CNOT_Best(l,:))./CNOT_Naive(l,:)*100 );
    
end

%--------- Plot the results -----------------------------------------------

subplot(2,1,1)
plot(nrange,Mean_Naive,'color','k','marker','o','linewidth',2)
hold on
plot(nrange,Mean_CNOT_Best,'color','c','marker','p','linewidth',2)

set(gca,'fontsize',22,'fontname','Microsoft Sans Serif')
set(gcf,'color','w')

xlabel('$n_p$','interpreter','latex')
ylabel('Averages')
title(['$p=$',num2str(p),', $\#$ of samples:',num2str(iterMax)],'interpreter','latex')
legend('$\#$ of emitter CNOTs (Naive)','$\#$ of emitter CNOTs (Heuristics $\#2$)','interpreter','latex','location','best',...
    'color','none','edgecolor','none')

set(gca,'ytick',[0:25:50])
xlim([min(nrange),max(nrange)])
subplot(2,1,2)
plot(nrange,MeanReduction,'color','k','marker','o','markerfacecolor','r','markeredgecolor','k','linewidth',2)
hold on
plot(nrange,MaxReduction,'color','k','marker','o','markerfacecolor','b','markeredgecolor','k','linewidth',2)

set(gca,'fontsize',22,'fontname','Microsoft Sans Serif')
set(gcf,'color','w')

xlabel('$n_p$','interpreter','latex')
ylabel('Reduction $\%$','interpreter','latex')
title(['$p=$',num2str(p),', $\#$ of samples:',num2str(iterMax)],'interpreter','latex')
legend('Mean','Max','location','best',...
    'color','none','edgecolor','none')
xlim([min(nrange),max(nrange)])
set(gca,'ytick',[0,20,40,60])
end