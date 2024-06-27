function [CNOT_Best,MeanReduction,MaxReduction]=CNOT_Scaling_Naive_vs_Heuristics2_Specified_Adj(iterMax,minK,maxK)
%--------------------------------------------------------------------------
%Created by Eva Takou
%Last modified: June 27, 2024
%--------------------------------------------------------------------------
%
%Script to compare the CNOT counts obtained by the Naive and Heuristics #2
%optimizer for various graph sizes.
%
%Input: iterMax: # of Adjacency matrices to inspect (here up to 500)
%       minK: index from 1-8 (to start optimization in range np=[6,40])
%       maxK: index from 1-8 (to end optimization in range np=[6,40])
%
%The size of photonic graphs we explore has np=[6,8,10,12,18,26,30,40]
%If we have minK = 2 and maxK=4, then we get results for np=8,10,12.
%
%Output: CNOT_Best: Min emitter CNOT counts out of 3 variants of Heuristics
%                   #2
%       MeanReduction: Mean CNOT reduction %
%       MaxReduction:  Max CNOT reduction %
%
%The optimization of the paper has emitter_cutoff=5 and future_cutoff=2.

close all;
load('500_graphs_per_np.mat','Adj')        %Fixed sampling of graphs
load('500_graphs_per_np.mat','CNOT_Naive') %Obtained from Naive Optimizer
load('500_graphs_per_np.mat','CNOT_Best')  %Obtained from Heuristics #1 Optimizer


CNOT_Best1=CNOT_Best;
clearvars -except Adj iterMax minK maxK CNOT_Naive CNOT_Best1

Store_Graphs    = false;
Store_Gates     = false;
Verify_Circuit  = false;
EXTRA_OPT_LEVEL = true;
emitter_cutoff0 = 5;    
future_step     = 2;    
recurse_further = true;
nrange          = [6,8,10,12,18,26,30,40];

for iter=1:iterMax
    
    for k=minK:maxK %nmin:nstep:nmax
        
        n           = nrange(k);
        temp        = Tableau_Class(Adj{iter,n},'Adjacency');
        BackSubs    = false;
        return_cond = false;
        
        if k<=5
                  
            temp=temp.Generation_Circuit_Heu2(1:n,Store_Graphs,Store_Gates,BackSubs,Verify_Circuit,...
                                          EXTRA_OPT_LEVEL,return_cond,...
                                          emitter_cutoff0,future_step,recurse_further);
                                      
        else
            
            temp=temp.Generation_Circuit_Heu2(1:n,Store_Graphs,Store_Gates,BackSubs,Verify_Circuit,...
                                          EXTRA_OPT_LEVEL,return_cond,...
                                          emitter_cutoff0,future_step,recurse_further,false);
            
        end
        
        temp                       = temp.Count_emitter_CNOTs;
        CNOT_Heu2_Alt_2_V1(iter,k) = temp.Emitter_CNOT_count;

        %------------------------------------------------------------------
        BackSubs    = true;
        return_cond = false;
        
        if k<=5
                                          
            temp=temp.Generation_Circuit_Heu2(1:n,Store_Graphs,Store_Gates,BackSubs,Verify_Circuit,EXTRA_OPT_LEVEL,return_cond,...
                                              emitter_cutoff0,future_step,recurse_further);
                                      
        else
            
            temp=temp.Generation_Circuit_Heu2(1:n,Store_Graphs,Store_Gates,BackSubs,Verify_Circuit,EXTRA_OPT_LEVEL,return_cond,...
                                              emitter_cutoff0,future_step,recurse_further,false);
            
        end
                                      
        temp                       = temp.Count_emitter_CNOTs;
        CNOT_Heu2_Alt_2_V2(iter,k) = temp.Emitter_CNOT_count;
        
        %------------------------------------------------------------------
        BackSubs    = false;
        return_cond = true;
        
        if k<=5
        
            temp=temp.Generation_Circuit_Heu2(1:n,Store_Graphs,Store_Gates,BackSubs,Verify_Circuit,EXTRA_OPT_LEVEL,return_cond,...
                                              emitter_cutoff0,future_step,recurse_further);
                                      
        else %Turn-off search for disconnected components (only allow weight 2 stab search)
            
            temp=temp.Generation_Circuit_Heu2(1:n,Store_Graphs,Store_Gates,BackSubs,Verify_Circuit,EXTRA_OPT_LEVEL,return_cond,...
                                              emitter_cutoff0,future_step,recurse_further,false);
            
        end
        
        temp                       = temp.Count_emitter_CNOTs;
        CNOT_Heu2_Alt_2_V3(iter,k) = temp.Emitter_CNOT_count;
        
    end
    
