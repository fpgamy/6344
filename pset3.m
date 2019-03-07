%% pset 3
clear;
clc;
%% Basic tutorial
% Load the image
I = imread('pent.jpg');
% Convert to a double
I = double(I)/256;
% Extract luminance
bw = (I(:,:,1)+ I(:,:,2) + I(:,:,3))/3;
% show result
subplot(1, 2, 1);
imshow(bw);

%% Compress
fun = @(block_struct) compr(block_struct.data);
res = blockproc(bw, [4, 4], fun);
subplot(1, 2, 2);
imshow(res);

%% algorithm for problem 4
function compressed = compr(blk)
    trans = dct2(blk);
    mask = [ [1 1 1 0]; [1 1 0 0]; [1 0 0 0]; [0 0 0 0] ];
    masked = trans.*mask;
    compressed = idct2(masked);
end