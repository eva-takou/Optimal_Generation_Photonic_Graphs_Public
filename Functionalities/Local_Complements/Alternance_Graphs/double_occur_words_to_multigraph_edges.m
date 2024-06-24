function EdgeList=double_occur_words_to_multigraph_edges(word)
%--------------------------------------------------------------------------
%Created by Eva Takou
%Last modified: June 25, 2024
%--------------------------------------------------------------------------
%
%Function to convert the double occurence word of an alternance graph to
%the corresponding 4-regular multigraph. 
%
%Input: word: The alternance word
%
%Output: EdgeList: A cell array contain the edges of the multigraph


EdgeList=[];
    
for kk=1:length(word)

    if kk<length(word)

        EdgeList = [EdgeList; [word(kk),word(kk+1)]];
    else
        EdgeList = [EdgeList;[word(kk),word(1)]];

    end
end
    
    
end