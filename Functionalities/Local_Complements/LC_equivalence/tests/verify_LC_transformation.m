clc;
clear;
close all;

n=12;

G1=create_random_graph(n);


iterMax=5;

LC_length = 3;

for iter=1:iterMax
    
    LC_seq=randi(n,[1,LC_length]);
    
    for k=1:length(LC_seq)
       
        G2=G1;
        G2=Local_Complement(G2,LC_seq(k));
        
        [Q_transf,flag,str_sols]=LC_check(G1,G2);
        [str_sols]=verify_LC_sol_Tab(G1,G2,str_sols);
        
    end
    
    
    
    
    
end
