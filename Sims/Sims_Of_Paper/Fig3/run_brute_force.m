%% Results for graphs of np=8
clear; close all;

load('500_graphs_np_8.mat')
clearvars -except Adj_Store
Adj   = Adj_Store;
n     = 8; 
tryLC = true;
prune = true;
[ne,CNOTs,CNOTs_Opt]=compare_naive_w_brute_force_specified_Adj(Adj,n,tryLC,prune);
%% Results for graphs of np=7
clear; close all;

load('2e3_graphs_np_7_prune_off.mat')
clearvars -except Adj
n      = 7;
tryLC  = true;
prune  =false;
[ne,CNOTs,CNOTs_Opt]=compare_naive_w_brute_force_specified_Adj(Adj,n,tryLC,prune);