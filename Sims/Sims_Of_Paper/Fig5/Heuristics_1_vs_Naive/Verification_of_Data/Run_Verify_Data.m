clear;
clc;
load('500_graphs_per_np.mat')

iterMax=50; %Verify the data for a subset of the graphs

nmax  = 20;
nmin  = 6;
nstep = 2;


verify_Data(Adj,CNOT_Best,CNOT_Naive,nmin,nmax,nstep,iterMax)
