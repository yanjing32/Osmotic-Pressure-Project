function [green,red] = life_dead(file_green,file_red,water_threshold,smallest_area,show_image_or_not)

% Written by Jing Yan 2016/12/13

% Used to analyze images aobtained by BacLight live-dead stain
% Input: 
% file_green: name of the green image corresponding to live cells
% file_red: name of the red image corresponding to dead cells
% water_threshold: control the criteria for separating cells. To start, use
% 1000
% smallest_area: threshold for what is considered a object or not. 20 is
% good for a pixel size of 100 nm
% Show_image_or_not: whether show an image of the binarization result to
% check visually. 1 is true. 
% note: cell size not calibrated. 

pixel_size = 0.101; % unit is micron

arr_green = imread(file_green); % use the green channel to separate cells
arr_green = conv1and1(arr_green,[1 1 1],1);

% apply watershed based segmentation
g = imhmin(imcomplement(arr_green),water_threshold);
L = watershed(g);
BW = ones(size(g));
BW (L==0) = 0;
imgMask = double(arr_green).*BW;
arr1 = imgMask./max(max(imgMask));
fbw = im2bw(arr1,graythresh(arr1));

[~,L] = bwboundaries(fbw,'noholes');
p = regionprops(L,'Centroid','MajorAxisLength','MinorAxisLength','Area');

green = zeros(length(p),1);

% save information for future use
for n = 1:length(p)
green(n,1) = p(n).MajorAxisLength;
green(n,2) = p(n).MinorAxisLength;
green(n,3) = p(n).Area;
green(n,4:5) = p(n).Centroid;
end
keep = green(:,3) > smallest_area;
green = green(keep,:);
green(:,1) = green(:,1)*pixel_size;
green(:,2) = green(:,2)*pixel_size;
green(:,3) = green(:,3)*pixel_size*pixel_size;

% now red (dead cells)
arr_red = imread(file_red); % use the green channel to separate cells
arr_red = conv1and1(arr_red,[1 1 1],1);

% apply watershed based segmentation
g1 = imhmin(imcomplement(arr_red),water_threshold);
L1 = watershed(g1);
BW1 = ones(size(g1));
BW1 (L1==0) = 0;
imgMask1 = double(arr_red).*BW1;
arr2 = imgMask1./max(max(imgMask1));
fbw1 = im2bw(arr2,graythresh(arr2));

[~,L1] = bwboundaries(fbw1,'noholes');
p1 = regionprops(L1,'Centroid','MajorAxisLength','MinorAxisLength','Area');

red = zeros(length(p),1);
% save information for the future
for n = 1:length(p1)
red(n,1) = p1(n).MajorAxisLength;
red(n,2) = p1(n).MinorAxisLength;
red(n,3) = p1(n).Area;
red(n,4:5) = p1(n).Centroid;
end

keep = red(:,3) > smallest_area;
red = red(keep,:);
red(:,1) = red(:,1)*pixel_size;
red(:,2) = red(:,2)*pixel_size;
red(:,3) = red(:,3)*pixel_size*pixel_size;

% p = regionprops(L,'MajorAxisLength');

% for n = 1:length(p)
%     green_image = imread(file_green);
%     red_image = imread(file_red);
%     keep = (L==n);
%     p(n).green = sum(sum(keep.*double(green_image)));
%     p(n).red = sum(sum(keep.*double(red_image)));
%     p(n).reporter = p(n).red/p(n).green;
% end

% Save the cell length





% Reject objects that are too small (likely dust or dead cells)


% reject cells that are close to the edge
% keep = green(:,3) > 20 & green(:,3) < size(arr_green,1)-20 & green(:,4) > 20 & green(:,4) < size(arr_green,2) - 20;
% green = green(keep,:);

% result(:,1) = result(:,1)*pixel_size; % change the unit to um. this is using 60x objective with 1.5 postmagnification.

% Show image side by side, green left and red on the right

if show_image_or_not == 1
   
    figure('units','normalized','outerposition',[0 0 1 1])
    h1 = subplot(1,2,1);
    imagesc(arr_green);daspect([1 1 1]);
    hold on
    % show center
    plot(green(:,4),green(:,5),'ro','MarkerFaceColor','r','MarkerSize',2);
    
    h2 = subplot(1,2,2);
    imagesc(arr_red);daspect([1 1 1]);
    hold on
    plot(red(:,4),red(:,5),'ro','MarkerFaceColor','r','MarkerSize',2);
    
       
end
% figure; [N,edges] = histcounts(result(:,7),20);bar(edges(2:end),N,'r');

save([file_green '.mat'],'green','red','water_threshold','smallest_area');
[length(green) length(red)]


