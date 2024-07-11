function [Adj,CNOT_Naive,CNOT_Best,MeanReduction,MaxReduction]=CNOT_Scaling_Naive_vs_Heuristics1_specified_Adj
close all

load('optimized_data_heu1.mat','Adj')

nstep   = 2;
iterMax = 500;
nmin    = 6;
nmax    = 50;
clearvars -except Adj nmax nmin nstep iterMax

BackSubsOption  = false;
return_cond     = true;
Store_Graphs    = false;
Store_Gates     = false;
Verify_Circuit  = false;

parfor iter=1:iterMax
    
    for n=nmin:nstep:nmax
        
        temp=Tableau_Class(Adj{iter,n},'Adjacency');
        temp=temp.Generation_Circuit(1:n,Store_Graphs,Store_Gates,BackSubsOption,Verify_Circuit,return_cond) ;
        temp=temp.Count_emitter_CNOTs;
        CNOT_Naive(iter,n) = temp.Emitter_CNOT_count;
        ne(iter,n)=temp.Emitters;
        
        temp=temp.Generation_Circuit_Heu1(1:n,Store_Graphs,Store_Gates,false,Verify_Circuit,true)
        temp=temp.Count_emitter_CNOTs;
        CNOT_Heu1(iter,n) = temp.Emitter_CNOT_count;
        
        temp=temp.Generation_Circuit_Heu1(1:n,Store_Graphs,Store_Gates,true,Verify_Circuit,false)
        temp=temp.Count_emitter_CNOTs;
        CNOT_Heu1_Alt(iter,n) = temp.Emitter_CNOT_count;
        
        temp=temp.Generation_Circuit_Heu1(1:n,Store_Graphs,Store_Gates,false,Verify_Circuit,false)
        temp=temp.Count_emitter_CNOTs;
        CNOT_Heu1_Alt_2(iter,n) = temp.Emitter_CNOT_count;
        
    end
    
end


CNOT_Best = zeros(iterMax,nmax);

for iter=1:iterMax
    
    for n=nmin:nstep:nmax
        
        CNOT_Best(iter,n) = min([CNOT_Heu1(iter,n),CNOT_Heu1_Alt(iter,n),...
                                 CNOT_Heu1_Alt_2(iter,n),CNOT_Naive(iter,n)]);
    
    end
    
end

MeanReduction = zeros(1,nmax);
MaxReduction  = zeros(1,nmax);

for n=nmin:nstep:nmax
   
    MeanReduction(n) = mean( (CNOT_Naive(:,n)-CNOT_Best(:,n))./CNOT_Naive(:,n)*100,"omitnan" );
    MaxReduction(n)  = max( (CNOT_Naive(:,n)-CNOT_Best(:,n))./CNOT_Naive(:,n)*100 );
    
end


%------------------------ Get the best count -----------------------------

np = nmin:nstep:nmax;
y  = np.^2./log2(np);

plot(np,mean(CNOT_Naive(:,np)),'marker','o','linewidth',2,'color','k')
hold on
plot(np,mean(CNOT_Best(:,np)),'marker','o','linewidth',2)
hold on
plot(np,mean(ne(:,np)),'marker','o','linewidth',2,'color',[0.4660 0.6740 0.1880])

hold on
plot(np,np.^2,'color','k','linewidth',1.5)

hold on
plot(np,y,'color','k','linestyle','-.','linewidth',1.5)

set(gca,'fontsize',20,'fontname','Microsoft Sans Serif')
set(gcf,'color','w')
xlabel('$n_p$','interpreter','latex')
ylabel('Averages')
legend('Emitter CNOTs (Naive)','Emitter CNOTs (Heuristics $\#1$)','$\bar{n}_e$','$n_p^2$','$n_p^2/\log2(n_p)$','location','best','interpreter','latex',...
    'color','none','location','best','edgecolor','none')

xlim([nmin,nmax])

figure(2)
plot(np,MeanReduction(np),'marker','o','linewidth',2,'color','k',...
    'MarkerSize',10,'MarkerFaceColor','red')
hold on
plot(np,MaxReduction(np),'marker','s','linewidth',2,'color','k',...
    'MarkerSize',10,'MarkerFaceColor','blue')

set(gcf,'color','w')
set(gca,'fontsize',20,'fontname','Microsoft Sans Serif')

legend('Mean','Max','location','best','interpreter','latex',...
    'color','none','location','best','edgecolor','none')
xlabel('$n_p$','interpreter','latex')
ylabel('Reduction $\%$','interpreter','latex')
xlim([nmin,nmax])

end