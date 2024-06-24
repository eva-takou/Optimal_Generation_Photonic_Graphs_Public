clear; clc; close all;

%Plot the non-isomorphic LC orbit of RGSs.


n=3;
Adj_LC=Map_Out_RGS_Orbit(n,1:2*n);
figure(1)

for k=1:length(Adj_LC)

    nexttile
    plot(graph(double(Adj_LC{k})),'NodeColor','k',...
        'linewidth',1.2)
    hold on
    
    
    set(gcf,'color','w')
    
    
end


n=5;
Adj_LC=Map_Out_RGS_Orbit(n,1:2*n);
figure(2)

for k=1:length(Adj_LC)

    nexttile
    plot(graph(double(Adj_LC{k})),'NodeColor','k',...
        'linewidth',1.2)
    hold on
    
    set(gcf,'color','w')
    
end


