%% project
clear;
clc;

%% Stream Sobel from from webcam to video output
cam = webcam;

%% Running step
% Get image from camera

% smooth the movements of the peaks
smooth_buff_sz = 64;
smooth_buffer = zeros(smooth_buff_sz, 256);
smooth_buffer_cntr = 1;

% account for background once
run_once = 0;

% initialise the locations to be -1 (i.e. no peak)
locations = -ones(16, 2);
locations_cntr = zeros(1, 2);

% pointer to the locations array
written_loc_ind = 1;
written_loc_ind_prev = 1;

% this parameter can be tweaked to change the edge sensitivity
gauss_filt_size  = 10;
fft_cutoff_percentile = 75;

% smoothing function parameters (for figuring out presence of lines)
no_taps = 32;
delay_factor_weight = 1;

filt_a = 1;
filt_b = ones(1, no_taps);
for i=1:no_taps
    filt_b(i:end) = filt_b(i:end).*delay_factor_weight;
end
filt_b = filt_b.*(1/sum(filt_b));

% smoothing function for peak motion
no_taps_motion = 4;
delay_factor_weight_motion = 0.5;

motion_filt_a = 1;
motion_filt_b = ones(1, no_taps_motion);
for i=1:no_taps_motion
    motion_filt_b(i:end) = motion_filt_b(i:end).*delay_factor_weight_motion;
end
motion_filt_b = motion_filt_b.*(1/sum(motion_filt_b));

% percentile to remove non-peaks
peak_percentile = 0.5;

% noise threshold
noise_thresh = 0.08;


% run for short 200 frames
for i = 1:200
    % get an image
    I = snapshot(cam);
    I = I(:,:,3);
    I = imresize(I, 0.5);
    I = double(I)/256;
    I = histeq(I);
    
    % this blurs the image to reduce the number of edges
    I = imgaussfilt(I, gauss_filt_size);
    % apply a sobel filter
    res = edge(I, 'Sobel');
    
    % show the edges
    subplot(2, 2, 1);
    imshow(res);
    
    % show the FFT
    subplot(2, 2, 2);
    F = fftshift(fft2(res));
    % zero the FFT coefficients which are too small
    F(abs(F) < prctile(abs(reshape(F, 1,  numel(F))), fft_cutoff_percentile)) = 0;
    %  normalise so we can see  things
    normalised_ft = 100*log(1+abs(F));
    % plot the DFT
    imagesc(normalised_ft);
    
    % plot the linear version
    subplot(2, 2, 3);
%     lin = ImToPolar(abs(normalised_ft), 0.5, 1, 64, 256);
    lin = ImToPolar(abs(F), 0.5, 1, 64, 256);
    imshow(lin);
    subplot(2, 2, 4);
    
    % sum the intensities at each x location (corresponding to an angle in
    % fft)
    peak_sum_in_x = sum(lin);
    
    % remove values corresponding to non-peaks
    peak_sum_in_x(peak_sum_in_x < prctile(peak_sum_in_x, peak_percentile)) = 0;
    smooth = filter(filt_b, filt_a, peak_sum_in_x);
    
    % calculate the mean of top percentiles of intensities
    smooth = filter(filt_b, filt_a, smooth);
    m = mean(smooth_buffer);
    % calculate the difference between the mean and m
    smooth_new = abs(smooth - m);
    
    % store smooth data
    
    % if the sum of non-noise is smaller than 0.08 * sum(mean of smooth 
    % buffer) then we assume the frame is noise
    if (sum(abs(smooth - m))*run_once <= noise_thresh*sum(abs(m))) 
        % update the smooth buffer
        smooth_buffer(smooth_buffer_cntr,:) = smooth;
        smooth_buffer_cntr = smooth_buffer_cntr + 1;
        
        % wrap around
        if (smooth_buffer_cntr > smooth_buff_sz)
            smooth_buffer_cntr = 1;
            
            % update run once (this assumes initially no hand)
            run_once = 1;
        end
        plot(smooth_new);
    else
        % there is hands
        locations_cntr = locations_cntr + ones(1, 2);
        % find the peaks
        [~, locs] = findpeaks(smooth_new, 'MinPeakDistance', 32, 'NPeaks', 5);
        
        if (numel(locs) < 2)
            locs = [0 locs];
        end
        
        plot(smooth_new);
        hold on;
        
        % store locations: invalid = -1
        for pklocations=1:2
            % if the current location is -1, update
            if (locations(written_loc_ind, pklocations) < 0)
                locations(written_loc_ind, pklocations) = locs(pklocations);
            else
                % find the peak location closest to the current stored
                % peaks
                [Y, I] = min(abs(locs(:) - locations(written_loc_ind_prev, pklocations)));
                if (Y < 8)
                    % update if the locations if the distance is less than
                    % 8
                    locations(written_loc_ind, pklocations) = locs(I);
                    locations_cntr(pklocations) = locations_cntr(pklocations) - 1;
                else
                    % account for wrap around
                    [Y, I] = min(abs((256-locs(:)) - locations(written_loc_ind_prev, pklocations)));
                    if (Y < 8)
                        locations(written_loc_ind, pklocations) = locs(I);
                        locations_cntr(pklocations) = locations_cntr(pklocations) - 1;
                    end
                end
            end
            
            % if the sum of the locations has not changed, probably should
            % ignore
            if (sum(diff(locations(written_loc_ind,:))) == 0)
                locations(written_loc_ind, pklocations) = -1;
            end
            
            % if it has been a long time since a peak has occured at that
            % location, ignore
            if (locations_cntr(pklocations) > 10)
                locations(written_loc_ind, pklocations) = -1;
                locations_cntr(pklocations) = 0;
            end
        end
        
        % update the locations pointer
        written_loc_ind_prev = written_loc_ind;
        written_loc_ind = written_loc_ind + 1;
        if (written_loc_ind > 16)
            written_loc_ind = 1;
        end
        
        plot(locations(1,:), zeros(1, numel(locations(1,:))), 'LineStyle', 'none', 'Marker', '*', 'MarkerSize', 10);
        hold off;
    end
end