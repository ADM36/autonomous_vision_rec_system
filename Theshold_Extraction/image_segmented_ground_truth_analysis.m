function ground_truth_analysis(filePath, xlsx_data, output_file_name, gaus_weight_threshold)
% Function to plot ground truth of a video sequence to image frames,
% extract the YUV values of each traffic light for each frame, and analyze
% ground truth values for the Y, U and V channels via guassian bell curve methods
% example input: image_segmented_ground_truth_analysis('D:\TrafficLightImages\labeled\Nightime\9419', 'temp4.xlsx', '9419YUV.xlsx',.05)

% Inputs: 
%   
%   filePath (str) --- path to folder of labeled bmp images of traffic lights, ex: D:\TrafficLightImages\labeled\Nightime\9419
%   xlsx_data (str) -- An xlsx data file containing data (including bounding box coordinates) on each traffic light in each frame for a given sequence (needs to be same sequence chosen in filePath input)
%   output_file_name (str) - desired output file name for output xlsx file (file containing YUV channel extracted information)
%   gaus_weight_threshold - (float) gaussian bell curve weighted threshold number for y channel values (what weighted value will we keep y values for in threshold consideration)(recomended default is .05)

%
% Outputs: An XLSX file conatining:
%   
%    Sheet 1: All YUV pixel values for every pixel in true positive light spots (bounding boxes) in each frame
%    Sheet 2: Grouped mean, max and min statistics for all YUV pixel values for every pixel in true positive light spots (bounding boxes) in each frame, grouped by color and image segment (1-8 segments).
%    Sheet 3: Y channel output for the ground truth traffic lights boxes in each frame, with a guassian bell curve applied to filter Y values of importance from center (MEAN) of each traffic light.
%    Sheet 4: Y channel output for the ground truth traffic lights boxes in each frame, with a guassian bell curve applied to filter Y values of importance from MAX Y value of each traffic light.
%    Sheet 5: Statistics (max, mean, min, standrad deviation) on Y channel output with a guassian bell curve applied to filter Y values of importance from center (MEAN) of each traffic light
%    Sheet 6: Statistics (max, mean, min, standrad deviation) on Y channel output with a guassian bell curve applied to filter Y values of importance from max Y value of each traffic light
%    Sheet 7: U channel output for the ground truth traffic lights boxes in each frame, with a guassian bell curve applied to filter U values of importance from center (MEAN) of each traffic light.
%    Sheet 8: U channel output for the ground truth traffic lights boxes in each frame, with a guassian bell curve applied to filter U values of importance from MAX Y value of each traffic light.
%    Sheet 9: Statistics (max, mean, min, standrad deviation) on U channel output with a guassian bell curve applied to filter U values of importance from center (MEAN) of each traffic light
%    Sheet 10: Statistics (max, mean, min, standrad deviation) on U channel output with a guassian bell curve applied to filter U values of importance from max Y value of each traffic light
%    Sheet 11: V channel output for the ground truth traffic lights boxes in each frame, with a guassian bell curve applied to filter V values of importance from center (MEAN) of each traffic light.
%    Sheet 12: V channel output for the ground truth traffic lights boxes in each frame, with a guassian bell curve applied to filter V values of importance from MAX Y value of each traffic light.
%    Sheet 13: Statistics (max, mean, min, standrad deviation) on V channel output with a guassian bell curve applied to filter V values of importance from center (MEAN) of each traffic light
%    Sheet 14: Statistics (max, mean, min, standrad deviation) on V channel output with a guassian bell curve applied to filter V values of importance from max Y value of each traffic light

%
%   Image files for each frame in a video sequence, with ground truth
%   bounding boxes around each traffic light



msg = ['Completed: ' filePath];
display(msg);


path = filePath; % choose sequence file path

files = dir(strcat(path,'\*.bmp')); % grab all image files in given folder for a sequence

sequence_data = readtable(xlsx_data); % read xlsx data into a table

toDelete = sequence_data.visible == false; % ignores traffic lights which are marked as ground truth but not visible
sequence_data(toDelete,:) = [];  % ignores traffic lights which are marked as ground truth but not visible

toDeleteTwo = ismember(sequence_data.Visibility,'partially_occluded'); % ignores traffic lights which are partially ocluded
sequence_data(toDeleteTwo,:) = [];  % ignores traffic lights which are marked as ground truth but not visible


tag = '.bmp';


empty_table = table; % create an empty table

y_gaus = table; % create an empty table for gaussian normal data - centered on center of image

y_max_num_gaus = table; % create an empty table for gaussian data - centrered on max Y value of image

u_gaus = table; % create an empty table for gaussian normal data - centered on center of image

u_max_num_gaus = table; % create an empty table for gaussian data - centrered on max U value of image

