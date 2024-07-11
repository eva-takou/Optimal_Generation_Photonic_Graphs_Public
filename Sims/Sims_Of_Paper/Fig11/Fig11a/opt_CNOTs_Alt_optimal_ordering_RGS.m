function opt_CNOTs_Alt_optimal_ordering_RGS
%--------------------------------------------------------------------------
%Created by Eva Takou
%Last modified: June 17, 2024
%--------------------------------------------------------------------------
%
%Find the optimal CNOT counts for un-encoded RGS with optimal ordering that
%requires 2 emitters only. We use the Heuristics #1 Optimizer.


clear; clc; close all;

nmin = 3;    %min # of core nodes of un-encoded RGS
nmax = 200;  %max # of core nodes of un-encoded RGS

Store_Graphs    = false;
Verify_Circuit  = false;
Store_Gates     = false;
BackSubsOption  = false;
return_cond     = true;


parfor n=nmin:nmax
    
    Adj{n}=(create_RGS_opt_ordering(n)); %Optimal ordering of RGS (K_n^n)
    
end

tic
parfor n=nmin:nmax

    
    temp=Tableau_Class(Adj{n},'Adjacency');
    
    
    temp       = temp.Generation_Circuit_Heu1(1:2*n,Store_Graphs,Store_Gates,...
                                              BackSubsOption,Verify_Circuit,...
                                              return_cond,false);
                                      
    temp       = temp.Count_emitter_CNOTs;
    CNOT_H1(n) = temp.Emitter_CNOT_count;
    
end
T=toc;
%---------- Plot the results ----------------------------------------------
close all
plot(nmin:nmax,CNOT_H1(nmin:nmax),'linewidth',2,'color',[0.8500 0.3250 0.0980])
xlabel('$n$','interpreter','latex')
ylabel('$\#$ of emitter CNOTs','interpreter','latex')
set(gca,'fontsize',24,'fontname','Microsoft Sans Serif')
set(gcf,'color','w')
title(['T=',num2str(T),'~(s)'],'interpreter','latex')
hold on
plot(nmin:nmax,[nmin:nmax]-2,'linewidth',2,'linestyle','--','color','k')
legend('Heuristics $\#1$','$y=n-2$','interpreter','latex','location','best',...
    'color','none','edgecolor','none')

figure(2)
Adj=double(create_RGS_opt_ordering(100));
plot(graph(Adj),'layout','circle','NodeColor','k','MarkerSize',5)



end