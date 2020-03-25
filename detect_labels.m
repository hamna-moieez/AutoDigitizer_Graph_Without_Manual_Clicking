
function [xvalues, yvalues] = detect_labels(gray, xaxis, yaxis, ylinear)

    label_margin = 60;

    % crop out y axis to focus just on x labels
    xCropped = gray(yaxis(1):end, xaxis(1)-(label_margin/2):end);
    %figure, imshow(cropped);

    % Perform OCR to get axis number labels
    results = ocr(xCropped, 'CharacterSet', '-0123456789', 'TextLayout','Block');

    % Weed out low confidence 
    confidentIdx = find(results.CharacterConfidences > 0.70);
    % Get the bounding box locations of the low confidence characters
    confBBoxes = results.CharacterBoundingBoxes(confidentIdx, :);
    confVal = results.CharacterConfidences(confidentIdx); % Get confidence values

    commonY = mode(confBBoxes(:, 2));
    commonHeight = mode(confBBoxes(:, 4));

    withoutAxisLabel = xCropped(1:commonY + commonHeight,:);

    xResults = ocr(withoutAxisLabel,'TextLayout','Block');
    xnumBBs = xResults.WordBoundingBoxes;
    wordConf = xResults.WordConfidences;
    xNums = xResults.Words;

    Iocr = insertObjectAnnotation(withoutAxisLabel, 'rectangle', xnumBBs, xNums);
    figure; imshow(Iocr);

    errorThresh = 10;
    %determine if first detected x axis number label is at xStart 
    if xnumBBs(1, 1) < errorThresh
        leftNumOnXstart = true;
    else
        leftNumOnXstart = false;
    end

    %determine if last detected x axis number label is at xEnd
    xEndNumAlignment = xnumBBs(end, 1) + xaxis(1)-(label_margin/2) + xnumBBs(end, 3)/2;
    if abs(xEndNumAlignment - xaxis(2)) < errorThresh
        rightNumOnXend = true;
    else
        rightNumOnXend = false;
    end

    % crop out x axis to focus just on y labels
    yCropped = gray(1:yaxis(1)+(label_margin/2), 1:xaxis(1));

    % Perform OCR to get axis number labels
    results = ocr(yCropped, 'CharacterSet', '-0123456789', 'TextLayout','Block');

    % Weed out low confidence 
    confidentIdx = find(results.CharacterConfidences > 0.70);

    % Get the bounding box locations of the low confidence characters
    confBBoxes = results.CharacterBoundingBoxes(confidentIdx, :);

    commonX = mode(confBBoxes(:, 1));

    withoutAxisLabel = yCropped(:, commonX - (label_margin/2):end);
    
    yResults = ocr(withoutAxisLabel,'TextLayout','Block');
    ynumBBs = yResults.WordBoundingBoxes;
    wordConf = yResults.WordConfidences;
    yNums = yResults.Words;
    
    Iocr = insertObjectAnnotation(withoutAxisLabel, 'rectangle', ynumBBs, yNums);
    figure; imshow(Iocr);

    %determine if first detected x axis number label is at xStart 
    yStartNumAlignment = ynumBBs(1, 2) + ynumBBs(1, 4)/2;
    if (yStartNumAlignment - yaxis(2)) < errorThresh
        topNumOnYend = true;
    else
        topNumOnYend = false;
    end

    %determine if last detected x axis number label is at xEnd
    yEndNumAlignment = ynumBBs(end, 2) + ynumBBs(end, 4)/2;
    if abs(yEndNumAlignment - yaxis(1)) < errorThresh
        bottomNumOnYstart = true;
    else
        bottomNumOnYstart = false;
    end
    
    %if ocr wasn't successful, ask for user's input
    if isempty(str2num(xNums{1})) || isempty(str2num(xNums{end}))
        xmin = input('Enter minimum labeled x value: ');
        xmax = input('Enter maximum labeled x value: '); 
    else
        xmin = str2num(xNums{1});
        xmax = str2num(xNums{end});
    end

    if leftNumOnXstart
        xvalues(1) = xmin;
    else 
        %find range of labeled values
        valueDiff = xmax - xmin;
        %find dist those labeled values span over
        labelDist = abs(xnumBBs(1, 1) - xnumBBs(end, 1));
        % determine how far the first number is from the beginnning of the x
        % axis (include width/2 of bounding box)
        firstNumOffset = abs(xnumBBs(1, 1) + xnumBBs(1, 3)/2 - label_margin/2); 
        xvalues(1) = xmin - (firstNumOffset/labelDist) * valueDiff;
    end

    if rightNumOnXend
        xvalues(2) = xmax;
    else 
        %find range of labeled values
        valueDiff = xmax - xmin;
        %find dist those labeled values span over 
        labelDist = abs(xnumBBs(1, 1) - xnumBBs(end, 1));
        % determine how far the last number is from the end of the x axis
        lastNumOffset = abs(xaxis(2) - (xaxis(1)-(label_margin/2)) - xnumBBs(end, 1) + xnumBBs(end, 3)/2); 
        xvalues(2) = xmax + (lastNumOffset/labelDist) * valueDiff;
    end    
    
    if isempty(str2num(yNums{1})) || isempty(str2num(yNums{end}))
        ymin = input('Enter minimum labeled y value: ');
        ymax = input('Enter maximum labeled y value: ');
    else
        ymax = str2num(yNums{1}); 
        ymin = str2num(yNums{end});
    end
        
    if bottomNumOnYstart
        yvalues(1) = ymin;
    else
        %find range of labeled values
        valueDiff = abs(ymax - ymin);
        %find dist those labeled values span over 
        labelDist = abs(ynumBBs(1, 2) - ynumBBs(end, 2));
        % determine dist btwn lowest num and end of the y axis near origin
        lowNumOffset = abs(yaxis(1) - ynumBBs(end, 2) + ynumBBs(end, end)/2);
        if ylinear 
            yvalues(1) = ymin - (lowNumOffset/labelDist) * valueDiff;
        else 
            h = labelDist;
            f = lowNumOffset;
            % <-ymax-------ymin--ycorner--> 
            yvalues(1) = 10^(log10(ymin) - (f/h) * (log10(ymax) - log10(ymin)));    
        end
    end

    if topNumOnYend
        yvalues(2) = ymax;
    else 
        %find range of labeled values
        valueDiff = abs(ymax - ymin);
        %find dist those labeled values span over 
        labelDist = abs(ynumBBs(1, 2) - ynumBBs(end, 2));
        % determine dist btwn lowest num and end of the y axis near origin
        highNumOffset = abs(yaxis(2) - ynumBBs(1, 2) + ynumBBs(1, end)/2); 
        if ylinear 
            yvalues(2) = ymax + (highNumOffset/labelDist) * valueDiff;    
        else 
            h = labelDist;
            f = highNumOffset;
            yvalues(2) = 10^(log10(ymax) + (f/h) * (log10(ymax) - log10(ymin)));    
        end
    end
end


