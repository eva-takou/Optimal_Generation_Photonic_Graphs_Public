function l=count_l_Bouchet(Adj)
%Get the # of LC graphs of an input graph. The input graph has to be a
%circle graph to be able to extract the size of the LC orbit.
%Input: Adj: Adjacency matrix
%Ouput: l: size of LC orbit

[bool,~]=is_circleG(Adj,false);

if ~bool
    
    warning('Cannot count LC graphs if the input is not an alternance graph.')
    l=[];
    return
    
end
    

e = count_e_Bouchet(Adj);
k = index_k_of_F(Adj);

l = e/k;


end