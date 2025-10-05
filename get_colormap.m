function colormap = get_colormap(L) 
%Returns a colormap used to display the environment with "dark green"
%   indicating low probability and "red" indicating high probability.
    map2 = zeros(L,3); 
    
    for i = 1:50 
        map2(i,:) = [0 (i+50)/100 0];  
    end
    for i = 1:100
        map2(i+50,:) = [i/100 1 0]; 
    end
    for i = 1:100
        map2(i+150,:) = [1 (100-i)/100  0]; 
    end
    colormap = map2;
end