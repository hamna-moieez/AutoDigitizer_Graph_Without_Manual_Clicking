function [origin,xaxis,yaxis] = detect_axis(image)

[~, threshold] = edge(image, 'sobel');
fudgeFactor = .5;
BWhorz = edge(image,'sobel', threshold * fudgeFactor, 'horizontal');
%figure, imshow(BWhorz), title('binary gradient mask horz');

fudgeFactor = .5;
BWvert = edge(image,'sobel', threshold * fudgeFactor, 'vertical');
%figure, imshow(BWvert), title('binary gradient mask vert');

% coordinates of the origin, endpts of x and y axis
[h, w] = size(BWhorz);

%find y axis
startCol = 1;
axisCol = 1;
while axisCol == 1
    currCol = BWvert(:, startCol);
    condIndsY = find(currCol == 1);
    numPixelsTrue = size(condIndsY, 1);
    if numPixelsTrue > h/2
        axisCol = startCol;
        break;
    end 
    startCol = startCol + 1;
end

%find x axis (assumption that there is an X axis on bottom of graph)
startRow = h;
axisRow = 1;
while axisRow == 1
    currRow = BWhorz(startRow, :);
    condIndsX = find(currRow);
    numPixelsTrue = size(condIndsX, 2);
    if numPixelsTrue > w/2
        axisRow = startRow;
        break;
    end 
    startRow = startRow - 1;
end

xStart = 0;
yStart = 0;
xEnd = 0;
yEnd = 0;

%find y axis start and end
if axisCol < w * (2/3)
    justYAxis = imopen(BWvert,ones(35, 1));
    yaxisInds = find(BWvert(:,axisCol) == 1);
    yMax = yaxisInds(1);
end

%find x axis start and end
if axisRow > h * (2/3) 
    justXAxis = imopen(BWhorz,ones(1, 35));
    xAxisInds = find(BWhorz(axisRow,:) == 1);
    xMax = xAxisInds(end);
end

%let starts be at the origin

% determine origin
originx = axisCol;
originy = axisRow;

xMin = originx;
yMin = originy;

figure, imshow(BWvert);
hold on;
plot(originx, originy, 'b*');

origin = [originx,originy];

xaxis = [xMin xMax];
yaxis = [yMin yMax];

end
