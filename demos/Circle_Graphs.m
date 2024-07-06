% Probability of finding a circle graph, and alternance words
clear; clc; close all;

iterMax = 1e3;
n       = 6;
cnt     = 0;

parfor iter = 1:iterMax
    
    Adj            = create_random_graph(n);
    [bool,m{iter}] = is_circleG(Adj); %m is alternance word
    
    if bool
        cnt=cnt+1;
    end
    
end

disp(['Prob of finding a circle graph:',...
    num2str(cnt/iterMax),' for n=',num2str(n)])