end

CNOT_Heu2_Alt_2_temp                      = zeros(iterMax,max(nrange(minK:maxK)));
CNOT_Heu2_Alt_2_temp(:,nrange(minK:maxK)) = CNOT_Heu2_Alt_2_V2(:,minK:maxK);
CNOT_Heu2_Alt_2_V2                        = CNOT_Heu2_Alt_2_temp;

CNOT_Heu2_Alt_2_temp                      = zeros(iterMax,max(nrange(minK:maxK)));
CNOT_Heu2_Alt_2_temp(:,nrange(minK:maxK)) = CNOT_Heu2_Alt_2_V3(:,minK:maxK);
CNOT_Heu2_Alt_2_V3                        = CNOT_Heu2_Alt_2_temp;

CNOT_Heu2_Alt_2_temp                      = zeros(iterMax,max(nrange(minK:maxK)));
CNOT_Heu2_Alt_2_temp(:,nrange(minK:maxK)) = CNOT_Heu2_Alt_2_V1(:,minK:maxK);
CNOT_Heu2_Alt_2_V1                        = CNOT_Heu2_Alt_2_temp;


CNOT_Naive_Trunc=CNOT_Naive(1:iterMax,1:max(nrange(minK:maxK)));
CNOT_Best1_Trunc=CNOT_Best1(1:iterMax,1:max(nrange(minK:maxK)));

for iter=1:iterMax
    
    for k=minK:maxK   
        n = nrange(k);
        
        CNOT_Best(iter,n) = min([CNOT_Heu2_Alt_2_V1(iter,n),CNOT_Heu2_Alt_2_V2(iter,n),...
            CNOT_Heu2_Alt_2_V3(iter,n),CNOT_Naive(iter,n)]);
        
    end
    
end

for k=minK:maxK 
   
    n=nrange(k);
    MeanReduction(n)  = mean( (CNOT_Naive_Trunc(:,n)-CNOT_Best(:,n))./CNOT_Naive_Trunc(:,n)*100,"omitnan" );
    MaxReduction(n)   = max( (CNOT_Naive_Trunc(:,n)-CNOT_Best(:,n))./CNOT_Naive_Trunc(:,n)*100 );
    
    MeanReduction1(n) = mean( (CNOT_Naive_Trunc(:,n)-CNOT_Best1_Trunc(:,n))./CNOT_Naive_Trunc(:,n)*100,"omitnan" );
    MaxReduction1(n)  = max( (CNOT_Naive_Trunc(:,n)-CNOT_Best1_Trunc(:,n))./CNOT_Naive_Trunc(:,n)*100 );
    
end

%------------------------ Get the best count -----------------------------

np = nrange(minK:maxK);
y  = np.^2./log2(np);

plot(np,mean(CNOT_Naive_Trunc(:,np)),'marker','o','linewidth',2,'color','k')
hold on
plot(np,mean(CNOT_Best1_Trunc(:,np)),'marker','o','linewidth',2)
hold on
plot(np,mean(CNOT_Best(:,np)),'marker','o','linewidth',2,'color','c')
hold on

hold on
plot(np,y,'color','k','linestyle','-.','linewidth',1.5)

set(gca,'fontsize',20,'fontname','Microsoft Sans Serif')
set(gcf,'color','w')
xlabel('$n_p$','interpreter','latex')
ylabel('Averages')
legend('Emitter CNOTs (Naive)','Heu1','Emitter CNOTs (Heuristics $\#2$)',...
    '$n_p^2/\log2(n_p)$','location','best','interpreter','latex',...
    'color','none','location','best','edgecolor','none')



%xlim([min(np),max(np)])

figure(2)
plot(np,MeanReduction(np),'marker','o','linewidth',2,'color','k',...
    'MarkerSize',10,'MarkerFaceColor','red')
hold on
plot(np,MaxReduction(np),'marker','s','linewidth',2,'color','k',...
    'MarkerSize',10,'MarkerFaceColor','blue')

hold on
plot(np,MeanReduction1(np),'marker','o','linewidth',2,'color','k',...
    'MarkerSize',10,'MarkerFaceColor','red','linestyle','--')
hold on
plot(np,MaxReduction1(np),'marker','s','linewidth',2,'color','k',...
    'MarkerSize',10,'MarkerFaceColor','blue','linestyle','--')
set(gcf,'color','w')
set(gca,'fontsize',20,'fontname','Microsoft Sans Serif')

legend('Mean','Max','location','best','interpreter','latex',...
    'color','none','location','best','edgecolor','none')
xlabel('$n_p$','interpreter','latex')
ylabel('Reduction $\%$','interpreter','latex')
%xlim([min(np),max(np)])

end