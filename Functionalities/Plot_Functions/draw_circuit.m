function draw_circuit(np,ne,Gate_Sequence,circuit_order,layer_shift,Init_State_Option)
%--------------------------------------------------------------------------
%Created by Eva Takou
%Last modified: May 19, 2024
%--------------------------------------------------------------------------
%
%Input: np: # of photons, 
%       ne: # of emitters, 
%       Gate_Sequence: A struct Gate_Sequence.Gate with 2 fields "qubit" 
%                      (indices of qubits) & "name" (name of the gate). For
%                      2-qubit gates, the first qubit is the control.
%       circuit_order: 'forward' or 'backward' regarding how we pass the
%                      order of the circuit as an input.
%       Layer shift: Value for spacing between gate boxes
%       Init_State_Option: '0' or '+' to show initial state of qubits as 
%                          |0> or |+>. If |+>, the Hadamard box on that
%                          qubit is removed.
%
%
%--------------------------------------------------------------------------
%This scripts draws a quantum circuit with 1:np photons (bottom lines)
%and np+1:np+ne emitters (top lines).
%--------------------------------------------------------------------------


%--- Fix parameters which work good for visualization ---------------------
vspace     = 1;
box_width  = (vspace/4)*40/20; %30/20
box_height = box_width;
LnWidths   = 1;
%==========================================================================

fntGate     = 11;
gate_colors = get_Gate_Colors;
gate_names  = get_Gate_Names;

%h=draw_qubits(np,ne,vspace,Right_X,'0');

%Get an approximate total length based on the # of gates the circuit has:
Right_X=length(Gate_Sequence.Gate.name)*(box_width+box_width)+layer_shift;


if strcmpi(circuit_order,'backward') %Bring to forward, & set P -> Pdagger
   
    Gates  = flip(Gate_Sequence.Gate.name);
    Qubits = flip(Gate_Sequence.Gate.qubit);    
    
    for k=1:length(Gates)

        if strcmpi(Gates{k},'P')

            Gates{k}='Pdag';

        end

    end                
    
else
    
    Gates  = Gate_Sequence.Gate.name;
    Qubits = Gate_Sequence.Gate.qubit;    
    
end


n = np+ne; %Total # of qubits

switch Init_State_Option
    
    case '+'
        
        init_H_gates = false(1,n);
        locs         = [];
        
        for jj=1:n
            
            for kk=1:length(Gates)
                
                if ismember(jj,Qubits{kk})  %First encounter of Qubit jj
                    
                    if strcmpi(Gates{kk},'H')
                        
                        locs=[locs,kk]; %Store location where first gate on jj is 'H'
                   
                        init_H_gates(jj)=true;
                    
                    end
                    
                    break %Break so that we check only first encounter
                end
                
            end
            
        end
        
        if all(init_H_gates)
            
            Gates(locs)  = []; %Remove initial Hadamards
            Qubits(locs) = [];
            
            h=draw_qubits(np,ne,vspace,Right_X,'+'); %Start the qubits from |+>
            
        else
            
            h=draw_qubits(np,ne,vspace,Right_X,'0');
            
        end
        
        
    case '0'
    
        h=draw_qubits(np,ne,vspace,Right_X,'0'); 
    
end


l0    = 1;
lstep = 1;
lf    = length(Gates);


