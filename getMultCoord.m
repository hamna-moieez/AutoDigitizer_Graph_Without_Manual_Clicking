%% Returns values of points in an image (assuming circular with radius 2)
% origin, xaxis, yaxis: cells containing (row,col) coordinate vector
% xvalues: array containing min and max values of x axis
% yvalues: "                                   "  y axis
% imgFile: string of file name of image
% linear: 0/1 based on whether linear scale or log scale axes
% line: 0/1 whether line or set of points
% coord: x,y values of point(s)
function coord = getMultCoord(origin,xaxis,yaxis,xvalues,yvalues,imgFile,ylinear)
    % crop and binarize image 
    img = imread(imgFile);  
    img_gray = rgb2gray(img);
    img_bin = ~im2bw(img_gray, graythresh(img_gray));
    img_crop = img_bin(yaxis(2):yaxis(1),xaxis(1):xaxis(2));
    img_crop_gray = img_gray(yaxis(2):yaxis(1),xaxis(1):xaxis(2));
    
    %crop out the edge tick marks (1/30th of img_crop)
    [h_crop,w_crop] = size(img_crop);
    img_crop_edge = img_crop_gray(h_crop/30:29*h_crop/30,w_crop/30:29*w_crop/30);
    %figure; imshow(img_crop_edge);
    [h_crop_edge,w_crop_edge] = size(img_crop_edge);
    

    [centersx,centersy] = diff_overlap_symbol_detection(img_crop_edge);
    centers = cat(2,centersx',centersy');
    [n_centers,~] = size(centers);
    for j = 1:n_centers
        xdist = centers(j,1) + w_crop/30;
        ydist = h_crop - (centers(j,2) + h_crop/30);
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
