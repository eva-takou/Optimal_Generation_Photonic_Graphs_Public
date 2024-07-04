%Script to test the size of the LC orbit (including isomorphs) in 2 ways
%1) By using the method of Bouchet
%2) By mapping out all the LC orbit, and then counting the size

clc; clear; close all; warning('on')

n       = 7;
iterMax = 10;

for iter=1:iterMax

    Adj0        = create_random_graph(n);
    l           = count_l_Bouchet(double(Adj0));
    Adj_LC      = Map_Out_Orbit(Adj0,'all'); %Need to include isomorphs
    
    if ~isnan(l) %Only if it is a circle graph we count correctly
        
        if l~=length(Adj_LC)

            error('Something is wrong in the code.')
            
        end
        
    end

end
