
%% Written by Jing Yan 20161217
% This is not a prosecutable code. Type line by line to matlab window
% First need to input filenamestube. For images acquired with Nikon Element
% software, use export option to export files as separate tifs into a
% folder. filenamestube will be the name before height and channel identification (z01c1)
%%
[invaders,invade_image,bw_invader] = invading_cells(filenamestube,'r',0);
erosion_curve = gradual_shrink(6:12:126,invaders,filenamestube,'r');
% erosion_curve contains all information for further processing.
% quickly plot to take a look.
figure;
plot(erosion_curve(:,1),erosion_curve(:,2),'black')
% It might be better to plot the normalized curve
figure
plot(erosion_curve(:,1),erosion_curve(:,2)./max(erosion_curve(:,2)),'black')
