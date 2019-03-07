%% pset 4
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
figure;
imshow(bw);

% set the dynamic range to be centred about 0
img_in = bw;

h0 = [1 1];
h1 = [-1 1];
g0 = [0.5 0.5];
g1 = [0.5 -0.5];

x00 = conv2(h0, h0, img_in);
x00 = x00(1:2:end, 1:2:end);
x01 = conv2(h0, h1, img_in);
x01 = x01(1:2:end, 1:2:end);
x11 = conv2(h1, h1, img_in);
x11 = x11(1:2:end, 1:2:end);
x10 = conv2(h1, h0, img_in);
x10 = x10(1:2:end, 1:2:end);

figure;
subplot(2, 2, 1);
imshow(x00);
subplot(2, 2, 2);
imshow(x01);
subplot(2, 2, 3);
imshow(x10);
subplot(2, 2, 4);
imshow(x11);

x00 = upsample(x00, 2);
x00 = upsample(x00', 2);
x00 = x00';
x00 = conv2(g0, g0, x00);

x01 = upsample(x01, 2);
x01 = upsample(x01', 2);
x01 = x01';
x01 = conv2(g0, g1, x01);

x10 = upsample(x10, 2);
x10 = upsample(x10', 2);
x10 = x10';
x10 = conv2(g1, g0, x10);

x11 = upsample(x11, 2);
x11 = upsample(x11', 2);
x11 = x11';
x11 = conv2(g1, g1, x11);
figure;
imshow(x00+x01+x10+x11);