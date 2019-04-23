clc;
clear;

N = 100;
video = zeros(N, 360, 640);
labels = ones(1, N);
cam = webcam;

min_interval = 8;
max_interval = 15;
i = 1;
prev_l = 1;
while (i < N)
    l = randi([1 3]);
    
    if (i ~= 1)
        while (prev_l == l)
            l = randi([1 3]);
        end
    end
    prev_l = l;
    rep = randi([min_interval max_interval]);
    if (i+rep <= N)
        labels(i:i+rep) = ones(1, rep+1).*l;
        disp(l);
        disp(rep);
        i = i + rep;
    else
        i = N;
    end
end
disp('first label: ');
disp(labels(1));
pause(2);

% this parameter can be tweaked to change the edge sensitivity
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

% stores integral approx of smoothed peaks
regions = 16;
r_width = 256/regions;
sum_arr = zeros(1, regions);
sum_arr_next = zeros(1, regions);
x_locs = (1:regions)*r_width - r_width/2;
XTrain = zeros(regions, N);
YTrain = labels;

% run for short 200 frames
for i = 1:N
    disp(labels(i));
    I = snapshot(cam);
    I = I(:,:,3);
    I = imresize(I, 0.5);
    I = double(I)/256;
    I = histeq(I);
    
    % this blurs the image to reduce the number of edges
    I = imgaussfilt(I, 5);
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
    plot(smooth);
   
    hold on;

    sum_arr = sum(reshape(smooth,r_width,[]));
    
    plot(x_locs, sum_arr./100, 'LineStyle', 'none', 'Marker', '*', 'MarkerSize', 10);
    XTrain(:,i) = sum_arr;
    hold off;
    
    if (i < N)
        if (labels(i) ~= labels(i + 1))
            disp('Next label:');
            disp('1: hand, 2: left, 3: right');
            disp(labels(i+1));
            pause(2);
        end
    end
end

save('training_dorm99.mat', 'XTrain', 'YTrain'); 
clear('cam');