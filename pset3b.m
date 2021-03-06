%% pset 3
clear;
clc;
%% Basic tutorial
% Load the image
I = imread('lena.jpg');
% Convert to a double
I = double(I)/256;
% Extract luminance
bw = (I(:,:,1)+ I(:,:,2) + I(:,:,3))/3;
% show result
% subplot(1, 2, 1);
% imshow(bw);

% set the dynamic range to be centred about 0
img_in = bw - 128;

% %% Problem 9
% % take the total fft
% freq_domain = fft2(img_in);
% total_power = sum(freq_domain .* conj(freq_domain), 'All');
% disp("Total Power: ");
% disp(total_power);
% 
% %% Part A
% p  = 5;
% [freq, pow] = compress(freq_domain, p);
% disp("Power of 15% of coeffs: ");
% disp(pow)
% cimg = ifft2(freq);
% cimg = cimg + 128;
% % show result
% subplot(1, 2, 2);
% imshow(cimg);
% 
% %% Part B
% figure;
% % show result
% subplot(1, 2, 1);
% imshow(bw);
% fun = @(block_struct) get_compressed(block_struct.data, p);
% res = blockproc(img_in, [8 8], fun) + 128;
% subplot(1, 2, 2);
% imshow(res);

%% Problem 10
img_in_256 = img_in(1:2:end, 1:2:end) + 128;

figure;
subplot(3, 2, 1);
imshow(img_in_256);

h12 = zeros(20, 20);
for i = 1:20
    h1 = min(i + 1, 20 -i);
    for j = 1:20
       h2 = min(j + 1, 20 - j);
       h12(i, j) = h1*h2/10000;
    end
end
res = conv2(img_in_256, h12);
subplot(3, 2, 2);
imshow(res);
% res is size 275 by 275

% show result
subplot(3, 2, 3);
imshow(img_in_256);
fun = @(block_struct) h_filt(block_struct.data, h12);
res = zeros(275, 275);
temp = (blockproc(img_in_256, [32 32], fun));

for i = 1:8
    for j = 1:8
        startx = (i-1)*32 + 1;
        startx2 = (i-1)*64 + 1;
        starty = (j-1)*32 + 1;
        starty2 = (j-1)*64 + 1;
        prev = res(startx:(startx+50), starty:(starty+50));
        res(startx:(startx+50), starty:(starty+50)) = prev + temp(startx2:(startx2+50), starty2:(starty2+50));
        subplot(3, 2, 4);
        imshow(res);
        pause(0.01);
    end
end

%% Smallest number of 2D DFT operations is 1. The DFT would be 512 by 512
%% k = 9.

subplot(3, 2, 5);
imshow(img_in_256);
imshow(bw);
f1 = fft2(img_in_256, 512, 512);
f2 = fft2(h12, 512, 512);
out = ifft2(f1.*f2, 512, 512);
out = out(1:275, 1:275);
subplot(3, 2, 6);
imshow(res);

function out = h_filt(img, h)
    f1 = fft2(img, 64, 64);
    f2 = fft2(h, 64, 64);
    out = ifft2(f1.*f2, 64, 64);
end

function compressed = get_compressed(img, percentage)
    fft_img = fft2(img);
    [f, ~] = compress(fft_img, percentage);
    compressed = ifft2(f);
end

function [freq, pow] = compress(freq_domain, percentage)
    no_coeffs = numel(freq_domain);
    psd = freq_domain .* conj(freq_domain);
    ordered_coeffs = sort(reshape(psd, 1, no_coeffs));
    cutoff = ordered_coeffs(ceil(no_coeffs*((100-percentage)/100)));
%     disp('Cutoff: ');
%     disp(cutoff)
    largest_coeffs = freq_domain;
%     disp('Zero Coeffs Raw: ');
%     disp(sum((largest_coeffs == 0), 'All'))
    largest_coeffs(psd < cutoff) = 0;
%     disp('Zero Coeffs After: ');
%     disp(sum((largest_coeffs == 0), 'All'))
    pow = sum(largest_coeffs .* conj(largest_coeffs),  'All');
    freq = largest_coeffs;
end

