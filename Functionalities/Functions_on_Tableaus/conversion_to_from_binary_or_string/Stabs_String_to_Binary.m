function Stabs=Stabs_String_to_Binary(S)
%--------------------------------------------------------------------------
%Created by Eva Takou
%Last modified: May 25, 2024
%
%Convert stabilizer string to binary matrix.
%
%Input: S: cell array of char which contain a pauli sequence of I,X,Y,Z.
%Each element of the cell array is a stabilizer generator.
%Output: The stabilizer (n x 2n) representation in binary.

if ~iscell(S)
    
   error('Please provide the stabs as a cell of strings.') 

end

n     = length(S);
Stabs = zeros(n,2*n,'int8');

for ii=1:n %loop through stabs

   for jj=1:length(S{ii})  %loop through opers

       if strcmpi(S{ii}(jj),'X')

           Stabs(ii,jj)=1;

       elseif strcmpi(S{ii}(jj),'Y')

           Stabs(ii,jj)=1;
           Stabs(ii,jj+n)=1;

       elseif strcmpi(S{ii}(jj),'Z')

           Stabs(ii,jj+n)=1;

       end

   end

end

end