v_gaus = table; % create an empty table for gaussian normal data - centered on center of image

v_max_num_gaus = table; % create an empty table for gaussian data - centrered on max V value of image

%%%


for i = 1 : size(files); % iterate through data structure of file names
    
    baseFileName = files(i).name;
    fullFileName = fullfile(path, baseFileName);
    
    frame = imread(fullFileName); % read in one image frame
    
    %%
    
    %%% BELOW CODE (LINE 87) ADDS GAUSSIAN NOISE TO IMAGE FOR THRESHOLD DEVELOPMENT,
    %%% IF DESIRED
    
    %frame = imgaussfilt3(frame);
    
    %%
        
    ctr_frame = strsplit(baseFileName, '_');
    
    ctr_frame = str2double(ctr_frame(1,2));
    
    ctr_frame = ctr_frame + 1; % add one to frame number to align with xml data (img file name and frame number off by one)
    
    rows = sequence_data.frameNumber == ctr_frame;
    vars = {'x','y','xs','ys'};

    light_spots = sequence_data{rows, vars};

    [r,c] = size(light_spots);
    
    lines = @(x) size(x,1); % lines(x) calculates number of lines in matrix x


    
    for i = 1 : lines(light_spots); %iterate through frame by each true positive traffic light
        profrow = light_spots(i,:);
        
        m = sequence_data.x == profrow(1);
        T_result = sequence_data.light_color(m,:); %take the color associated with the x,y coordinates
        
        if length(T_result) > 1; %sometimes T_result (color associated with bounding box, is longer then one color name, unsure why at tius point
            T_result = T_result(1,1);
        end
        
        x = profrow(1) - (profrow(3)/2); % take x and y values and update to center around light spot, to properly frame bounding box around traffic light
        y = profrow(2) - (profrow(4)/2);

        newrow = [x,y,profrow(3),profrow(4)]; 
        
        
            if newrow(2) < 161; % determine which image segment (1-8) the traffic light is located in and assign image segment number appropriately 
                image_segment = '1';
            elseif newrow(2) < 321;
                image_segment = '2';
            elseif newrow(2) < 481;
                image_segment = '3';
            elseif newrow(2) < 641;
                image_segment = '4';
            elseif newrow(2) < 801;
                image_segment = '5';
            elseif newrow(2) < 961;
                image_segment = '6';
            elseif newrow(2) < 1121;
                image_segment = '7';
            else
                image_segment = '8';
            end;
        
        
        true_pos = imcrop(frame, newrow); %crop an image of the true positive pixels of a traffic light


        Y = true_pos(:,:,1); % get the true positive YUV values for a traffic light

        U = true_pos(:,:,2);

        V = true_pos(:,:,3);
        
        
            channel = Y; %starts block to get Y channel values from gaussian normal bell curve
    
            len = 1:size(channel,1);

            wid = 1:size(channel,2);

            [X1,X2] = meshgrid(len,wid);

            center_loc=num2cell(ceil(size(channel)/2)); %find center point of bounding box traffic light

            X = [X1(:) X2(:)];

            testtest = mvnpdf(X,(cell2mat(center_loc)),eye(2)); %mvnpdf(X,mu,sigma) returns pdf values of points in X, where sigma determines the covariance of each associated multivariate normal distribution

            y = reshape(testtest,size(X2,2),size(X2,1));

            y_channel_gaus = double(channel).*(y>gaus_weight_threshold); %extract channel values greater than gaussian weighting threshold
    
            y_channel_gaus = reshape(y_channel_gaus',[],1);



            Color = char.empty;
            Image_Segment = char.empty;

            for i = 1 : length(y_channel_gaus);
                Color = [Color, T_result]; % get color of TL and TP result (TP or FN)
                Image_Segment = [Image_Segment, cellstr(image_segment)]; % get the image segment (1-8) of TL location
            end
            

            Color = reshape(Color',[],1);
            
            Image_Segment = reshape(Image_Segment',[],1);

            stats = table(Color,Image_Segment,y_channel_gaus); % create tanle containing color, image segment and channel values

            y_gaus = [y_gaus; stats];



            [max_num, max_idx]=max(Y(:)); %starts block to get Y channel values from gaussian normal bell curve with center at max value in image
    
            [horizontal,vertical]=ind2sub(size(Y),max_idx);


            testagain = mvnpdf(X,[horizontal vertical],eye(2)); %mvnpdf(X,mu,sigma) returns pdf values of points in X, where sigma determines the covariance of each associated multivariate normal distribution

            y = reshape(testagain,size(X2,2),size(X2,1));

            y_channel_gaus_max = double(channel).*(y>gaus_weight_threshold); %extract channel values greater than gaussian weighting threshold
    
            y_channel_gaus_max = reshape(y_channel_gaus_max',[],1);
            
            Color = char.empty;
            Image_Segment = char.empty;

            for i = 1 : length(y_channel_gaus_max);
                Color = [Color, T_result];
                Image_Segment = [Image_Segment, cellstr(image_segment)];
            end
            

            Color = reshape(Color',[],1);
            
            Image_Segment = reshape(Image_Segment',[],1);
            
            stats = table(Color,Image_Segment, y_channel_gaus_max);% create tanle containing color, image segment and channel values

            y_max_num_gaus = [y_max_num_gaus; stats];
            
            
            
            
            
            
            channel = U; %starts block to get U channel values from gaussian normal bell curve
    
            len = 1:size(channel,1);

            wid = 1:size(channel,2);

            [X1,X2] = meshgrid(len,wid);

            center_loc=num2cell(ceil(size(channel)/2)); %find center point of bounding box traffic light

            X = [X1(:) X2(:)];

            testtest = mvnpdf(X,(cell2mat(center_loc)),eye(2)); %mvnpdf(X,mu,sigma) returns pdf values of points in X, where sigma determines the covariance of each associated multivariate normal distribution

            u = reshape(testtest,size(X2,2),size(X2,1));

            u_channel_gaus = double(channel).*(u>gaus_weight_threshold); %extract channel values greater than gaussian weighting threshold
    
            u_channel_gaus = reshape(u_channel_gaus',[],1);

%%%%%%

            Color = char.empty;
            
            Image_Segment = char.empty;

            for i = 1 : length(u_channel_gaus);
                Color = [Color, T_result];
                Image_Segment = [Image_Segment, cellstr(image_segment)];
            end
            

            Color = reshape(Color',[],1);
            
            Image_Segment = reshape(Image_Segment',[],1);

            stats = table(Color,Image_Segment, u_channel_gaus);% create tanle containing color, image segment and channel values

            u_gaus = [u_gaus; stats];



            [max_num, max_idx]=max(U(:)); %starts block to get U channel calues from gaussian normal bell curve with center at max value in image
    
            [horizontal,vertical]=ind2sub(size(U),max_idx);


            testagain = mvnpdf(X,[horizontal vertical],eye(2)); %mvnpdf(X,mu,sigma) returns pdf values of points in X, where sigma determines the covariance of each associated multivariate normal distribution.

            u = reshape(testagain,size(X2,2),size(X2,1));

            u_channel_gaus_max = double(channel).*(u>gaus_weight_threshold); %extract channel values greater than gaussian weighting threshold
    
            u_channel_gaus_max = reshape(u_channel_gaus_max',[],1);
            
            Color = char.empty;
            
            Image_Segment = char.empty;

            for i = 1 : length(u_channel_gaus_max);
                Color = [Color, T_result];
                Image_Segment = [Image_Segment, cellstr(image_segment)];
            end

            Color = reshape(Color',[],1);
            
            Image_Segment = reshape(Image_Segment',[],1);

            stats = table(Color,Image_Segment, u_channel_gaus_max);% create tanle containing color, image segment and channel values

            u_max_num_gaus = [u_max_num_gaus; stats];



            
            
            
            
            
            
            channel = V; %starts block to get V channel values from gaussian normal bell curve
    
            len = 1:size(channel,1);

            wid = 1:size(channel,2);

            [X1,X2] = meshgrid(len,wid);

            center_loc=num2cell(ceil(size(channel)/2)); %find center point of bounding box traffic light

            X = [X1(:) X2(:)];

            testtest = mvnpdf(X,(cell2mat(center_loc)),eye(2)); %mvnpdf(X,mu,sigma) returns pdf values of points in X, where sigma determines the covariance of each associated multivariate normal distribution

            v = reshape(testtest,size(X2,2),size(X2,1));

            v_channel_gaus = double(channel).*(v>gaus_weight_threshold); %extract channel values greater than gaussian weighting threshold
    
            v_channel_gaus = reshape(v_channel_gaus',[],1);

%%%%%%

            Color = char.empty;
            
            Image_Segment = char.empty;

            for i = 1 : length(v_channel_gaus);
                Color = [Color, T_result];
                Image_Segment = [Image_Segment, cellstr(image_segment)];
            end
            

            Color = reshape(Color',[],1);
            
            Image_Segment = reshape(Image_Segment',[],1);

            stats = table(Color, Image_Segment, v_channel_gaus);% create tanle containing color, image segment and channel values

            v_gaus = [v_gaus; stats];



            [max_num, max_idx]=max(V(:)); %starts block to get V channel calues from gaussian normal bell curve with center at max value in image
    
            [horizontal,vertical]=ind2sub(size(V),max_idx);


            testagain = mvnpdf(X,[horizontal vertical],eye(2)); %mvnpdf(X,mu,sigma) returns pdf values of points in X, where sigma determines the covariance of each associated multivariate normal distribution

            v = reshape(testagain,size(X2,2),size(X2,1));

            v_channel_gaus_max = double(channel).*(v>gaus_weight_threshold); %extract channel values greater than gaussian weighting threshold
    
            v_channel_gaus_max = reshape(v_channel_gaus_max',[],1);
            
            Color = char.empty;
            
            Image_Segment = char.empty;

            for i = 1 : length(v_channel_gaus_max);
                Color = [Color, T_result];
                Image_Segment = [Image_Segment, cellstr(image_segment)];
            end
            

            Color = reshape(Color',[],1);
            
            Image_Segment = reshape(Image_Segment',[],1);

            stats = table(Color,Image_Segment, v_channel_gaus_max);% create tanle containing color, image segment and channel values

            v_max_num_gaus = [v_max_num_gaus; stats];

            
            
            
            

        Y = reshape(Y',[],1);

        U = reshape(U',[],1);

        V = reshape(V',[],1);

        Color = char.empty;
        Image_Segment = char.empty;

        for i = 1 : length(Y);
            Color = [Color, T_result];
            Image_Segment = [Image_Segment, cellstr(image_segment)];
        end
            

        Color = reshape(Color',[],1);
            
        Image_Segment = reshape(Image_Segment',[],1);

        A = table(Color,Image_Segment, Y,U,V); %create a table with the color associated with each pixel and its asssociated YUV values for a traffic light
        
        empty_table = [empty_table; A]; % append data for each traffic light to empty_table
        
        %%%

        frame = insertShape(frame,'Rectangle',[newrow],'LineWidth',1); % add light spot bounding box to image

    end   
    
    name = int2str(ctr_frame - 1);

    framename = strcat('frame_', name);

    S = strcat(framename, tag);

    imwrite(frame, S); % save ground truth image 
    
end

writetable(empty_table,output_file_name,'Sheet','TP_YUV_Values'); % write table of all YUV pixel values for true positive light spots to file

writetable(grpstats(empty_table, {'Color', 'Image_Segment'}, {'min', 'max', 'mean'}),output_file_name,'Sheet','TP_YUV_Statistics');

%write Y channel gaussian data
y_gaus(~y_gaus.y_channel_gaus,:) = []; % get rid of zero values

y_max_num_gaus(~y_max_num_gaus.y_channel_gaus_max,:) = []; % get rid of zero values

writetable(y_gaus,output_file_name,'Sheet','Gaus_Mean_Y_Values');

writetable(y_max_num_gaus,output_file_name,'Sheet','Gaus_Max_Y_Values');

writetable(grpstats(y_gaus, {'Color', 'Image_Segment'}, {'min', 'max', 'mean', 'std'}),output_file_name,'Sheet','Gaus_Mean_Y_Statistics');

writetable(grpstats(y_max_num_gaus, {'Color', 'Image_Segment'}, {'min', 'max', 'mean', 'std'}),output_file_name,'Sheet','Gaus_Max_Y_Statistics');

%write U channel gaussian data
u_gaus(~u_gaus.u_channel_gaus,:) = []; % get rid of zero values

u_max_num_gaus(~u_max_num_gaus.u_channel_gaus_max,:) = []; % get rid of zero values

writetable(u_gaus,output_file_name,'Sheet','Gaus_Mean_U_Values');

writetable(u_max_num_gaus,output_file_name,'Sheet','Gaus_Max_U_Values');

writetable(grpstats(u_gaus, {'Color', 'Image_Segment'}, {'min', 'max', 'mean', 'std'}),output_file_name,'Sheet','Gaus_Mean_U_Statistics');

writetable(grpstats(u_max_num_gaus, {'Color', 'Image_Segment'}, {'min', 'max', 'mean', 'std'}),output_file_name,'Sheet','Gaus_Max_U_Statistics');

%write V channel gaussian data
v_gaus(~v_gaus.v_channel_gaus,:) = []; % get rid of zero values

v_max_num_gaus(~v_max_num_gaus.v_channel_gaus_max,:) = []; % get rid of zero values

writetable(v_gaus,output_file_name,'Sheet','Gaus_Mean_V_Values');

writetable(v_max_num_gaus,output_file_name,'Sheet','Gaus_Max_V_Values');

writetable(grpstats(v_gaus, {'Color', 'Image_Segment'}, {'min', 'max', 'mean', 'std'}),output_file_name,'Sheet','Gaus_Mean_V_Statistics');

writetable(grpstats(v_max_num_gaus, {'Color', 'Image_Segment'}, {'min', 'max', 'mean', 'std'}),output_file_name,'Sheet','Gaus_Max_V_Statistics');


msg = ['File published: ' output_file_name];
display(msg);

end

