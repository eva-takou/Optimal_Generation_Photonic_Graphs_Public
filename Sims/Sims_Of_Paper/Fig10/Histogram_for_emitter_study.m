clearvars
close all
clc

%% Plot emitter resources for unencoded RGS of any ordering

n   = 3; %# of core qubits
Adj = create_RGS(n,1:2*n,n,'Adjacency');
P0  = eye(2*n);

orders = perms(1:2*n);

parfor jj=1:size(orders,1)
    
    P          = P0;
    P(:,1:2*n) = P(:,orders(jj,:));
    
    temp    = Tableau_Class(P*double(Adj)*P','Adjacency');
    temp    = temp.Get_Emitters(1:2*n);
    ne3(jj) = temp.Emitters;

    
end
%%
n   = 4;
Adj = create_RGS(n,1:2*n,n,'Adjacency');
P0  = eye(2*n);

orders = perms(1:2*n);

parfor jj=1:size(orders,1)
    
    P          = P0;
    P(:,1:2*n) = P(:,orders(jj,:));
    
    temp   = Tableau_Class(P*double(Adj)*P','Adjacency');
    temp   = temp.Get_Emitters(1:2*n);
    ne4(jj) = temp.Emitters;
    
end
%%
n   = 5;
Adj = create_RGS(n,1:2*n,n,'Adjacency');
P0  = eye(2*n);

orders = perms(1:2*n);

parfor jj=1:size(orders,1)
    
    P          = P0;
    P(:,1:2*n) = P(:,orders(jj,:));
    
    temp   = Tableau_Class(P*double(Adj)*P','Adjacency');
    temp   = temp.Get_Emitters(1:2*n);
    ne5(jj) = temp.Emitters;
    
end

%% Plot the results
close all

subplot(1,3,1)
bar(sort(ne3))
subplot(1,3,2)
bar(sort(ne4))
subplot(1,3,3)
bar(sort(ne5))


figure(2)



h=histogram([ne3],'Normalization','probability');

h.BinEdges = [1.7,2.3,2.7,3.3];
hold on
h=histogram(ne4,'Normalization','probability');
h.BinWidth = 0.3;
h.BinEdges=[1.8,2.2,2.8,3.2,3.8,4.2];


hold on
h=histogram(ne5,'Normalization','probability');
h.BinWidth = 0.3;
h.BinEdges=[1.9,2.1,2.9,3.1,3.9,4.1,4.9,5.1];
ylabel('Prob. across permutations')
hold on


legend('$K_3^3$','$K_4^4$','$K_5^5$','interpreter','latex',...
    'edgecolor','none','color','none','location','best')
set(gcf,'color','w')
set(gca,'fontsize',20,'fontname','Microsoft Sans Serif')
xlabel('$n_e$','interpreter','latex')



