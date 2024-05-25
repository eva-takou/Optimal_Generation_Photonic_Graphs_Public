function [A1,A2,A3]=i_minors(Adj,v)
%--------------------------------------------------------------------------
%Created by Eva Takou
%Last modified: May 24, 2024
%--------------------------------------------------------------------------
%
%Calculate the i-minors of G, given a node v.
%The three i-minors are G\v, G*v\v and G*vwv\v, where w\in N(v).
%'*' here implies local complementation about node v.
%
%Input: Adj: Adjacency matrix
%       v: node for which to get the 3 i-minors

A1 = Adj;
A2 = Adj;
A3 = Adj;

%G\v
A1(:,v)=[];
A1(v,:)=[];

%G*v\v
A2      = Local_Complement(A2,v);
A2(v,:) = [];
A2(:,v) = [];

%G*vwv\v
Nv = Get_Neighborhood(A3,v);
w  = Nv(1);
A3 = Local_Complement(A3,v);
A3 = Local_Complement(A3,w);
A3 = Local_Complement(A3,v);

A3(:,v) = [];
A3(v,:) = [];


end