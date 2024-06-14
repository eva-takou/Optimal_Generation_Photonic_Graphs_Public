function RGB_triplet=color_palette(color_name)
%--------------------------------------------------------------------------
%Created by Eva Takou
%Last modified: May 19, 2024
%--------------------------------------------------------------------------
%Output RGG triplet of colors based on: 
%http://www.fifi.org/doc/wwwcount/Count2.5/rgb.txt.html
%
%Input: Color name 'AliceBlue', 'BlueViolet', 'CadetBlue', 'CadetBlue1',
%                  'CadetBlue2', 'CadetBlue3', 'CadetBlue4',
%                  'CornflowerBlue', 'DarkSlateBlue'.
%Output: RGB triplet of the color name provided.

if strcmpi(color_name,'AliceBlue')
   
    RGB_triplet = [240,248,255];
    
elseif strcmpi(color_name,'BlueViolet')
    
    RGB_triplet = [138,43,226];
    
elseif strcmpi(color_name,'CadetBlue')
    
    RGB_triplet = [95,158,160];
    
elseif strcmpi(color_name,'CadetBlue1')
    
    RGB_triplet = [152,245,255];
    
elseif strcmpi(color_name,'CadetBlue2')    
    
    RGB_triplet = [142,229,238];
    
elseif strcmpi(color_name,'CadetBlue3')        
    
    RGB_triplet = [122,197,205];
    
elseif strcmpi(color_name,'CadetBlue4')      
    
    RGB_triplet = [83,134,139];
    
elseif strcmpi(color_name,'CornflowerBlue')     
    
    RGB_triplet = [100,149,237];
    
elseif strcmpi(color_name,'DarkSlateBlue')     
    
    RGB_triplet = [72,61,139];
    
end

RGB_triplet = RGB_triplet/255; %Scale

end