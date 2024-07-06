%Timing of different Naive variants
clear; close all; clc;

Store_Graphs   = false;
Store_Gates    = false;
Verify_Circuit = false;

nmin    = 20;
nstep   = 5;
nmax    = 100;
iterMax = 50;

nrange = nmin:nstep:nmax;
Ln     = length(nrange);

parfor k=1:Ln
    
    n = nrange(k);

    for iter=1:iterMax

        BackSubsOption = false;
        return_cond    = true;

        Adj = create_random_graph(n);
        obj = Tableau_Class(Adj,'Adjacency');
        
        
        tic
        obj = obj.Generation_Circuit(1:n,Store_Graphs,Store_Gates,BackSubsOption,...
                                     Verify_Circuit,return_cond);
        T_Naive(iter,k)=toc;
        
        
        BackSubsOption = false;
        return_cond    = false;

        tic
        obj = obj.Generation_Circuit(1:n,Store_Graphs,Store_Gates,BackSubsOption,...
                                     Verify_Circuit,return_cond);
        T_Naive_w_extra_test(iter,k)=toc;
        
        
        BackSubsOption = true;
        return_cond    = false;

        tic
        obj = obj.Generation_Circuit(1:n,Store_Graphs,Store_Gates,BackSubsOption,...
                                     Verify_Circuit,return_cond);
        T_Naive_w_extra_test_and_Back_Subs(iter,k)=toc;
        
    end            
    
end
             
%%
close all; clc;
LNW = 2;
MS  = 4;

yneg = mean(T_Naive,1)-min(T_Naive,[],1);
ypos = max(T_Naive,[],1)-mean(T_Naive,1);

h    = errorbar(nrange,mean(T_Naive,1),yneg,ypos,'linewidth',LNW,...
    'marker','s','MarkerSize',MS,'linestyle','-.');
h.Color='k';
hold on

yneg = mean(T_Naive_w_extra_test,1)-min(T_Naive_w_extra_test,[],1);
ypos = max(T_Naive_w_extra_test,[],1)-mean(T_Naive_w_extra_test,1);
h    = errorbar(nrange,mean(T_Naive_w_extra_test,1),yneg,ypos,'linewidth',LNW,...
    'marker','s','MarkerSize',MS,'linestyle','-.');
h.Color=[0.9290 0.6940 0.1250];
hold on


yneg = mean(T_Naive_w_extra_test_and_Back_Subs,1)-min(T_Naive_w_extra_test_and_Back_Subs,[],1);
ypos = max(T_Naive_w_extra_test_and_Back_Subs,[],1)-mean(T_Naive_w_extra_test_and_Back_Subs,1);
h    = errorbar(nrange,mean(T_Naive_w_extra_test_and_Back_Subs,1),yneg,ypos,'linewidth',LNW,...
    'marker','s','MarkerSize',MS,'linestyle','-.');
h.Color=[0.4940 0.1840 0.5560];
hold on

set(gca,'yscale','log','fontsize',20,'fontname','Microsoft Sans Serif')
set(gcf,'color','w')
legend('Naive','Naive w/ extra test PA',...
       'Naive w/ extra test PA & BackSubs',...
       'color','none','edgecolor','none','location','best')
xlim([min(nrange),max(nrange)])
grid('on')
xlabel('$n_p$','interpreter','latex')
ylabel('Average time (s)')