function [invaders,invade_image,bw_invader] = invading_cells(filenamestub,invader_color,save_or_not)

%% Written by Jing Yan 20161217
% Analyze invasion data. Step two is to track the invading cells.

%% Read files
aaaa = dir([filenamestub,'*c1.tif']);
Zsteps = (length(aaaa));
I = double(imread(aaaa(1).name));

invade_image = zeros(size(I,1),size(I,2),Zsteps);

% Reading the invader channel
if invader_color =='r'
    for z = 1:Zsteps
    I = double(imread(aaaa(z).name));
    invade_image(:,:,z) = I;
    end
else if invader_color == 'y'
    aaaa = dir([filenamestub,'*c2.tif']);
    for z = 1:Zsteps
     I = double(imread(aaaa(z).name));
    invade_image(:,:,z) = I;
    end
    end
end

%% Track invader cells
invaders = struct();

for n = 1:size(invade_image,3)
    arr = invade_image(:,:,n);
    % quick removal of noise
    arr = conv1and1(arr,[1 1 1],1);
    % method 1 uses circlefinding to find cells 
	 [ftr, ~] = imfindcircles(arr,[2 10],'ObjectPolarity','Bright','Sensitivity',0.95);
    % alternatively, can use feature finding. not as robust though. Not recommended. 
    %     options.peakmin = 2000;
    %     ftr = features((arr),3,options);
    if isempty(ftr)==0
    % remove cells that are close to the edge
        keep = ftr(:,1)>10 & ftr(:,2)>10 & ftr(:,1) < size(invade_image,1)-10 & ftr(:,2)< size(invade_image,2)-10;
        ftr = ftr(keep,:);
        % record the plane of the cells reside in
        [x,~]=meshgrid(n,1:size(ftr,1));
         ftr(:,3) = x;

        if length(ftr)< 1000 % sometime in a plane there is nothing, the code is tracking empty cells. 
            invaders(n).ftr = ftr;
        else
            invaders(n).ftr = [];
        end
    end 
    disp(n)
end

% now sometimes a cell will appear in both bottom and upper plane, especially for cells with a vertical orientation. 
% Need to remove them to avoid overcounting. Note because of the
% acquisition step (dz = 3 um), a cell cannot appear in 3 consecutive
% planes.

for n = 1:size(invade_image,3)-1
    if isempty(invaders(n).ftr)==0 && isempty(invaders(n+1).ftr)==0 
        [x,~]=meshgrid(invaders(n).ftr(:,1),1:length(invaders(n+1).ftr(:,1)));
        [~,y]=meshgrid(1:length(invaders(n).ftr(:,1)),invaders(n+1).ftr(:,1));
        temp1 = abs(x-y);
        [x,~]=meshgrid(invaders(n).ftr(:,2),1:length(invaders(n+1).ftr(:,2)));
        [~,y]=meshgrid(1:length(invaders(n).ftr(:,2)),invaders(n+1).ftr(:,2));
        temp2 = abs(x-y);
        [~,col] = find(temp1<2 & temp2<2); % the criteria should be 2 pixel to account for slight shift in xy during z motion. 
        % remove the recording of the cell in the bottom plane. 
        invaders(n).ftr(col,:) = [];
    end
end 

%%
% if necessary, make a movie to check 
% writerObj = VideoWriter('invader1.avi');
% writerObj.FrameRate = 1;
% open(writerObj)
% for n = 1:size(invade_image,3)
% arr = invade_image(:,:,n);
% imagesc(arr); daspect([1 1 1]);
% hold on
% if isempty(invaders(n).ftr) == 0
% plot(invaders(n).ftr(:,1),invaders(n).ftr(:,2),'rx');
% end
% hold off
% frame = getframe(gcf);
% writeVideo(writerObj,frame)
% end
% close(writerObj);

%% geerate a simple illustration to compare with oriignal image
bw_invader = zeros(size(I,1),size(I,2),Zsteps);
for n = 2:size(invade_image,3)
    ftr = invaders(n).ftr;
    temp = zeros(size(invade_image,1),size(invade_image,2));
    for m = 1:size(ftr,1)
        temp (ceil(ftr(m,2)),ceil(ftr(m,1))) = 1;
    end
    % dilate the single point to a circle with radius of 5 to be clearer
    se = strel('disk',5);
    temp = imdilate(temp,se);
    bw_invader(:,:,n) = temp;
       
end 

%% save images and data. optional

if save_or_not == 1
  save_segmented_tif(bw_invader,'invaders');
  save('invader.mat');
end
%% Not useful: have tried to use watershed to find cells. However, not really needed because cells are usually far apart in this case


% g = imhmin(imcomplement(invade_image),watershed_value); 
% % g = imgfilter;
% L = watershed(g); 
% BW = ones(size(g));
% BW (L==0) = 0; % find the boundary and assign zero value. This effectively cut nearby cells
% imgMask = invade_image.*BW; 
% imgMask = invade_image;
% for n = 1:size(imgMask,3)
%         arr = imgMask(:,:,n);
%         arr = arr./max(max(arr));
%         BW = im2bw(arr,graythresh(arr)); % automatically finding threshold value. Note this works better if first devided by max value. 
%         imgMask(:,:,n) = arr.*BW;
% %  NOTE : due to degregation of signal in z direction, it is better to find
% %  threshold independently for each z. For water objective and appropriate
% %  deconvolution, z degredation is not severe
% % disp(n)
% end

% mask = zeros(size(imgMask)); mask(imgMask>0)=1; % Now cell region is labeled 1 and non-cell region is zero
% maskLabel = bwlabeln(mask(:,:,1:size(invade_image,3))); % label the cells with numbers
% ncells = max(maskLabel(:))% output total number of cells as a check.

% out put images for quality control
% save_segmented_tif(mask);
