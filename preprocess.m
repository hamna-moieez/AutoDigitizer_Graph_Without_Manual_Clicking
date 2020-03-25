function imgFile_out = preprocess(imgFile)
    img = imread(imgFile);
    img_gray = rgb2gray(img);
    
    % straighten axes
    img_edge = edge(img_gray, 'Canny');
    [H,T,R] = hough(img_edge);
    peaks = houghpeaks(H,4); %4 bounding lines of graph
    rhos = R(peaks(:,1));
    thetas = T(peaks(:,2));
    rho1 = rhos(1);
    theta1 = thetas(1);
    for i=2:4
        if thetas(i)~=theta1
            theta2 = thetas(i);
            break
        end
    end
    
    theta = min(abs(theta1),abs(theta2));
    img_out = imrotate(img,theta);
    [~,file,ext] = fileparts(imgFile);
    imgFile_out = strcat(file,'_out.',ext);
    imwrite(img_out,imgFile_out);
end