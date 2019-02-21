%% pset 2, problem 9
clear;
clc;

%% Converting to BW

% Load the image
I1 = imread('lena.jpg');
% Convert to a double
I1 = double(I1)/256;
% Extract luminance
I1 = (I1(:,:,1)+ I1(:,:,2) + I1(:,:,3))/3;

% Load the second image
I2 = imread('puss_in_boots.jpg');
% Convert to a double
I2 = double(I2)/256;
% Extract luminance
I2 = (I2(:,:,1)+ I2(:,:,2) + I2(:,:,3))/3;

% Display input
% figure;
% imshow(I1);
% figure;
% imshow(I2);

%% Find DFT
DFT1 = fft2(I1);
DFT2 = fft2(I2);

%% Combine the phase and magnitudes
m1p2 = abs(DFT1) .* exp(1i * angle(DFT2));
m2p1 = abs(DFT2) .* exp(1i * angle(DFT1));

%% Inverse ft
out1 = abs(ifft2(m1p2));
out2 = abs(ifft2(m2p1));
% Normalise
out1 = histeq(out1);
out2 = histeq(out2);

%% Display
figure;
imshow(out1);
figure;
imshow(out2);

