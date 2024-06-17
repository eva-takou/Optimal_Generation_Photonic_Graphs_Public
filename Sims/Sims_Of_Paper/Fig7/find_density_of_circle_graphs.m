function find_density_of_circle_graphs(nmin,nmax,iterMax)
%Script to plot the probability of finding a circle graph of size n.
%
%Input: nmin: min # of nodes
%       nmax: max # of nodes
%    iterMax: # of samples

close all;
cnt(1:nmax)=nan;

parfor n=nmin:nmax
   
    cnt(n)=0;
    for iter=1:iterMax
    
        Adj=create_random_graph(n);
        
        [bool,~]=is_circleG(Adj);
    
        if bool

            cnt(n)=cnt(n)+1;

        end
        
    end
    
end

cnt=cnt(~isnan(cnt));

h=bar(nmin:nmax,cnt/iterMax);
h.FaceColor=[0.17,0.45,0.7];
xlabel('$n$','interpreter','latex')
ylabel('$p$','interpreter','latex')
set(gcf,'color','w')
set(gca,'fontsize',24,'fontname','Microsoft Sans Serif')


end