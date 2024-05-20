clear
close all;
clc;

%% Test that all Adj from within the orbit are LC equivalent

clc
n      = 5;
G1     = create_random_graph(n);
Adj_LC = Map_Out_Orbit(G1,'all');

for k=1:length(Adj_LC)
    
    [~,bool,~]=LC_check(G1,Adj_LC{k});
    
    if ~bool
       error('Incorrect result.') 
    end
    
end

%% Check that in negative case, the graph does not belong in the orbit

G1 = create_random_graph(n);
G2 = create_random_graph(n);

Adj_LC_2   = Map_Out_Orbit(G2,'all');
[~,bool,~] = LC_check(G1,G2);

if ~bool
   
    for k=1:length(Adj_LC_2)
        
        if all(all(Adj_LC_2{k}==G1))
            
           error('Incorect evaluation.') 
        end
        
    end
    
end
