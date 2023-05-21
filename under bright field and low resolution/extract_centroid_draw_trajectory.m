% A script to extract centroids and then draw crawling trajectory of bright filed recording.
% Written by Tianqi Xu and Ping Wang in WenLab.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 1.prepare basic parameters, DO NOT change afterwards.

% 1.1 the start and the end frame of entire video
istart = 1;
iend = 1800;

% 1.2 the start and the end frames of each reversal, each row represents each reversal.
reversal_frames=[1 2];
fwd_frames=[1 1800];
% 1.3 frames that the agar pad was displaced in the video
displacing_frames=[1;2];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 2.load the video
[filename,pathname]  = uigetfile({'*.avi'});
readerobj = VideoReader(strcat(pathname,filename));
skip = floor((iend-istart+1)/10);
numframes = iend - istart + 1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 3.find the roi
j=0;
for i=istart:skip:iend
    j = j+1;
    
    img=read(readerobj,i);
    img=img(:,:,1);
    
    if i == istart
        imgsum = single(img);
        [ysize xsize ] = size(img);
        imgmin = ones(size(img))*255.0;
        imgdata = zeros(ysize, xsize, length(istart:skip:iend));
    end
    figure(1);
    imagesc(img); colormap gray;hold on;
    axis image;    title(num2str(i));
    imgdata(:,:,j) = img;
    imgmin = min(single(img), single(imgmin));
    imgsum = imgsum + single(img);
    pause(0.05);
end

figure(1);clf;
imagesc(imgsum); colormap gray; hold on;
title('sum image');

text(10,20, 'select ROI: upper left then lower right', 'Color', 'white');
[cropx1 cropy1 ] = ginput(1);
cropx1= floor(cropx1);
cropy1  = floor(cropy1);
plot([1 xsize], [cropy1 cropy1], '-r');
plot([cropx1 cropx1], [1 ysize], '-r');
[cropx2 cropy2 ] = ginput(1);
cropx2 = floor(cropx2);
cropy2 = floor(cropy2);
plot([1 xsize], [cropy2 cropy2], '-r');
plot([cropx2 cropx2], [1 ysize], '-r');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 4.Find a suitable threshold, so that the worm is as clear as possible and no larger impurities than the worm
imgtest=read(readerobj,round(rand(1)*numframes));
thred=200;%this is threshold
imagesc(imgtest>thred);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 5.extract centroiddata
centroiddata_all=zeros(numframes,2);
for j=1:numframes
    i = istart + (j - 1);
    
    
    
    img=read(readerobj,i);
    img = img(cropy1:cropy2,cropx1:cropx2);
    bw =single(img(:,:,1));
    
    
    bw(bw>thred)=5000;
    bw(bw<thred)=255;
    bw(bw==5000)=0;
    %Fill the gap
    se = strel('disk',2);
    imgfinal = imclose(uint8(bw),se);
    
    %Find the maximum connected domain and the center of mass
    L = bwlabel(imgfinal);
    STATS = regionprops(bwlabel(imgfinal),'Area', 'Centroid');
    Ar = cat(1, STATS.Area);
    ind = find(Ar ==max(Ar));
    areadata(1) = STATS(ind,:).Area;
    centroiddata(1,:) = STATS(ind,:).Centroid;
    if (i/100)==fix((i/100))
        disp(i);
    end
    centroiddata_all(i,1)=centroiddata(1,1);
    centroiddata_all(i,2)=-centroiddata(1,2);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %If you want to check the video, do not comment the code below
    figure(1);
    if mod(j,50)==1
        imshow(imgfinal);hold on;
        plot(centroiddata(1,1),centroiddata(1,2), 'oy'); hold on;
        axis image;    title(num2str(i));
        if (i/100)==fix((i/100))
            close;
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    clear img bw imgfinal L STATS Ar ind areadata centroiddata se
end  % end main loop

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 6.preview the trajectory
close;
figure;
scatter(centroiddata_all(:,1),centroiddata_all(:,2),30,'b');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 7. draw crawling trajectory with colormap
% such as:
% centroid, reversal_frames, displacing_frames cmap
cmap=turbo(1024);
padding=[0,0;0,0];
centroid_adj=[padding;centroiddata_all];
cdiff=diff(centroid_adj);
cdiff(displacing_frames,:)=0;
centroid_adj=cumsum(cdiff);
cdiff=diff(centroid_adj);
dist=sqrt(cdiff(:,1).^2+cdiff(:,2).^2);
plot(centroid_adj(:,1),centroid_adj(:,2));

% generate color points
color=zeros(length(dist),3);
for i=1:height(fwd_frames)
    color(fwd_frames(i,1):fwd_frames(i,2),:)=map_distance_to_cmap( ...
        dist(fwd_frames(i,1):fwd_frames(i,2)),cmap(1:floor(end/2),:));
end
for i=1:height(reversal_frames)
    color(reversal_frames(i,1):reversal_frames(i,2),:)=map_distance_to_cmap( ...
        dist(reversal_frames(i,1):reversal_frames(i,2)),flipud(cmap(ceil(end/2):end,:)));
end
scatter(centroid_adj(1:end-1,1),centroid_adj(1:end-1,2),20,color,'filled');

% plot
p=plot([centroid_adj(1:end-1,1)';centroid_adj(2:end,1)'],[centroid_adj(1:end-1,2)';centroid_adj(2:end,2)']);
for i=1:length(p)
    p(i).Color=color(i,:);
    p(i).LineJoin='round';
    p(i).LineWidth=5;
end

% interp
factor=100;
for i=1:width(centroid_adj)
    centroid_adj_i(:,i)=interp(centroid_adj(1:end-1,i),factor);
end
for i=1:width(color)
    color_i(:,i)=interp(color(:,i),factor);
end

% scatter
s=scatter(centroid_adj_i(:,1),centroid_adj_i(:,2),10,color_i,'filled');