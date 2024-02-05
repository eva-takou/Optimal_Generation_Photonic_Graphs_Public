clc
clear
close all

n                   = 7;
iterMax             = 10;

for iter=1:iterMax

    Adj0        = create_random_graph(n);
    l           = count_l_Bouchet(double(Adj0));
    Adj_LC      = Map_Out_Orbit(Adj0,'bruteforce');
    
    if l~=length(Adj_LC)

        error('Something is wrong in the code.')

    end


end
