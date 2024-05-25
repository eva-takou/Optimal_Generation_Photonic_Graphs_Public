function word=transform_word_LC(word,p)
%--------------------------------------------------------------------------
%Created by Eva Takou
%Last modified: May 24, 2024
%--------------------------------------------------------------------------
%
%
%Apply LC operation on the level of the double occurence word.
%Input: word: the alternance word
%          p: the node on which to apply the LC operation.        
%Output: the updated alternance word.  

if ~isempty(p{1})

   for k=1:length(p) %transform the double occurence word

       q       = p{k}; 
       locs    = find(word==q);
       subword = flip(word(locs(1):locs(2)));
       word    = [word(1:locs(1)-1),subword,word(locs(2)+1:end)];

   end

end

end
