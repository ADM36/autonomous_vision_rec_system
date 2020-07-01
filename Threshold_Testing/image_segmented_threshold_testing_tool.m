function test_YUV_threshold(filePath, xlsx_data, output_file_name, threshold_type, threshold_values)
% Function to test inputed YUV channel thresholds on a video sequence of traffic light images
% example input: image_segmented_threshold_testing_tool('D:\TrafficLightImages\labeled\Daytime\9474', 'temp24.xlsx', '9474red_UOPEN.xlsx', 'Gmean_SD', {[160, 42, 255, 0, 203, 142
%];[160, 42, 255, 0, 203, 142
%];[160, 42, 255, 0, 203, 142
%];[185, 75, 255, 0, 210, 162
%];[211, 82, 255, 0, 210, 141
%];[211, 82, 255, 0, 210, 141
%];[211, 82, 255, 0, 210, 141
%];[211, 82, 255, 0, 210, 141
%]})

% Inputs: 
%   filePath (str) --- path to folder of labeled bmp images of traffic lights, ex: D:\TrafficLightImages\labeled\9419
%   xlsx_data (str) -- An xlsx data file containing data on each traffic light in
%   each frame, specifically bounding box coordinates
%   output_file_name (str) - desired output file name for output xlsx file
%   threshold_type (str) - the method used to derive the thresholds being tested
%   (ex: Gmean_SD are thresholds derived from Gaussian Mean methods and a
%   lower-bound of one standard deviation below the mean channel value
%   threshold_values (list of lists of int) - 8 cells of 8 arrays of threshold values for each of the Y, U
%   and V channels - ex: [200 150 134 127 122 105] (Y, then U, then V
%   channel)
%
% Outputs: An XLSX file conatining:
%   Sheet 1: % All Truue Positive traffic lights within the provided video
%   sequence, including the traffic light color, the image segment the
%   traffic light is located in, the number of pixels detected in that
%   light using the provided threshold, the ratio of pixels detected/total
%   pixels in bounding box and whether the true positive was classified as
%   a true positive or false negative
%   Sheet 2: % Every frame within a video sequence, including the total
%   number of non-black pixels detected in the image, how many of those
%   pixels are true positive pixels (in a bounding box and how many pixels
%   are false positive pixels (not in a bounding box).
%   Sheet 3: % Summary statistics on traffic lights by color and image
%   segment, including group count for the category, minimum number of
%   pixels detected for true positives in that category, maxmimum pixels
%   detected, mean number of pixels and the standard deviation of the
%   number of pixels detected for that category
%   
%   OPTIONAL
%   Two image files for each frame in a video sequence:
%   One containing the binary detected ground truth traffic lights after applying filtering masks 
%   One contatining the YUV values for each detected ground truth traffic
%   light after applying filtering masks 

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

new_table = table; %create an empty table

TPP = table; %create an empty table

filtered_pixels_table = table; %create an empty table

for i = 1 : size(files); % iterate through data structure of file names
    
    baseFileName = files(i).name;
    fullFileName = fullfile(path, baseFileName);
    
    frame = imread(fullFileName); % read in one image frame
    
        seg1 = imcrop(frame, [1 1 1920 159]); %1/8 of total image frame, each segment corresponds to an input threshold
        
        seg2 = imcrop(frame, [1 161 1920 159]);
        
        seg3 = imcrop(frame, [1 321 1920 159]);
        
        seg4 = imcrop(frame, [1 481 1920 159]);
        
        seg5 = imcrop(frame, [1 641 1920 159]);
        
        seg6 = imcrop(frame, [1 801 1920 159]);
        
        seg7 = imcrop(frame, [1 961 1920 159]);
        
        seg8 = imcrop(frame, [1 1121 1920 159]);
    
    
    ctr_frame = strsplit(baseFileName, '_');
    
    ctr_frame = str2double(ctr_frame(1,2));
    
    ctr_frame = ctr_frame + 1; % add one to frame number to align with xml data (img file name and frame number of by one)
    
    rows = sequence_data.frameNumber == ctr_frame;
    vars = {'x','y','xs','ys'};

    light_spots = sequence_data{rows, vars};

    [r,c] = size(light_spots);
    
    lines = @(x) size(x,1); % lines(x) calculates number of lines in matrix x
    
    comparison_gt = frame;

    comparison_gt(:, :, :) = 0; %create black image to use as comparison image, adding bounding boxes to it
    
    true_pos_pixels = 0; % initialize counter for number of true positive pixels in each bounding box in each frame
    

        for i = 1 : lines(light_spots); %iterate through each ground truth traffic light in frame
        profrow = light_spots(i,:);

        m = sequence_data.x ==profrow(1);
        T_result = sequence_data.light_color(m,:);
        
        if length(T_result) > 1;
            T_result = T_result(1,1);
        end

        x = profrow(1) - (profrow(3)/2); %update location of bounding box to be centered to traffic light
        y = profrow(2) - (profrow(4)/2);

        newrow = [x,y,profrow(3),profrow(4)];
        
            % below assigns the correct segment number (1-8) to a TL (traffic light)
            if newrow(2) < 161;
                image_segment = '1';
                segYBand = seg1(:,:, 1); % extract YUV channel pixel values, by channel
                segUBand = seg1(:,:, 2);
                segVBand = seg1(:,:, 3);
                segYMask = (segYBand >= threshold_values{1,1}(1,2) & segYBand <= threshold_values{1,1}(1,1)); % create image masks for YUV thresholds provided
                segUMask = (segUBand >= threshold_values{1,1}(1,4) & segUBand <= threshold_values{1,1}(1,3));
                segVMask = (segVBand >= threshold_values{1,1}(1,6) & segVBand <= threshold_values{1,1}(1,5));
                segYUVObjectsMask = uint8(segYMask & segUMask & segVMask);
                
                segmaskedyuvImage = uint8(zeros(size(segYUVObjectsMask)));
                
                segmaskedyuvImage(:,:,1) = seg1(:,:,1) .* segYUVObjectsMask;
                segmaskedyuvImage(:,:,2) = seg1(:,:,2) .* uint8(segUMask);
                segmaskedyuvImage(:,:,3) = seg1(:,:,3) .* uint8(segVMask);
            elseif newrow(2) < 321;
                image_segment = '2';
                segYBand = seg2(:,:, 1); % extract YUV channel pixel values, by channel
                segUBand = seg2(:,:, 2);
                segVBand = seg2(:,:, 3);
                segYMask = (segYBand >= threshold_values{2,1}(1,2) & segYBand <= threshold_values{2,1}(1,1)); % create image masks for YUV thresholds provided
                segUMask = (segUBand >= threshold_values{2,1}(1,4) & segUBand <= threshold_values{2,1}(1,3));
                segVMask = (segVBand >= threshold_values{2,1}(1,6) & segVBand <= threshold_values{2,1}(1,5));
                segYUVObjectsMask = uint8(segYMask & segUMask & segVMask);
                
                segmaskedyuvImage = uint8(zeros(size(segYUVObjectsMask)));
                
                segmaskedyuvImage(:,:,1) = seg2(:,:,1) .* segYUVObjectsMask;
                segmaskedyuvImage(:,:,2) = seg2(:,:,2) .* uint8(segUMask);
                segmaskedyuvImage(:,:,3) = seg2(:,:,3) .* uint8(segVMask);
            elseif newrow(2) < 481;
                image_segment = '3';
                segYBand = seg3(:,:, 1); % extract YUV channel pixel values, by channel
                segUBand = seg3(:,:, 2);
                segVBand = seg3(:,:, 3);
                segYMask = (segYBand >= threshold_values{3,1}(1,2) & segYBand <= threshold_values{3,1}(1,1)); % create image masks for YUV thresholds provided
                segUMask = (segUBand >= threshold_values{3,1}(1,4) & segUBand <= threshold_values{3,1}(1,3));
                segVMask = (segVBand >= threshold_values{3,1}(1,6) & segVBand <= threshold_values{3,1}(1,5));
                segYUVObjectsMask = uint8(segYMask & segUMask & segVMask);

                segmaskedyuvImage = uint8(zeros(size(segYUVObjectsMask)));
                
                segmaskedyuvImage(:,:,1) = seg3(:,:,1) .* segYUVObjectsMask;
                segmaskedyuvImage(:,:,2) = seg3(:,:,2) .* uint8(segUMask);
                segmaskedyuvImage(:,:,3) = seg3(:,:,3) .* uint8(segVMask);                
            elseif newrow(2) < 641;
                image_segment = '4';
                segYBand = seg4(:,:, 1); % extract YUV channel pixel values, by channel
                segUBand = seg4(:,:, 2);
                segVBand = seg4(:,:, 3);
                segYMask = (segYBand >= threshold_values{4,1}(1,2) & segYBand <= threshold_values{4,1}(1,1)); % create image masks for YUV thresholds provided
                segUMask = (segUBand >= threshold_values{4,1}(1,4) & segUBand <= threshold_values{4,1}(1,3));
                segVMask = (segVBand >= threshold_values{4,1}(1,6) & segVBand <= threshold_values{4,1}(1,5));
                segYUVObjectsMask = uint8(segYMask & segUMask & segVMask);
                
                segmaskedyuvImage = uint8(zeros(size(segYUVObjectsMask)));
                
                segmaskedyuvImage(:,:,1) = seg4(:,:,1) .* segYUVObjectsMask;
                segmaskedyuvImage(:,:,2) = seg4(:,:,2) .* uint8(segUMask);
                segmaskedyuvImage(:,:,3) = seg4(:,:,3) .* uint8(segVMask);                
            elseif newrow(2) < 801;
                image_segment = '5';
                segYBand = seg5(:,:, 1); % extract YUV channel pixel values, by channel
                segUBand = seg5(:,:, 2);
                segVBand = seg5(:,:, 3);
                segYMask = (segYBand >= threshold_values{5,1}(1,2) & segYBand <= threshold_values{5,1}(1,1)); % create image masks for YUV thresholds provided
                segUMask = (segUBand >= threshold_values{5,1}(1,4) & segUBand <= threshold_values{5,1}(1,3));
                segVMask = (segVBand >= threshold_values{5,1}(1,6) & segVBand <= threshold_values{5,1}(1,5));
                segYUVObjectsMask = uint8(segYMask & segUMask & segVMask);
                
                segmaskedyuvImage = uint8(zeros(size(segYUVObjectsMask)));
                
                segmaskedyuvImage(:,:,1) = seg5(:,:,1) .* segYUVObjectsMask;
                segmaskedyuvImage(:,:,2) = seg5(:,:,2) .* uint8(segUMask);
                segmaskedyuvImage(:,:,3) = seg5(:,:,3) .* uint8(segVMask);                
            elseif newrow(2) < 961;
                image_segment = '6';
                segYBand = seg6(:,:, 1); % extract YUV channel pixel values, by channel
                segUBand = seg6(:,:, 2);
                segVBand = seg6(:,:, 3);
                segYMask = (segYBand >= threshold_values{6,1}(1,2) & segYBand <= threshold_values{6,1}(1,1)); % create image masks for YUV thresholds provided
                segUMask = (segUBand >= threshold_values{6,1}(1,4) & segUBand <= threshold_values{6,1}(1,3));
                segVMask = (segVBand >= threshold_values{6,1}(1,6) & segVBand <= threshold_values{6,1}(1,5));
                segYUVObjectsMask = uint8(segYMask & segUMask & segVMask);
                
                segmaskedyuvImage = uint8(zeros(size(segYUVObjectsMask)));
                
                segmaskedyuvImage(:,:,1) = seg6(:,:,1) .* segYUVObjectsMask;
                segmaskedyuvImage(:,:,2) = seg6(:,:,2) .* uint8(segUMask);
                segmaskedyuvImage(:,:,3) = seg6(:,:,3) .* uint8(segVMask);                
            elseif newrow(2) < 1121;
                image_segment = '7';
                segYBand = seg7(:,:, 1); % extract YUV channel pixel values, by channel
                segUBand = seg7(:,:, 2);
                segVBand = seg7(:,:, 3);
                segYMask = (segYBand >= threshold_values{7,1}(1,2) & segYBand <= threshold_values{7,1}(1,1)); % create image masks for YUV thresholds provided
                segUMask = (segUBand >= threshold_values{7,1}(1,4) & segUBand <= threshold_values{7,1}(1,3));
                segVMask = (segVBand >= threshold_values{7,1}(1,6) & segVBand <= threshold_values{7,1}(1,5));
                segYUVObjectsMask = uint8(segYMask & segUMask & segVMask);
                
                segmaskedyuvImage = uint8(zeros(size(segYUVObjectsMask)));
                
                segmaskedyuvImage(:,:,1) = seg7(:,:,1) .* segYUVObjectsMask;
                segmaskedyuvImage(:,:,2) = seg7(:,:,2) .* uint8(segUMask);
                segmaskedyuvImage(:,:,3) = seg7(:,:,3) .* uint8(segVMask);                
            else
                image_segment = '8';
                segYBand = seg8(:,:, 1); % extract YUV channel pixel values, by channel
                segUBand = seg8(:,:, 2);
                segVBand = seg8(:,:, 3);
                segYMask = (segYBand >= threshold_values{8,1}(1,2) & segYBand <= threshold_values{8,1}(1,1)); % create image masks for YUV thresholds provided
                segUMask = (segUBand >= threshold_values{8,1}(1,4) & segUBand <= threshold_values{8,1}(1,3));
                segVMask = (segVBand >= threshold_values{8,1}(1,6) & segVBand <= threshold_values{8,1}(1,5));
                segYUVObjectsMask = uint8(segYMask & segUMask & segVMask);
                
                segmaskedyuvImage = uint8(zeros(size(segYUVObjectsMask)));
                
                segmaskedyuvImage(:,:,1) = seg8(:,:,1) .* segYUVObjectsMask;
                segmaskedyuvImage(:,:,2) = seg8(:,:,2) .* uint8(segUMask);
                segmaskedyuvImage(:,:,3) = seg8(:,:,3) .* uint8(segVMask);                
            end;        
        
    
    
        Y = y - ((str2num(image_segment) - 1) * 160); %have to multiply by 160 to find the correct y axis value accordin to whole image frame, not just cropped image segment
        segrow = [x,Y,profrow(3),profrow(4)];
        
        true_pos = imcrop(segmaskedyuvImage(:,:,1), segrow); % extract bounding boxes from image
        
        tp_box_pixels = nnz(true_pos); %get number of pixels in one bounding box
        
        true_pos_pixels = true_pos_pixels + nnz(true_pos); %iterate through true positive bounding boxes to get total number of true positive pixels identified per frame
        
        dimensions = size(true_pos);
        
        dims_totes = dimensions(1) * dimensions(2);
        
        ratio = tp_box_pixels/dims_totes;
        
        if ratio >= 0.25; %hard coded ratio to determine if we count traffic light as TP. Example: 0.25 means that 25% or more of the pixels in the traffic light bounding box need to have been detected to count as a TP TL
            evaluation = 'TP';
        else
            evaluation = 'FN';
        end
        
        Image_Segment = cellstr(image_segment);
        
        Frame_Number = cellstr(num2str(ctr_frame));
        
        one_box_pixels = table(T_result, Image_Segment, tp_box_pixels, ratio, cellstr(evaluation), Frame_Number); %create table to collect number of TP pixels in each bounding box
        
        TPP = [TPP; one_box_pixels]; % add number of TP pixels and traffic light color to table
        

        end
        
        
    %%
    % BELOW CODE BLOCK IS TO GET NUMBER OF FALSE POSITIVE PIXELS IN A
    % SPECIFIC FRAME BY ADDING FALSE POSITIVE PICELS OF EACH SEGMENT
   
    
                total_frame_pixels = 0; % initialize counter for number of false positive pixels in each frame

    
                segYBand = seg1(:,:, 1); % extract YUV channel pixel values, by channel
                segUBand = seg1(:,:, 2);
                segVBand = seg1(:,:, 3);
                segYMask = (segYBand >= threshold_values{1,1}(1,2) & segYBand <= threshold_values{1,1}(1,1)); % create image masks for YUV thresholds provided
                segUMask = (segUBand >= threshold_values{1,1}(1,4) & segUBand <= threshold_values{1,1}(1,3));
                segVMask = (segVBand >= threshold_values{1,1}(1,6) & segVBand <= threshold_values{1,1}(1,5));
                segYUVObjectsMask = uint8(segYMask & segUMask & segVMask);
                
                segmaskedyuvImage = uint8(zeros(size(segYUVObjectsMask)));
                
                segmaskedyuvImage(:,:,1) = seg1(:,:,1) .* segYUVObjectsMask;
                segmaskedyuvImage(:,:,2) = seg1(:,:,2) .* uint8(segUMask);
                segmaskedyuvImage(:,:,3) = seg1(:,:,3) .* uint8(segVMask);
                
                new_seg1 = segmaskedyuvImage(:,:,1);
                total_frame_pixels = (total_frame_pixels + nnz(segmaskedyuvImage(:,:,1))); 
                

                image_segment = '2';
                segYBand = seg2(:,:, 1); % extract YUV channel pixel values, by channel
                segUBand = seg2(:,:, 2);
                segVBand = seg2(:,:, 3);
                segYMask = (segYBand >= threshold_values{2,1}(1,2) & segYBand <= threshold_values{2,1}(1,1)); % create image masks for YUV thresholds provided
                segUMask = (segUBand >= threshold_values{2,1}(1,4) & segUBand <= threshold_values{2,1}(1,3));
                segVMask = (segVBand >= threshold_values{2,1}(1,6) & segVBand <= threshold_values{2,1}(1,5));
                segYUVObjectsMask = uint8(segYMask & segUMask & segVMask);
                
                segmaskedyuvImage = uint8(zeros(size(segYUVObjectsMask)));
                
                segmaskedyuvImage(:,:,1) = seg2(:,:,1) .* segYUVObjectsMask;
                segmaskedyuvImage(:,:,2) = seg2(:,:,2) .* uint8(segUMask);
                segmaskedyuvImage(:,:,3) = seg2(:,:,3) .* uint8(segVMask);
                
                new_seg2 = segmaskedyuvImage(:,:,1);
                total_frame_pixels = (total_frame_pixels + nnz(segmaskedyuvImage(:,:,1))); 


                
                image_segment = '3';
                segYBand = seg3(:,:, 1); % extract YUV channel pixel values, by channel
                segUBand = seg3(:,:, 2);
                segVBand = seg3(:,:, 3);
                segYMask = (segYBand >= threshold_values{3,1}(1,2) & segYBand <= threshold_values{3,1}(1,1)); % create image masks for YUV thresholds provided
                segUMask = (segUBand >= threshold_values{3,1}(1,4) & segUBand <= threshold_values{3,1}(1,3));
                segVMask = (segVBand >= threshold_values{3,1}(1,6) & segVBand <= threshold_values{3,1}(1,5));
                segYUVObjectsMask = uint8(segYMask & segUMask & segVMask);
                
                segmaskedyuvImage = uint8(zeros(size(segYUVObjectsMask)));
                
                segmaskedyuvImage(:,:,1) = seg3(:,:,1) .* segYUVObjectsMask;
                segmaskedyuvImage(:,:,2) = seg3(:,:,2) .* uint8(segUMask);
                segmaskedyuvImage(:,:,3) = seg3(:,:,3) .* uint8(segVMask);        
                
                new_seg3 = segmaskedyuvImage(:,:,1);
                total_frame_pixels = (total_frame_pixels + nnz(segmaskedyuvImage(:,:,1))); 


                
                image_segment = '4';
                segYBand = seg4(:,:, 1); % extract YUV channel pixel values, by channel
                segUBand = seg4(:,:, 2);
                segVBand = seg4(:,:, 3);
                segYMask = (segYBand >= threshold_values{4,1}(1,2) & segYBand <= threshold_values{4,1}(1,1)); % create image masks for YUV thresholds provided
                segUMask = (segUBand >= threshold_values{4,1}(1,4) & segUBand <= threshold_values{4,1}(1,3));
                segVMask = (segVBand >= threshold_values{4,1}(1,6) & segVBand <= threshold_values{4,1}(1,5));
                segYUVObjectsMask = uint8(segYMask & segUMask & segVMask);
                
                segmaskedyuvImage = uint8(zeros(size(segYUVObjectsMask)));
                
                segmaskedyuvImage(:,:,1) = seg4(:,:,1) .* segYUVObjectsMask;
                segmaskedyuvImage(:,:,2) = seg4(:,:,2) .* uint8(segUMask);
                segmaskedyuvImage(:,:,3) = seg4(:,:,3) .* uint8(segVMask); 
                
                new_seg4 = segmaskedyuvImage(:,:,1);
                total_frame_pixels = (total_frame_pixels + nnz(segmaskedyuvImage(:,:,1))); 

                
                image_segment = '5';
                segYBand = seg5(:,:, 1); % extract YUV channel pixel values, by channel
                segUBand = seg5(:,:, 2);
                segVBand = seg5(:,:, 3);
                segYMask = (segYBand >= threshold_values{5,1}(1,2) & segYBand <= threshold_values{5,1}(1,1)); % create image masks for YUV thresholds provided
                segUMask = (segUBand >= threshold_values{5,1}(1,4) & segUBand <= threshold_values{5,1}(1,3));
                segVMask = (segVBand >= threshold_values{5,1}(1,6) & segVBand <= threshold_values{5,1}(1,5));
                segYUVObjectsMask = uint8(segYMask & segUMask & segVMask);
                
                segmaskedyuvImage = uint8(zeros(size(segYUVObjectsMask)));
                
                segmaskedyuvImage(:,:,1) = seg5(:,:,1) .* segYUVObjectsMask;
                segmaskedyuvImage(:,:,2) = seg5(:,:,2) .* uint8(segUMask);
                segmaskedyuvImage(:,:,3) = seg5(:,:,3) .* uint8(segVMask);                


                new_seg5 = segmaskedyuvImage(:,:,1);
                total_frame_pixels = (total_frame_pixels + nnz(segmaskedyuvImage(:,:,1))); 

                                
                image_segment = '6';
                segYBand = seg6(:,:, 1); % extract YUV channel pixel values, by channel
                segUBand = seg6(:,:, 2);
                segVBand = seg6(:,:, 3);
                segYMask = (segYBand >= threshold_values{6,1}(1,2) & segYBand <= threshold_values{6,1}(1,1)); % create image masks for YUV thresholds provided
                segUMask = (segUBand >= threshold_values{6,1}(1,4) & segUBand <= threshold_values{6,1}(1,3));
                segVMask = (segVBand >= threshold_values{6,1}(1,6) & segVBand <= threshold_values{6,1}(1,5));
                segYUVObjectsMask = uint8(segYMask & segUMask & segVMask);
                
                segmaskedyuvImage = uint8(zeros(size(segYUVObjectsMask)));
                
                segmaskedyuvImage(:,:,1) = seg6(:,:,1) .* segYUVObjectsMask;
                segmaskedyuvImage(:,:,2) = seg6(:,:,2) .* uint8(segUMask);
                segmaskedyuvImage(:,:,3) = seg6(:,:,3) .* uint8(segVMask);    
                
                
                new_seg6 = segmaskedyuvImage(:,:,1);
                total_frame_pixels = (total_frame_pixels + nnz(segmaskedyuvImage(:,:,1))); 


                
                image_segment = '7';
                segYBand = seg7(:,:, 1); % extract YUV channel pixel values, by channel
                segUBand = seg7(:,:, 2);
                segVBand = seg7(:,:, 3);
                segYMask = (segYBand >= threshold_values{7,1}(1,2) & segYBand <= threshold_values{7,1}(1,1)); % create image masks for YUV thresholds provided
                segUMask = (segUBand >= threshold_values{7,1}(1,4) & segUBand <= threshold_values{7,1}(1,3));
                segVMask = (segVBand >= threshold_values{7,1}(1,6) & segVBand <= threshold_values{7,1}(1,5));
                segYUVObjectsMask = uint8(segYMask & segUMask & segVMask);
                
                segmaskedyuvImage = uint8(zeros(size(segYUVObjectsMask)));
                
                segmaskedyuvImage(:,:,1) = seg7(:,:,1) .* segYUVObjectsMask;
                segmaskedyuvImage(:,:,2) = seg7(:,:,2) .* uint8(segUMask);
                segmaskedyuvImage(:,:,3) = seg7(:,:,3) .* uint8(segVMask);          
                
                new_seg7 = segmaskedyuvImage(:,:,1);
                total_frame_pixels = (total_frame_pixels + nnz(segmaskedyuvImage(:,:,1))); 

                
                image_segment = '8';
                segYBand = seg8(:,:, 1); % extract YUV channel pixel values, by channel
                segUBand = seg8(:,:, 2);
                segVBand = seg8(:,:, 3);
                segYMask = (segYBand >= threshold_values{8,1}(1,2) & segYBand <= threshold_values{8,1}(1,1)); % create image masks for YUV thresholds provided
                segUMask = (segUBand >= threshold_values{8,1}(1,4) & segUBand <= threshold_values{8,1}(1,3));
                segVMask = (segVBand >= threshold_values{8,1}(1,6) & segVBand <= threshold_values{8,1}(1,5));
                segYUVObjectsMask = uint8(segYMask & segUMask & segVMask);
                
                segmaskedyuvImage = uint8(zeros(size(segYUVObjectsMask)));
                
                segmaskedyuvImage(:,:,1) = seg8(:,:,1) .* segYUVObjectsMask;
                segmaskedyuvImage(:,:,2) = seg8(:,:,2) .* uint8(segUMask);
                segmaskedyuvImage(:,:,3) = seg8(:,:,3) .* uint8(segVMask); 
    
                new_seg8 = segmaskedyuvImage(:,:,1);
                total_frame_pixels = (total_frame_pixels + nnz(segmaskedyuvImage(:,:,1))); 

                
                
    false_positive_pixels = (total_frame_pixels - true_pos_pixels); % total number of pixels outside of bounding boxes    
    
    name = int2str(ctr_frame - 1);
    
    
    
    
    
    %%
    %UNCOMMENT CODE IN THEIS BLOCK TO SAVE IMAGES OF STITCHED SEGMENTS

    stitched_image = [new_seg1 ;new_seg2 ;new_seg3 ;new_seg4 ;new_seg5 ;new_seg6 ;new_seg7 ;new_seg8]; %stitch together each frame image segment
    
    framename = strcat('segstitched_frame_', name);

    S = strcat(framename, tag);

    imwrite(stitched_image, S); % save stitched segmented image
    
    %%
    % Below code Gets areas of object in images to try and determine False Positive Objects
    
%     %Step 1: Label each object using the following code.
%     I = im2bw(stitched_image);  % be sure your image is binary
%     [L,n] = bwlabel(I); % label each object
%     
%     %Step 2: see the label of each object
%     s = regionprops(L, 'Centroid');
%     hold on;
%     for k = 1:numel(s);
%         c = s(k).Centroid;
%         text(c(1), c(2), sprintf('%d', k), ...
%             'HorizontalAlignment', 'center', ...
%             'VerticalAlignment', 'middle');
%     end
%     hold off;
%     % Step 3: find the area of the object you want using its label
%     larger_objects = 0;
%     for k = 1:n;
%         Obj = (L == k);
%         Area = bwarea(Obj); %get Area of each object
%         if Area > 25; % threshold for number of pixels determines if an object is large enough to consider a FP issue
%             larger_objects = larger_objects + 1;
%         else
%             larger_objects = larger_objects;
%         end
%         
%     end
%     
%     frame_objects = n;
%     
%    
%     A = table(cellstr(name), total_frame_pixels, true_pos_pixels, false_positive_pixels, frame_objects, larger_objects);
    
 %%   
   
    %IF USING ABOVE CODE BLOCK, HASH OUT VARIABLE A BELOW
    A = table(cellstr(name), total_frame_pixels, true_pos_pixels, false_positive_pixels);

    
    filtered_pixels_table = [filtered_pixels_table; A];
    
   
end
 
%writetable(new_table,output_file_name,'Sheet',strcat(threshold_type,'_TP_Values'));

writetable(TPP,output_file_name,'Sheet',strcat(threshold_type,'_TP_Pixels'));

writetable(filtered_pixels_table,output_file_name,'Sheet',strcat(threshold_type,'_Pixel_Totals'));

writetable(grpstats(TPP(:,1:3), {'T_result', 'Image_Segment'}, {'min', 'max', 'mean', 'std'}),output_file_name,'Sheet',strcat(threshold_type,'_TP_Statistics'));

msg = ['File published' output_file_name];
display(msg);

end