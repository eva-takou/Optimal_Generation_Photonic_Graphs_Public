function Adj=create_encoded_RGS_Opt_Ordering(n)
%n: number of core qubits.

if (-1)^n~=1

   error('Need even core for encoded RGS.') 
   
end

%Leaf -> core 1-> leaf -> core 2-> triangle -> leaf of core 1 -> leaf of
%core 2

%triangle -> core -> core -> leaf of 1st core -> leaf of 2nd core
%triangle -> core -> core -> leaf of 1st core -> leaf of 2nd core.


EdgeList={};



v=1:3;

w=[];
for k=1:n/2
    
    %Make triangle
    w=[w,v(2:end)];
    

    
    for l1=1:length(v)
        
        for l2=l1+1:length(v)
        
            EdgeList=[EdgeList,{[v(l1),v(l2)]}];
        end
        
    end
    
    
    
    %Add 2 leaves per core
    
    for m=1:2
       
        core = v(m+1);
        
        for leaf=1:2
            
            leaf_label = max([EdgeList{:}])+1;
            EdgeList=[EdgeList,{[core,leaf_label]}];
            
            
        end
        
        
        
    end
    

    
    %Make next triangle:
    v=max([EdgeList{:}])+1:max([EdgeList{:}])+3;
    
    %Store the core nodes:
    
    
end

for l1=1:length(w)
    
    for l2=l1+1:length(w)
        
   
        EdgeList=[EdgeList,{[w(l1),w(l2)]}];
        

    end
end


%Exchange position of 1-2 with first leaf



Adj=edgelist_to_Adj(EdgeList,max([EdgeList{:}]));
%Because it has duplicates, the locs of 2s put them 1s

[row,col]=find(Adj==2);

for k=1:length(row)
    Adj(row(k),col(k))=1;
end

Adj=exchange_labels(Adj,1,2);
Adj=exchange_labels(Adj,1,4);
Adj=exchange_labels(Adj,2,4);
Adj=exchange_labels(Adj,3,7);
Adj=exchange_labels(Adj,4,7);
Adj=exchange_labels(Adj,5,7);
Adj=exchange_labels(Adj,6,7);
Adj=exchange_labels(Adj,1,2);
Adj=exchange_labels(Adj,3,4);



%This is the best for n=4

Adj=exchange_labels(Adj,7,1);












end