function bw_resident = resident_biofilm(filenamestub,invader_color,imagethresh,dilate_number,erode_number,save_or_not)

%% Written by Jing Yan 20161217

% This code is part of the code used to analyze the invasion of planktonic
% cells to resident biofilms
% Step one: identify spaces occupied by the resident biofilm. 

%% Read files. Note this section is written specifically for data produced
% and exported with Nikon Element software. Please change according to the
% software and microscope model.
aaaa = dir([filenamestub,'*c1.tif']);
Zsteps = (length(aaaa));
I = double(imread(aaaa(1).name));

resident = zeros(size(I,1),size(I,2),Zsteps);

% Identify which color is the invader cells and read the resident biofilm
% raw data 
if invader_color =='y' % 
    for z = 1:Zsteps
    I = double(imread(aaaa(z).name));
    resident(:,:,z) = I;
    end
else if invader_color == 'r'
    aaaa = dir([filenamestub,'*c2.tif']);
    for z = 1:Zsteps
     I = double(imread(aaaa(z).name));
    resident(:,:,z) = I;
    end
    end
end

%% Threshhold the resident biofilm.
bw_resident = zeros(size(I,1),size(I,2),Zsteps);

% Threshold the resident biofilm from individual xz plane. In practice,
% this is better than thresholding from individual xy plane.
for n = 1:size(I,2)
    arr = squeeze(resident(:,n,:));
    % use streak dilation in the image plane to fill empty area between cells. 
    % note this step will artificially enlarge the biofilm a little bit. 
    se = strel('line',dilate_number,90); 
    % dilating_number should be large enough to fill the holes but not
    % too large to cause too much artificial enlargement of the biofilm
    arr1 = imdilate(arr,se);
    arr1 = arr1./max(max(arr1));
    Iblur = imgaussfilt(arr1,2); % use blur to smooth a bit
    Iblur = Iblur./max(max(Iblur));
    fbw = im2bw(Iblur,imagethresh);


    bw_resident(:,n,:) = fbw;
end

%% Erode back to exclude surface area

% Due to the dilation step, the resident biofilm will look bigger. Need to
% erode it back. This erosion step is equivilant to setting a threshold for
% what we consider is a biofilm. 

% Note what we consider the beginning of the biofilm is tricky. in
% principle, setting erosion_number the same as the dilation number should
% restore the biofilm. In reality, might need a bigger number. 

for n = 1:Zsteps
    arr = bw_resident(:,:,n);
    se = strel('disk',erode_number);
    eroded =  imerode(arr,se);
    bw_resident(:,:,n) = eroded;
end

% also need to erode in the vertical direction: erode for the same amount!
for n = 1:size(I,2)
    arr = squeeze(bw_resident(:,n,:));
    se = strel('line',ceil(erode_number/12),90);% the factor of 12 comes from the ratio of the pixel size between z and xy direction.
    eroded =  imerode(arr,se);
    bw_resident(:,n,:) = eroded;
end

%% output the binary image for comparison. Optional

if save_or_not == 1;
save_segmented_tif(bw_resident,'resident_biofilm')
save('resident.mat','bw_resident','dilate_number','erode_number');
end 


%% not useful later
% dilate boundary. but this is equivilant to erosion steps performed later   
% BW = edge(fbw,'Sobel');
% se = strel('line',50,90);
% dilated_boundary = imdilate(BW,se);
% test = dilated_boundary == 0;
% 
% se = strel('line',12,0);
% dilated_boundary = imdilate(BW,se);
% test = dilated_boundary == 0;
% fbw = fbw.*test;