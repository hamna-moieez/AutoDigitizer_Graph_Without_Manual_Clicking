function line = classifyGraph(origin,xaxis,yaxis,imgFile)
    img = imread(imgFile);
    img_gray = rgb2gray(img);
    img_crop = img_gray(yaxis(2):yaxis(1),xaxis(1):xaxis(2));
    %figure; imshow(img_crop);
    
    % crop out the edge tick marks (1/29th of img_crop on all sides)
    [h_crop,w_crop] = size(img_crop);
    img_crop_edge = img_crop(h_crop/29:28*h_crop/29,w_crop/29:28*w_crop/29);
    %figure; imshow(img_crop_edge);
    [h_crop_edge,w_crop_edge] = size(img_crop_edge);
    
    % detect number of regions
    img_bw = ~im2bw(img_crop,graythresh(img_crop_edge));
    reg_label = bwlabel(img_bw);
    num_reg = max(reg_label(:));
    
    % detect 1 line vs multiple points
    if num_reg > 1
        line = 0;
    else
        line = 1;
    end
end

