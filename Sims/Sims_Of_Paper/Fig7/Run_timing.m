clear;
clc;
close all;


nmin    = 6; 
nmax    = 25; 
nstep   = 2;
iterMax = 200;

[Adj_Store,T_Naive,T_Heur_1_No_Back_Return_PA,...
    T_Heur_1_W_Back_No_Return_PA,...
    T_Heur_2_No_Back_Return_PA,...
    T_Heur_2_W_Back_No_Return_PA]=plot_runtime(nmin,nmax,iterMax,nstep)


