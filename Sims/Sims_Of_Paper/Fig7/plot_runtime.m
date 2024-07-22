function [Adj_Store,T_Naive,T_Heur_1_No_Back_Return_PA,...
    T_Heur_1_W_Back_No_Return_PA,...
    T_Heur_2_No_Back_Return_PA,...
    T_Heur_2_W_Back_No_Return_PA]=plot_runtime(nmin,nmax,iterMax,nstep)

%--------------------------------------------------------------------------
%Created by Eva Takou
%Last modified: June 17, 2024
%--------------------------------------------------------------------------
%
%
%Script to get the average runtime of Naive, Heuristics #1 & Heuristics #2
%Optimizers as a function of the graph size.
%
%Input: nmin: min # of graph nodes
%       nmax: max # of graph nodes
%    iterMax: # of samples per size of graph
%      nstep: step for size of graph nodes 
%Output: Adj_Store: Adjacency matrices of random generation
%          T_Naive: Mean time of Naive approach per graph size
%          T_Heur_1_No_Back_Return_PA: Mean time of Heuristics #1 with false
%          on Back-substitution and w/o exhausting all checks for free PA
%          T_Heur_1_W_Back_No_Return_PA: Mean time of Heuristics #1 with
%          true on Back-substitution and w/ exhausting all checks for free PA
%          T_Heur_1_No_Back_Return_PA: Mean time of Heuristics #2 with false
%          on Back-substitution and w/o exhausting all checks for free PA
%          T_Heur_1_W_Back_No_Return_PA: Mean time of Heuristics #2 with
%          true on Back-substitution and w/ exhausting all checks for free PA


warning('off') 
close all;

Store_Graphs   = false;
Store_Gates    = false;
Verify_Circuit = false;

nrange          = nmin:nstep:nmax;
emitter_cutoff0 = 3;
future_step     = 2;
recurse_further = true;

for l=1:length(nrange)
    
    n             = nrange(l);
    node_ordering = 1:n;
    

    
    for iter=1:iterMax

        Adj               = create_random_graph(n); 
        Adj_Store{iter,l} = Adj;

        temp    = Tableau_Class(Adj,'Adjacency');
        temp    = temp.Get_Emitters(1:n);
        ne_temp = temp.Emitters;

        BackSubsOption=false;
        tic
        temp=temp.Generation_Circuit(node_ordering,Store_Graphs,...
                Store_Gates,BackSubsOption,Verify_Circuit,true);
        T_Naive(iter,l)=toc;
        
        %--------- 2 variants of Heuristics 1 -----------------------------
        BackSubsOption=false;
        
        tic
        temp = temp.Generation_Circuit_Heu1(node_ordering,Store_Graphs,Store_Gates,...
                                BackSubsOption,Verify_Circuit,true);
        T_Heur_1_No_Back_Return_PA(iter,l)=toc;

        
        BackSubsOption=true;
        
        tic
        temp = temp.Generation_Circuit_Heu1(node_ordering,Store_Graphs,Store_Gates,...
                                BackSubsOption,Verify_Circuit,false);
        T_Heur_1_W_Back_No_Return_PA(iter,l)=toc;
        
        %--------- 2 variants of Heuristics 2 -----------------------------
        EXTRA_OPT_LEVEL=true;
        BackSubsOption=false;
        return_cond = true;
        

        tic
        temp = temp.Generation_Circuit_Heu2(node_ordering,Store_Graphs,Store_Gates,...
                                BackSubsOption,Verify_Circuit,EXTRA_OPT_LEVEL,return_cond,emitter_cutoff0,future_step,recurse_further);
        T_Heur_2_No_Back_Return_PA(iter,l)=toc;

        
        BackSubsOption=true;
        return_cond=false;
        
        tic
        temp = temp.Generation_Circuit_Heu2(node_ordering,Store_Graphs,Store_Gates,...
                                BackSubsOption,Verify_Circuit,EXTRA_OPT_LEVEL,return_cond,emitter_cutoff0,future_step,recurse_further);
        T_Heur_2_W_Back_No_Return_PA(iter,l)=toc;
        

    end
    

