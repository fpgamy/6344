clear;
clc;
%% Basic tutorial
% Load the image
I = imread('lena.jpg');
% Convert to a double
I = double(I)/256;
% Extract luminance
lum = (I(:,:,1)+ I(:,:,2) + I(:,:,3))/3;
% histogram equalize
processed = histeq(lum);
% show result
imshow(processed);

%% Problem 8

% Load the image
I = imread('lena.jpg');
% Convert to a double
D = double(I)/256;
% Extract luminance
lum = (I(:,:,1)+ I(:,:,2) + I(:,:,3))/3;

% Get the bw image
gscale = lum;
% Quantise
qgscale = bitshift(bitshift(gscale, -7), 7);
% show result
imshow(qgscale);

% Quantise
qgscale = bitshift(bitshift(gscale, -6), 6);
% show result
imshow(qgscale);

% Quantise
qgscale = bitshift(bitshift(gscale, -4), 4);
% show result
imshow(qgscale);

% Quantise
qgscale = bitshift(bitshift(gscale, -2), 2);
% show result
imshow(qgscale);

% show result
imshow(gscale);

C = bitshift(bitshift(I, -6), 6);
imshow(C)

%% Problem 9
% Load the image
I = imread('lena.jpg');
% Convert to a double
D = double(I)/256;
% Extract luminance
lum = (I(:,:,1)+ I(:,:,2) + I(:,:,3))/3;
gscale = lum;

figure;

h_1 = [0.25 0.5 0.25];
h_2 = [0.25 0.5 0.25];
lpf = h_1.' * h_2;
% plot the magnitude response
freqz2(lpf);

% filter the image by lpf
lpf_gscale = imfilter(gscale, lpf);

figure;
% show result
hold on;
subplot(1, 2, 1);
imshow(lpf_gscale);
subplot(1, 2, 2);
imshow(gscale);

figure;
% calculate hpf
hpf = zeros(size(lpf));
hpf(round(size(lpf)/2)) = 1;
hpf = hpf - lpf;

% plot the magnitude response
freqz2(hpf);

% filter the image by lpf
hpf_gscale = imfilter(gscale, hpf);

figure;
% show result
hold on;
subplot(1, 2, 1);
imshow(hpf_gscale);
subplot(1, 2, 2);
imshow(gscale);
