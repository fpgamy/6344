%% project
clear;
clc;

load('Net1.mat');
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

% this parameter can be tweaked to change the edge sensitivity
gauss_filt_size  = 5;
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

% noise threshold
noise_thresh = 0.1;

% stores integral approx of smoothed peaks
regions = 16;
r_width = 256/regions;
sum_arr = zeros(1, regions);
sum_arr_norm = zeros(1, regions);
sum_arr_next = zeros(1, regions);
x_locs = (1:regions)*r_width - r_width/2;

% left and right threshold
lr_thresh = 4000;
stationionary_thres = 2e3;

% set the volume to 0.5
scale = SoundVolume(0.5);
max_vol = 0.7;
min_vol = 0.0;
vol_step = 0.07;

% player start only once
[y, Fs] = audioread('bensound-scifi.mp3');
player = audioplayer(y, Fs);
start_playing = 0;
prev_left = 0;
prev_right = 0;
prev_up_sf = 1.1;
prev_down_sf = 0.9;

% check if we need to readjust scene
stationary_count = 0;

cap_scene = 1;
disp('Capturing Scene (Please Wait)...');
% run frames
while 1
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
    lin = ImToPolar(abs(F), 0.5, 1, 64, 256);
    imshow(lin);
    subplot(2, 2, 4);

    % sum the intensities at each x location (corresponding to an angle in
    % fft)
    peak_sum_in_x = sum(lin);
    smooth = filter(filt_b, filt_a, peak_sum_in_x);

    % calculate the mean of intensities
    smooth = filter(filt_b, filt_a, smooth);

    sum_arr_prev = sum_arr_norm;
    sum_arr_norm = sum(reshape(smooth,r_width,[]));
    sum_arr_norm = (sum_arr_norm - 1.2e4) ./6.8e3;

    m = mean(smooth_buffer);
    % calculate the difference between the mean and m
    smooth_new = abs(smooth - m);
    % store smooth data

    % if the sum of non-noise is smaller than 0.08 * sum(mean of smooth
    % buffer) then we assume the frame is noise
    if (sum(abs(smooth - m))*run_once <= noise_thresh*sum(abs(m)))
        pause(player);
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
        if ((max(smooth_new) < 100) && (cap_scene == 1) && (run_once == 1))
            cap_scene = 0;
            disp('Ready!');
        end
    else
        % there is hands
        if (start_playing == 0)
            play(player);
            start_playing = 1;
        else
            resume(player)
        end
        % sum chunks of smooth
        sum_arr_next = sum(reshape(smooth_new,r_width,[]));

        X = zeros(48, 1);
        X(1:16,:) = sum_arr_norm;
        lshift = circshift(sum_arr_prev, -1);
        rshift = circshift(sum_arr_prev, 1);

        X(17:32,:) = sum_arr_norm - lshift;
        X(33:48,:) = sum_arr_norm - rshift;
        plot(X(1:16,:), 'LineStyle', 'none', 'Marker', 'diamond', 'MarkerSize', 10);
        hold on;
        plot(X(17:32,:), 'LineStyle', 'none', 'Marker', 'x', 'MarkerSize', 10);
        plot(X(33:48,:), 'LineStyle', 'none', 'Marker', '+', 'MarkerSize', 10);
        hold off;
        if (max(abs(sum_arr_next - sum_arr)) > stationionary_thres)
            stationary_count = 0;
            YPred = classify(net1,X);
            if (YPred == categorical(3))
                disp('Right');
                if (scale <= (max_vol - vol_step))
                    scale = scale + vol_step;
                    SoundVolume(scale);
                    disp(scale);
                end
            else
                if (YPred == categorical(2))
                    disp('Left');
                    if (scale >= (min_vol + vol_step))
                        scale = scale - vol_step;
                        SoundVolume(scale);
                        disp(scale);
                    end
                end
            end
        else
            stationary_count = stationary_count + 1;
            if (stationary_count > 50)
                disp('Capuring Scene');
                run_once = 0;
                cap_scene = 1;
                stationary_count = 0;
                smooth_buffer = zeros(smooth_buff_sz, 256);
                smooth_buffer_cntr = 1;
            end
        end

        sum_arr = sum_arr_next;
    end
end

