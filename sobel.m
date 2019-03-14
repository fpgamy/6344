%% sobel filter using conv2
clear;
clc;
%% Basic tutorial
% Load the image
I = imread('lena.jpg');
% Convert to a double
I = double(I)/256;

% %% Get image from camera
% cam = webcam;
% I = snapshot(cam);
% I = histeq(double(I)/256);

% 3 by 3 sobel
sobel_x = [-1 0 1; -2 0 2; -1 0 1];

% 7 by 7 sobel
% sobel_x = [-3/18 -2/13 -1/10 0  1/10 2/13 3/18;
%            -3/13 -2/8  -1/5  0  1/5  2/8  3/13;
%            -3/10 -2/5  -1/2  0  1/2  2/5  3/10;
%            -3/9  -2/4  -1/1  0  1/1  2/4  3/9;
%            -3/10 -2/5  -1/2  0  1/2  2/5  3/10;
%            -3/13 -2/8  -1/5  0  1/5  2/8  3/13;
%            -3/18 -2/13 -1/10 0  1/10 2/13 3/18];
sobel_y = sobel_x';

gaussian_filt = fspecial('gaussian', [11 11], 1);

Iyuv = get_yuv(I);
[~, ~, ~, gauss_yuv] =  apply_filt_yuv(Iyuv, gaussian_filt);
[Gx, ~, ~, ~] = apply_filt_yuv(gauss_yuv, sobel_x);
[Gy, ~, ~, ~] = apply_filt_yuv(gauss_yuv, sobel_y);

% figure;
% imshow(get_rgb(gauss_yuv));
% figure;
% imshow(get_rgb(sobelx_yuv));
% figure;
% imshow(get_rgb(sobely_yuv));

G = sqrt(Gx.*Gx + Gy.*Gy);
%theta in degrees - scale: (-180, 180)
Theta = atan2(Gy, Gx).*(180/pi);
%theta in degrees rounded to nearest 45
Theta = round(Theta ./ 45)*45;
Theta(Theta <= 0) = Theta(Theta <= 0) + 180;
Theta(Theta >= 180) = Theta(Theta >= 180) - 180;

Sup = G;
for x = 2:(size(Theta, 1)-1)
    for y = 2:(size(Theta, 2)-1)
        cu = G(x, y);
        no = G(x, y-1);
        so = G(x, y+1);
        ea = G(x+1, y);
        we = G(x-1, y);
        noea = G(x+1, y-1);
        nowe = G(x-1, y-1);
        soea = G(x+1, y+1);
        sowe = G(x-1, y+1);
        
        if (Theta(x, y) == 0)
            if ((cu < ea) || (cu < we))
                Sup(x, y) = (cu + ea + we)*0.25;
            end
        end
        if (Theta(x, y) == 45)
            if ((cu < noea) || (cu < sowe))
                Sup(x, y) = (cu + noea + sowe)*0.25;
            end
        end
        if (Theta(x, y) == 90)
            if ((cu < no) || (cu < so))
                Sup(x, y) = (cu + no + so)*0.25;
            end
        end
        if (Theta(x, y) == 135)
            if ((cu < nowe) || (cu < soea))
                Sup(x, y) = (cu + nowe + soea)*0.25;
            end
        end
    end
end

HighThres = 0.3;
LowThres = 0.1;
High = zeros(size(Sup));
High(Sup > HighThres) = 1;
Low = zeros(size(Sup));
Sup(Sup <= LowThres) = 0;

for x = 2:(size(Theta, 1)-1)
    for y = 2:(size(Theta, 2)-1)
        if ((Sup(x, y) > LowThres) && (Sup(x, y) < HighThres))
            cu = High(x, y);
            no = High(x, y-1);
            so = High(x, y+1);
            ea = High(x+1, y);
            we = High(x-1, y);
            noea = High(x+1, y-1);
            nowe = High(x-1, y-1);
            soea = High(x+1, y+1);
            sowe = High(x-1, y+1);
            if (~(no || so || ea || we || noea || nowe || soea || sowe))
                Sup(x, y) = 0;
            end
        end
    end
end

figure;
Iyuv(:,:,1) = Sup;
imshow(get_rgb(Iyuv));

function [finy, finu, finv, finyuv] = apply_filt_yuv(img_in_yuv, filt_in)
    tempy = img_in_yuv(:,:,1);
    finu = img_in_yuv(:,:,2);
    finv = img_in_yuv(:,:,3);
    
    finy = conv2(tempy, filt_in, 'same');
    finyuv = cat(3, finy, finu, finv);
end

function yuv = get_yuv(rgb)
    A = [0.2126 0.7152 0.0722 ; -0.09991 -0.33609 0.436; 0.615 -0.55861 -0.05639];
    yuv = rgb;
    for i = 1:size(rgb, 1)
        for j = 1:size(rgb, 2)
            temp = reshape(rgb(i, j, :), [3 1]);
            yuv(i,j,:) = A*temp;
        end
    end
end

function rgb = get_rgb(yuv)
    A = [0.2126 0.7152 0.0722 ; -0.09991 -0.33609 0.436; 0.615 -0.55861 -0.05639];
    rgb = yuv;
    for i = 1:size(yuv, 1)
        for j = 1:size(yuv, 2)
            temp = reshape(yuv(i, j, :), [3 1]);
            rgb(i,j,:) = inv(A)*temp;
        end
    end
end

