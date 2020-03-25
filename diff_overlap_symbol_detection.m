function [xCentroids,yCentroids] = diff_overlap_symbol_detection(image)

% % Input image
origin = image;
grayImage = ~im2bw(origin, graythresh(image));
[h_crop,w_crop] = size(grayImage);

% user choose symbol 
figure; imshow(origin, []);
axis on;
set(gcf, 'Position', get(0,'Screensize')); % Maximize figure.
message = sprintf('Left click and hold to begin drawing.\nSimply lift the mouse button to finish');
uiwait(msgbox(message));
hFH = imfreehand();
binaryImage = hFH.createMask();
xy = hFH.getPosition;
labeledImage = bwlabel(binaryImage);

% derive symbol with slightly erosion 
se1 = strel('square', 3);
grayImage = imdilate(grayImage, se1);
grayImage = imerode(grayImage, se1);
extracted = labeledImage.*grayImage;
se2 = strel('disk', 2);
extracted = imerode(extracted, se2);
[rows,cols] = find(extracted);
extracted_crop = extracted(min(rows)-5:max(rows)+5,min(cols)-5:max(cols)+5);
figure;imshow(extracted_crop);title('Symbol template');

% erosion with extracted symbol
extracted_crop = imresize(extracted_crop, 1);
SE = strel('arbitrary',extracted_crop);
dilate_image = imerode(grayImage, SE);
%figure;imshow(dilate_image);

% save data 
measurements = regionprops(dilate_image, 'Centroid');
allCentroids = [measurements.Centroid];
xCentroids = allCentroids(1:2:end);
yCentroids = allCentroids(2:2:end);
%figure;plot(xCentroids,yCentroids,'o');
%axis([0 w_crop 0 h_crop]);


