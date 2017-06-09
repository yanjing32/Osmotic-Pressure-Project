function erosion_curve = gradual_shrink(range,invaders,filenamestub,invader_color)

%% Written by Jing Yan 20161218
% Instead of using one particular erosion number as the threshold, it is
% better to show how the number of invading cells changes as a function of penetration depth into
% biofilm

% default range should be 6: 12: 126; corresponding to 0:3: 30 um into the
% biofilm

%%
erosion_curve = zeros(length(range),3);
erosion_curve(:,1) = range';
count = 1;
for erod = range
    % find the space occupied by resident biofilm first. The parameters are
    %  default parameters for the specific imaging parameters.
    bw_resident = resident_biofilm(filenamestub,invader_color,0.3,6,erod,0);
    % Identify invader cells as being in or outside the resident biofilms
    [total_ftr,~,~,~] = combine_invader_resident (bw_resident,3,invaders,6);
    % count invaders in the resident biofilm.
    keep = total_ftr(:,4) == 1;
    erosion_curve(count,2) = sum(sum(keep));
    % count invaders outside the resident biofilm.
    keep = total_ftr(:,4) == -1;
    erosion_curve(count,3) = sum(sum(keep));
    disp(erosion_curve(count,:));
    count = count+1;
end

save([filenamestub '.mat'],'erosion_curve','invaders');