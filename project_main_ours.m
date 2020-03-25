function coord = project_main(imgFile)
I = imread(imgFile);
figure, imshow(I), title('original image');
image = rgb2gray(I);

%% Preprocess
imgFile = preprocess(imgFile);
I = imread(imgFile);
figure, imshow(I), title('original image preprocessed');
image = rgb2gray(I);
%% User Input
% ask user for axis type
ylinear = input('Enter 1 for linear y axis, 0 for log axis: ');

%% Detect Axes
[origin,xaxis,yaxis] = detect_axis(image);

%% Detecting Labels
[xvalues, yvalues] = detect_labels(image, xaxis, yaxis, ylinear);

     
%% Data Extraction

line = classifyGraph(origin,xaxis,yaxis,imgFile);

if line
    coord = getLineCoord(origin,xaxis,yaxis,xvalues,yvalues,imgFile,ylinear);
else
    coord = getMultCoord(origin,xaxis,yaxis,xvalues,yvalues,imgFile,ylinear);
end
if ylinear
    figure; plot(coord(:,1),coord(:,2),'o');
else
    figure; semilogy(coord(:,1),coord(:,2),'o');
end
axis([xvalues(1) xvalues(2) yvalues(1) yvalues(2)]); title('Extracted data');

