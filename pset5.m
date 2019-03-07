%% pset 5
clear;
clc;
%% Basic tutorial
% Load the image
I = imread('lena.jpg');
% Convert to a double
I = double(I)/256;
% Extract RGB
R = I(:,:,1);
G = I(:,:,2);
B = I(:,:,3);

% show result
figure;
subplot(1, 3, 1);
imshow(R);
subplot(1, 3, 2);
imshow(G);
subplot(1, 3, 3);
imshow(B);

A = [0.2126 0.7152 0.0722 ; -0.09991 -0.33609 0.436; 0.615 -0.55861 -0.05639];

%% Get YUV
I_yuv = I;
for i = 1:512
    for j = 1:512
        temp = reshape(I(i, j, :), [3 1]);
        I_yuv(i,j,:) = A*temp;
    end
end

% show result
figure;
subplot(1, 3, 1);
imshow(histeq(I_yuv(:,:,1)));
subplot(1, 3, 2);
imshow(histeq(I_yuv(:,:,2)));
subplot(1, 3, 3);
imshow(histeq(I_yuv(:,:,3)));

%% Recreate RGB
figure;
subplot(1, 2, 1);
imshow(I);
for i = 1:512
    for j = 1:512
        temp = reshape(I_yuv(i, j, :), [3 1]);
        I(i,j,:) = inv(A)*temp;
    end
end

subplot(1, 2, 2);
imshow(I);

%% Experiment with LPF
h1d = (1/3) .* [1 1 1];
ylp = conv2(h1d, h1d, I_yuv(:,:,1));
ylp(end-1:end,:) = [];
ylp(:,end-1:end) = [];
ulp = conv2(h1d, h1d, I_yuv(:,:,2));
ulp(end-1:end,:) = [];
ulp(:,end-1:end) = [];
vlp = conv2(h1d, h1d, I_yuv(:,:,3));
vlp(end-1:end,:) = [];
vlp(:,end-1:end) = [];
I_better = I_yuv;
I_better(:,:,2) = ulp;
I_better(:,:,3) = vlp;
I_yuv(:,:,1) = ylp;

for i = 1:512
    for j = 1:512
        temp = reshape(I_yuv(i, j, :), [3 1]);
        I(i,j,:) = inv(A)*temp;
    end
end

figure;
imshow(I);

for i = 1:512
    for j = 1:512
        temp = reshape(I_better(i, j, :), [3 1]);
        I(i,j,:) = inv(A)*temp;
    end
end

figure;
imshow(I);