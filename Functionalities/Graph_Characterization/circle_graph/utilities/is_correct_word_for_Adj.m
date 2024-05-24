function bool=is_correct_word_for_Adj(Adj,constructed_word)
%--------------------------------------------------------------------------
%Created by Eva Takou
%Last modified: May 24, 2024
%--------------------------------------------------------------------------
%
%Check if the constructed word matches the adjacency matrix.
%Input: Adj: Adjacency matrix
%       constructed word: the alternance word
%Output: bool: true or false

testA = double_occur_words_to_LC_graphs(constructed_word,'Adjacency');
testA = testA{1};

if ~all(all(Adj==testA))
    
    bool = false;
    
else
    
    bool = true;
    
end


end