end

%------------------ Plots -------------------------------------------------

MS  = 8; %MarkerSize
LNW = 2; %Linewidth

hold on
yneg=mean(T_Naive,1)-min(T_Naive,[],1);
ypos=max(T_Naive,[],1)-mean(T_Naive,1);
h=errorbar(nrange,mean(T_Naive,1),yneg,ypos,'linewidth',LNW,...
    'marker','o','MarkerSize',MS,'color','k');



%-------------------------- Heu 1 -----------------------------------------

hold on
yneg=mean(T_Heur_1_No_Back_Return_PA,1)-min(T_Heur_1_No_Back_Return_PA,[],1);
ypos=max(T_Heur_1_No_Back_Return_PA,[],1)-mean(T_Heur_1_No_Back_Return_PA,1);
h=errorbar(nrange,mean(T_Heur_1_No_Back_Return_PA,1),yneg,ypos,'linewidth',LNW,...
    'marker','p','MarkerSize',MS);

h.Color=[0.8500 0.3250 0.0980];


%-------------------------- Heu 1 -----------------------------------------
hold on
yneg=mean(T_Heur_1_W_Back_No_Return_PA,1)-min(T_Heur_1_W_Back_No_Return_PA,[],1);
ypos=max(T_Heur_1_W_Back_No_Return_PA,[],1)-mean(T_Heur_1_W_Back_No_Return_PA,1);
h=errorbar(nrange,mean(T_Heur_1_W_Back_No_Return_PA,1),yneg,ypos,'linewidth',LNW,...
    'marker','p','MarkerSize',MS,'linestyle','-.');

h.Color=[0.8500 0.3250 0.0980];

%-------------------------- Heu 2 -----------------------------------------


yneg=mean(T_Heur_2_No_Back_Return_PA,1)-min(T_Heur_2_No_Back_Return_PA,[],1);
ypos=max(T_Heur_2_No_Back_Return_PA,[],1)-mean(T_Heur_2_No_Back_Return_PA,1);
hold on


h=errorbar(nrange,mean(T_Heur_2_No_Back_Return_PA,1),yneg,ypos,'linewidth',LNW,...
    'marker','s','MarkerSize',MS);
h.Color='c';
hold on
%-------------------------- Heu 2 -----------------------------------------


yneg=mean(T_Heur_2_W_Back_No_Return_PA,1)-min(T_Heur_2_W_Back_No_Return_PA,[],1);
ypos=max(T_Heur_2_W_Back_No_Return_PA,[],1)-mean(T_Heur_2_W_Back_No_Return_PA,1);
hold on


h=errorbar(nrange,mean(T_Heur_2_W_Back_No_Return_PA,1),yneg,ypos,'linewidth',LNW,...
    'marker','s','MarkerSize',MS,'linestyle','-.');
h.Color='c';
hold on


ylabel('Average time (s)')
xlabel('$n_p$','interpreter','latex')
set(gca,'fontsize',24,'fontname','Microsoft Sans Serif')
set(gcf,'color','w')
legend('Naive',....
    'Heu. $\#1$ (W/O Back-subs., extra test  PA)',...
    'Heu. $\#1$ (W/ Back-subs., extra test  PA)',...    
    'Heu. $\#2$ (W/O Back-subs., extra test  PA)',...
    'Heu. $\#2$ (W/ Back-subs., extra test PA)',...
    'interpreter','latex',...
    'edgecolor','none','color','none','location','best','fontsize',18)

set(gca, 'YScale', 'log')
grid on
ylim([1e-4,3e2])

figure(2)
surf(nrange,1:iterMax,T_Heur_1_No_Back_Return_PA)
set(gca,'Zscale','log')
colormap(bone)
colorbar
xlabel('$n_p$','interpreter','latex')
ylabel('Iter number')
set(gca,'fontsize',24,'fontname','Microsoft Sans Serif')
set(gcf,'color','w')


end

