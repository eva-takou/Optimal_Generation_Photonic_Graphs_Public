%% Alternative optimal ordering of RGS (requires 2 emitters)
% Find the emitter CNOTs as we increase the size of the graph
clear;
clc;
close all;


nmin = 3;    %min # of core nodes of un-encoded RGS
nmax = 200;  %max # of core nodes of un-encoded RGS

Store_Graphs    = false;
Verify_Circuit  = false;
Store_Gates     = false;
BackSubsOption  = false;
return_cond     = true;


tic
parfor n=nmin:nmax

    Adj=(create_RGS_opt_ordering(n)); %Optimal ordering of RGS (K_n^n)
    
    temp=Tableau_Class(Adj,'Adjacency');
    
    temp       = temp.Generation_Circuit_Heu1(1:2*n,Store_Graphs,Store_Gates,BackSubsOption,Verify_Circuit,return_cond,false);
    temp       = temp.Count_emitter_CNOTs;
    CNOT_H1(n) = temp.Emitter_CNOT_count;
    
end
T=toc;
%% Plot the results
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
%% Natural ordering (also requires 2 emitters)

clear;
clc;
close all;


nmin=3;
nmax=200;

Store_Graphs=false;
Verify_Circuit=false;
Store_Gates=false;
BackSubsOption=false;
return_cond=true;

%Test if the un-encoded RGS has smaller # of CNOTs if we apply the Heu2 opt
tic
parfor n=nmin:nmax

    %Adj=full(create_RGS_natural_ordering(n));
    
    Adj=full(create_RGS_opt_ordering(n));
    
    temp=Tableau_Class(Adj,'Adjacency');
    
    
    temp       = temp.Generation_Circuit_Heu1(1:2*n,Store_Graphs,Store_Gates,BackSubsOption,Verify_Circuit,return_cond,false);
    temp       = temp.Count_emitter_CNOTs;
    CNOT_H1(n) = temp.Emitter_CNOT_count;
    
    
    
end
T=toc;

plot(nmin:nmax,CNOT_H1(nmin:nmax),'linewidth',2)
xlabel('$n$','interpreter','latex')
ylabel('$\#$ of emitter CNOTs','interpreter','latex')
set(gca,'fontsize',24,'fontname','Microsoft Sans Serif')
set(gcf,'color','w')
title(['T=',num2str(T),'~(s)'],'interpreter','latex')
hold on
plot(nmin:nmax,[nmin:nmax]-2,'linewidth',2,'linestyle','--')
legend('Natural ordering','$y=n-2$','interpreter','latex','location','best',...
    'color','none','edgecolor','none')
