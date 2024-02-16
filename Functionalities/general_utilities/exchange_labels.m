function Adj=exchange_labels(Adj,v,w)
%Exchange the labels of two nodes of an adjacency matrix.
Adj([v,w],:)=Adj([w,v],:);
Adj(:,[v,w])=Adj(:,[w,v]);




end