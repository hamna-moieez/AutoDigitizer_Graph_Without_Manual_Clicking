%% Returns values of points in an image
% origin, xaxis, yaxis: cells containing (row,col) coordinate vector
% xvalues: array containing min and max values of x axis
% yvalues: "                                   "  y axis
% imgFile: string of file name of image
% linear: 0/1 based on whether linear scale or log scale axes
% line: 0/1 whether line or set of points
% coord: x,y values of point(s)
function coord = getLineCoord(origin,xaxis,yaxis,xvalues,yvalues,imgFile,ylinear)
    % crop and binarize image   
    img = imread(imgFile);
    img_gray = rgb2gray(img);
    img_crop = img_gray(yaxis(2):yaxis(1),xaxis(1):xaxis(2));

    % crop out the edge tick marks (1/29th of img_crop)
    [h_crop,w_crop] = size(img_crop);
    img_crop_edge = img_crop(h_crop/29:28*h_crop/29,w_crop/29:28*w_crop/29);
    %figure; imshow(img_crop_edge);
    [h_crop_edge,w_crop_edge] = size(img_crop_edge);
    
    % detect number of regions and choose smaller
    img_bw = ~im2bw(img_crop_edge,graythresh(img_crop_edge));

    % generate set of x coordinates (at some resolution)
    resolution = 80;
    xpts = round(linspace(1,w_crop_edge,resolution));

    % search for zero value in each x coordinate column
    ypts = zeros(size(xpts));
    for i = 1:resolution
        col_bw = img_bw(:,xpts(i));
        ypts(i) = find(col_bw,1,'last');
    end
    
    centers = cat(2, xpts', ypts');
    for j = 1:length(centers)-1
        xdist = centers(j,1) + w_crop/29;
        ydist = h_crop - (centers(j,2) + h_crop/29);
        xrange = xvalues(2) - xvalues(1);
        coord(j,1) = xrange*(xdist/w_crop) + xvalues(1);
        if ylinear
            yrange = yvalues(2) - yvalues(1);
            coord(j,2) = yrange*(ydist/h_crop) + yvalues(1);
        else
            yrange = log10(yvalues(2)) - log10(yvalues(1));
            coord(j,2) = 10^(log10(yvalues(1)) + yrange*(ydist/h_crop));
        end
    end
    
end
