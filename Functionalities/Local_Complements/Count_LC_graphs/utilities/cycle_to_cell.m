function newcycles=cycle_to_cell(cycles)
%--------------------------------------------------------------------------
%Created by Eva Takou
%Last modified: May 19, 2024
%
%Convert the cycles (output as nodes) as a list of edges contained in the
%cycle.
%Input: cycles: A list of cycles, which contain an array of nodes
%Output: newcycles: A list of cycles, which contain a list of edges. Each
%                   edge is defined by 2 nodes.

LC = length(cycles);

for l=1:LC

    newcycles{l}=[];
    
    this_cycle = cycles{l};
    
    for k=1:length(this_cycle)
    
        if k<length(this_cycle)
        
        
            newcycles{l}=[newcycles{l};sort([this_cycle(k),this_cycle(k+1)])];
        
        else
            
            newcycles{l}=[newcycles{l};sort([this_cycle(k),this_cycle(1)])];
            
        end
        
        
    end
    
    newcycles{l}=sort(newcycles{l},2);
    
    
    
end







end