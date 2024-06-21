function [ne,CNOTs,CNOTs_Opt]=compare_naive_w_brute_force_specified_Adj(Adj,n,tryLC,prune)
%--------------------------------------------------------------------------
%Created by Eva Takou
%Last modified: June 21, 2024
%--------------------------------------------------------------------------
%Script to compare emitter-emitter CNOTs between Naive and brute-force
%optimizer.
%
%Input: Adj: Cell array of nxn Adjacency matrices
%         n: # of nodes for each graph
%     tryLC: true or false to enable LCs in the bruteforce optimization
%     prune: true or false to prune or not tableaux generated per
%            optimization step of the bruteforce method
%
%Output: ne: # of emitters per graphs
%        CNOTs: emitter-emitter CNOT counts obtained by the Naive method
%        CNOTs_Opt: emitter-emitter CNOT counts obtained by the bruteforce
%                   method
%
%The np=7 data of the paper have prune false.
%The np=8 data of the paper have prune true (and Lmax=30 
%truncation per optimization level of the bruteforce method).

close all;

LC_Rounds      = 1;     %# of LC rounds to inspect in bruteforce method
Store_Graphs   = false; %Do not store graph evolution
Store_Gates    = false; %Do not store gates of circuit
Verify_Circuit = false; %Do not verify the circuit
LCsTop         = false; %Do not enable LCs early in the beginning (after consumption of last emitter photon)
iterMax        = length(Adj);

tic

parfor iter=1:iterMax

    %Naive Optimizer
    temp     = Tableau_Class(full(Adj{iter}),'Adjacency');
    temp     = temp.Get_Emitters(1:n);
    ne(iter) = temp.Emitters;

    BackSubsOption = false;
    temp           = temp.Generation_Circuit(1:n,Store_Graphs,Store_Gates,BackSubsOption,Verify_Circuit,true);
    temp           = temp.Count_emitter_CNOTs;
    CNOTs(iter)    = temp.Emitter_CNOT_count;
    
    return_cond     = false; %true;
    BackSubsOption  = true;
    temp            = temp.Optimize_Generation_Circuit(1:n,Store_Graphs,Store_Gates,prune,tryLC,LC_Rounds,Verify_Circuit,LCsTop,BackSubsOption,return_cond) ;
    CNOTs_Opt(iter) = temp.Emitter_CNOT_count; 
    
    CNOTs_Opt(iter) = min([CNOTs(iter),CNOTs_Opt(iter)]);
    
end

toc


[~,indxSort] = sort(CNOTs);
CNOTs        = CNOTs(indxSort);
CNOTs_Opt    = CNOTs_Opt(indxSort);
Reduction    = (CNOTs-CNOTs_Opt)./CNOTs*100;

%--------------- Plot the results -----------------------------------------
subplot(2,1,1) %CNOTs

bar(CNOTs,'facecolor','k')
hold on
bar(CNOTs_Opt,0.7,'facecolor',[0.9290 0.6940 0.1250])

ylabel({'$\#$ of emitter','CNOTs'},'interpreter','latex')
xlabel('Graph index')

set(gca,'fontsize',18,'fontname','Microsoft Sans Serif')
legend('Naive','Brute-force',...
    'interpreter','latex','color','none','edgecolor','none','location','best')

title(['$n_p=$',num2str(n)],'interpreter','latex')

subplot(2,1,2) %Percentage reduction: (CNOTs-CNOTs_Opt)/CNOTs x 100
bar(Reduction)
ylabel('Reduction $\%$','interpreter','latex')
xlabel('Graph index')

set(gcf,'color','w')
hold on
line([1,iterMax],[max(Reduction),max(Reduction)],...
    'linestyle','--')

set(gca,'fontsize',18,'fontname','Microsoft Sans Serif')
title(['Average %=',num2str(mean(Reduction))])
ylim([0,5+max(Reduction)])

end