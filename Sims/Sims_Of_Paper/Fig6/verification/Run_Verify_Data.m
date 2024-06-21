clearvars; clc; close all;

iterMax = 20; %Verify the results of the first 20 graphs
minK    = 1; %Starting index in [1,8] for np array: np=[6,8,10,12,18,26,30,40]
maxK    = 8; %Final index in [1,8] for np array: np=[6,8,10,12,18,26,30,40]

verify_Data_Heu2(iterMax,minK,maxK)

