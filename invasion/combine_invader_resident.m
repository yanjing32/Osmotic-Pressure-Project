function [total_ftr,invaders,bw_invader_classified,combined] = combine_invader_resident (bw_resident,factor,invaders,disk_size)



%% Written by Jing Yan 20161218
% after tracking the resident biofilm and invader cells, need to identify
% if a invader cell is inside or outside the resident biofilm.

%% classify each invading cells
for n = 1:size(bw_resident,3)
    if isempty(invaders(n).ftr) ==0; 
        for m = 1:size(invaders(n).ftr,1)
            if bw_resident(ceil(invaders(n).ftr(m,2)),ceil(invaders(n).ftr(m,1)),n) == 1;
                 invaders(n).ftr(m,4) = 1; 
            else
                invaders(n).ftr(m,4) = -1;
            end
        end
    end
end

%% generate a combined image showing different type.
bw_invader_classified = zeros(size(bw_resident,1),size(bw_resident,2),size(bw_resident,3));

for n = 1:size(bw_resident,3)
    ftrsim=zeros(size(bw_resident,1),size(bw_resident,2));
    if isempty(invaders(n).ftr) ==0
    
        ftr = invaders(n).ftr;
        ftr(:,1)=ceil(ftr(:,1));
        ftr(:,2)=ceil(ftr(:,2));
        ftr(:,[1,2]) = ftr(:,[2,1]);
        % Artificially enlarge the cell to a disk_size for visualization
        tmpdisk=fspecial('disk',disk_size);
        keep=(tmpdisk~=0);
        for m=1:size(ftr,1)
                tempkeep=keep.*ftr(m,4);
                ftrsim(ftr(m,1)-disk_size:ftr(m,1)+disk_size,ftr(m,2)-disk_size:ftr(m,2)+disk_size)=ftrsim(ftr(m,1)-disk_size:ftr(m,1)+disk_size,ftr(m,2)-disk_size:ftr(m,2)+disk_size)+tempkeep;   
        end

    end
    bw_invader_classified(:,:,n) = ftrsim;
       
end 
% save_segmented_tif(bw_invader_classified,'invaders_classified');
combined = bw_resident + factor.*bw_invader_classified;
% save_segmented_tif(combined,'combined');

% In case needed, generate a movie
% writerObj = VideoWriter('combined.avi');
% writerObj.FrameRate = 1;
% open(writerObj)
% figure
% for n = 1:size(combined,3)
% arr = combined(:,:,n);
% imagesc(arr); daspect([1 1 1]);
% frame = getframe(gcf);
% writeVideo(writerObj,frame)
% end
% close(writerObj);

% collapse all data into one file
total_ftr = [];
for n = 1:size(bw_resident,3)
total_ftr = [total_ftr
invaders(n).ftr];
end

% total_ftr = [];
% for n = 1:size(bw_resident,3)
% total_ftr = [total_ftr
% invaders(n).ftr];
% end
% keep = total_ftr(:,4) == 1;
% sum(sum(keep))
% keep = total_ftr(:,4) == -1;
% sum(sum(keep))