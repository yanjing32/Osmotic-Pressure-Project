function [avg_distance,dist] = neighbor_distance(centers_norm,neighbor_cutoff,z_cutoff)

%% Written by Jing Yan 201161230 
% After segmenting individual cells in the biofilm, analyze the cell to cell
% distance in the biofilm.
% centers_norm is the result from single cell tracking. For detail, Please
% read http://www.pnas.org/content/113/36/E5337.abstract. For matlab codes
% needed to generate these files, visit
% https://github.com/yanjing32/Single-Cell-Tracking. 
% neighbor_cutoff sets the longested distance between cells that can be considered as neighbors
% default neighbor_cutoff should be around 6um.   
% To avoid surface effect, set a z_cutoff. After some manual testing, I found that if
% z_cutoff > 5, the result is robust. 

%% Use delaunay triangulation to find numbers. 
pairs=delaunaynSegs(centers_norm(:,1:3));
vectpair=centers_norm(pairs(:,2),1:3)-centers_norm(pairs(:,1),1:3);
vectpair(:,4)=(centers_norm(pairs(:,2),3)+centers_norm(pairs(:,1),3))/2;
dist=sqrt(sum(vectpair(:,1:3).^2,2));

% Set the threshold distance and the bottom layer thickness
keep=dist<neighbor_cutoff & vectpair(:,4) > z_cutoff; % 
% keep=dist<neighbor_cutoff;
vectpair=vectpair(keep,:);
pairs=pairs(keep,:);
dist=sqrt(sum(vectpair(:,1:3).^2,2));
% 
% [N] = histcounts(dist,0:0.2:10);
% plot(0.2:0.2:10,N,'r');hold on;

% Use gaussian peak method to find the average distance
range=0:0.2:neighbor_cutoff;
h=hist(dist,range);
[avg_distance,~,~]=gauss1dfit(h,range,h);