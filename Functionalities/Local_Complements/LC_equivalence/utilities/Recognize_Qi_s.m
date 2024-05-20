function strQ = Recognize_Qi_s(Qi)
%--------------------------------------------------------------------------
%Created by Eva Takou
%Last modified: May 19, 2024
%--------------------------------------------------------------------------
%Input: The symplectic matrix Qi which corresponds to the single-qubit
%       Clifford gate.
%Output: A char corresponding to the local gate.
%
%--------------------------------------------------------------------------
%Transformation rules of [Sz|Sx]^T matrix under single Clifford gate.

QP = ([1 1 ; ...
             0 1]);

QH = ([0 1 ; ...
             1 0]);

%The Q of 1,X,Y,Z operators is just identity.

QPH  = mod(QP*QH,2);
QHP  = mod(QH*QP,2);
QHPH = mod(QH*QP*QH,2);

%--------------------------------------------------------------------------

cond_eq =@(A,B) all(all(A==B));


if cond_eq(Qi,QH)

    strQ = 'H';

elseif cond_eq(Qi,QP)
    
    strQ = 'P';


elseif cond_eq(Qi,QPH) 

    strQ = 'PH';

elseif cond_eq(Qi,QHP) 

    strQ = 'HP';

elseif cond_eq(Qi,QHPH) 

    strQ = 'HPH';


elseif cond_eq(Qi,eye(2)) %Can be any pauli \sigma_0={1,X,Y,Z}.
    
    strQ = '1'; %just pick an identity
    
else

    error('Unknown Q.')

end

end
