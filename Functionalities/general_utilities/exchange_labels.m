function Adj=exchange_labels(Adj,v,w)
%--------------------------------------------------------------------------
%Created by Eva Takou
%Last modified: May 19, 2024
%--------------------------------------------------------------------------
%
%Exchange the labels of two nodes of an adjacency matrix.
%
%Input: Adj: Adjacency matrix
%       v: node label of first node (a number)
%       w: node label of second node (a number)
%Output: The updated adjacency matrix

Adj([v,w],:)=Adj([w,v],:);
Adj(:,[v,w])=Adj(:,[w,v]);

end