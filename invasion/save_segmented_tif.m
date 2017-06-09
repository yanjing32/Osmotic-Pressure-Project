function save_segmented_tif(mask,filename)


%% Written by Jing Yan 20161217
% Output a 3D matrix to a stached tiff file. 

% Sometimes the code runs into trouble of it is not able to write the file fast enough. 
% in this case, disp(frame) should work. or just add a pause. 

if exist([filename '.tif']) == 2;
    
    h = 1;
    while exist([filename num2str(h) '.tif']) == 2
        h = h+1;
    end
    newname = [filename num2str(h) '.tif'];
    for frame = 1:size(mask,3);
%         disp(frame)
        imwrite(mask(:,:,frame), newname, 'tif', 'WriteMode', 'append', 'compression', 'none');
    end
    
else
    for frame = 1:size(mask,3);
        imwrite(mask(:,:,frame),[filename '.tif'], 'tif', 'WriteMode', 'append', 'compression', 'none');
%         disp(frame)
    end
%     delete('segmented.tif');
end