for ll=l0:lstep:lf

    qubits = Qubits{ll};
    gates  = Gates{ll};
    hold on
    
    if length(qubits)==1 %Single qubit gate.
        
        if strcmpi(gates,'Pdag')
            clr = gate_colors.('P');
        else
            clr = gate_colors.(gates);
        end
        rectangle('Position',[layer_shift (h(qubits).YData(1)-box_height/2) box_width box_height],... %x,y,w,h 
                  'linewidth',LnWidths,'facecolor',clr);
            
        pos=[layer_shift,(h(qubits).YData(1)-box_height/2),box_width,box_height];
              
        if ~strcmpi(gates,'Pdag')
            text(pos(1)+pos(3)/2,pos(2)+pos(4)/2,gate_names.(gates),'HorizontalAlignment','center','fontsize',fntGate)      
        else
            text(pos(1)+pos(3)/2,pos(2)+pos(4)/2,'P$^\dagger$','HorizontalAlignment','center','fontsize',fntGate,'interpreter','latex')      
        end

        layer_shift=layer_shift+0.5+box_width/2;
        
        continue
              
    end
    
    
    %If it is not a measurement, draw the circle for the control qubit:
    
    if ~strcmpi(gates,'Measure') && ~strcmpi(gates,'MeasX') && ~strcmpi(gates,'MeasY')
        
       scatter(layer_shift+box_width/2,h(qubits(1)).YData(1),40,'filled','markerfacecolor','k',...
           'markeredgecolor','k')
        hold on

        %Draw the vertical line from qubit 1 to qubit 2
        line([layer_shift+box_width/2,layer_shift+box_width/2],[h(qubits(1)).YData(1),h(qubits(2)).YData(1)],...
            'color','k','linewidth',LnWidths)
        hold on
        
    end
    
    %Now if it is CNOT draw a box, if it's CZ draw another circle:
    
    if strcmpi(gates,'CNOT')
        
        clr = gate_colors.(gates);
        
        rectangle('Position',[layer_shift (h(qubits(2)).YData(1)-box_height/2) box_width box_height],... %x,y,w,h 
                  'linewidth',LnWidths,'facecolor',clr) 
              
        pos=[layer_shift,(h(qubits(2)).YData(1)-box_height/2),box_width,box_height];      
        text(pos(1)+pos(3)/2,pos(2)+pos(4)/2,gate_names.(gates),'HorizontalAlignment','center','fontsize',fntGate)      
        
    elseif strcmpi(gates,'CZ')
        
        
        scatter(layer_shift+box_width/2,h(qubits(2)).YData(1),40,'filled','markerfacecolor','k','markeredgecolor','k')          
        
    end
    
    
    if strcmpi(gates,'Measure') || strcmpi(gates,'MeasY') || strcmpi(gates,'MeasX')
        

        %Draw vertical lines from measured emitter to previously absorbed photon. 

        line([layer_shift+box_width*0.4,layer_shift+box_width*0.4],[h(qubits(1)).YData(1)-box_height/2,h(qubits(2)).YData(1)],...
            'color','k','linewidth',LnWidths)

        line([layer_shift+box_width*0.6,layer_shift+box_width*0.6],[h(qubits(1)).YData(1)-box_height/2,h(qubits(2)).YData(1)],...
            'color','k','linewidth',LnWidths)                
        
        %Draw the gate of feed-forward
        rectangle('Position',[layer_shift (h(qubits(2)).YData(1)-box_height/2) box_width box_height],'linewidth',LnWidths,...
           'facecolor',gate_colors.('X')) %x,y,w,h 
       
        pos=[layer_shift,(h(qubits(2)).YData(1)-box_height/2),box_width,box_height];
        
        text(pos(1)+pos(3)/2,pos(2)+pos(4)/2,gate_names.('X'),'HorizontalAlignment','center','fontsize',fntGate)      

       %Draw the box of measurement
        rectangle('Position',[layer_shift (h(qubits(1)).YData(1)-box_height/2) box_width box_height],'linewidth',LnWidths,...
           'facecolor','k') %x,y,w,h 
       
        if strcmpi(gates,'Measure')
            
            text(layer_shift+2*box_width/2,(h(qubits(1)).YData(1)-box_height/2)-box_height/2,'Z','HorizontalAlignment','center','fontsize',fntGate)      
            
        elseif strcmpi(gates,'MeasX')
            
            text(layer_shift+2*box_width/2,(h(qubits(1)).YData(1)-box_height/2)-box_height/2,'X','HorizontalAlignment','center','fontsize',fntGate)      
           
            
        elseif strcmpi(gates,'MeasY')
            
            text(layer_shift+2*box_width/2,(h(qubits(1)).YData(1)-box_height/2)-box_height/2,'Y','HorizontalAlignment','center','fontsize',fntGate)      
            
        end
       
        b  = 1.3;
        th = linspace(0,pi,100);
        R  = box_width/4*b;
        x  = R*cos(th)+layer_shift+box_width/2;
        y  = R*sin(th)+h(qubits(1)).YData(1)-box_width/8*b;
       
        plot(x,y,'color','w','linewidth',1.2)
        %plot a y=x line but shifted arguments i.e. y-y0 = (x-x0)
       
        line([layer_shift+box_width/2,layer_shift+3*box_width/4],...
             [h(qubits(1)).YData(1)-box_width/8*b,h(qubits(1)).YData(1)+box_height/3],'color','w','linewidth',1.2)

       
    end
    
    layer_shift=layer_shift+0.5+box_width/2;

end

set(gcf,'color','w')
axis off
axis equal
ax          = gca;
ax.Clipping = 'off';
zoom(1)


end