%% project
clear;
clc;

%% Stream Sobel from from webcam to video output
cam = webcam;

% %% Calibration Step
% curr_noise = zeros(720, 1280);
% 
% for i = 1:8
%     I = snapshot(cam);
%     I = I(:,:,3);
%     I = double(I)/256;
%     imshow(I);
%     I = imgaussfilt(I, 8);
%     res = edge(I, 'Sobel');
%     F = fft2(res);
%     curr_noise = curr_noise + F;
% end
% N = (curr_noise./8);
% B = snapshot(cam);
% B = double(B)/256;
% B = imgaussfilt(B, 8);
% 
% A = ones(720,  1280, 3);
% B_r = mean2(B(:,:,1));
% B_g = mean2(B(:,:,2));
% B_b = mean2(B(:,:,3));
% A(:,:,1) = A(:,:,1) * B_r;
% A(:,:,2) = A(:,:,2) * B_g;
% A(:,:,3) = A(:,:,3) * B_b;
% 
% input('Please raise your hand (and press enter): ');
% I = snapshot(cam);
% I = double(I)/256;
% I = imgaussfilt(I, 8);
% 
% sum_sq_h  = zeros(72, 128, 3);
% hcount = 0;
% for i = 0:9
%     for j = 0:9
%         I_sq = I(((i*72)+1):(((i+1)*72)),((j*128)+1):(((j+1)*128)),:);
%         B_sq = B(((i*72)+1):(((i+1)*72)),((j*128)+1):(((j+1)*128)),:);
%         I_sq_r = reshape(I_sq, 1, numel(I_sq));
%         B_sq_r = reshape(B_sq, 1, numel(B_sq));
% %         subplot(1, 2, 1);
% %         imshow(I_sq);
% %         subplot(1, 2, 2);
% %         imshow(B_sq);
% %         disp(min(abs(I_sq_r - B_sq_r)));
% %         disp(mean(abs(I_sq_r - B_sq_r)));
% %         input('Enter: ');
%         if ((min(abs(I_sq_r - B_sq_r)) > 0.1) || (mean(abs(I_sq_r - B_sq_r)) > 0.1))
%             hcount = hcount +  1;
%             sum_sq_h = sum_sq_h + I_sq;
%             I(((i*72)+1):(((i+1)*72)),((j*128)+1):(((j+1)*128)),2:3) = zeros(72, 128, 2);
%         end
%     end
% end
% 
% sum_sq_h = sum_sq_h ./ hcount;
% 
% H_r = mean2(sum_sq_h(:,:,1));
% H_g = mean2(sum_sq_h(:,:,2));
% H_b = mean2(sum_sq_h(:,:,3));
% H = ones(720,  1280, 3);
% H(:,:,1) = H(:,:,1) * H_r;
% H(:,:,2) = H(:,:,2) * H_g;
% H(:,:,3) = H(:,:,3) * H_b;
% 
% imshow(I);
% 
% input('Is your hand here?');
% 
% figure;
% subplot(1, 2, 1);
% imshow(A);
% subplot(1, 2, 2);
% imshow(H);
% 
% input('Color Difference:');

%% Running step
% Get image from camera

% sobel_x = [-1 0 1; -2 0 2; -1 0 1];
% sobel_y = sobel_x';
% sobel_diag1 = [0 1 2; -1 0 1; -2 -1 0];
% sobel_diag2 = [-2 -1 0; -1 0 1; 0 1 2];

figure;
% N_temp = zeros(720/2, 1280/2);
% F_prev = zeros(720/2, 1280/2);
for i = 1:100
    I = snapshot(cam);
    I = I(:,:,3);
    I = imresize(I, 0.5);
    I = double(I)/256;
    I = histeq(I);
    I = imgaussfilt(I, 3);
    res = edge(I, 'Sobel');
%     I_x = (conv2(I, sobel_x, 'same'));% > 0.5);
%     I_y = (conv2(I, sobel_y, 'same'));% > 0.5);
%     I_d1 = (conv2(I, sobel_diag1, 'same'));% > 0.5);
%     I_d2 = (conv2(I, sobel_diag2, 'same'));% > 0.5);
%     res = I_x + I_y + I_d1 + I_d2;
    
    
    
    % show the edges
    subplot(2, 2, 1);
    imshow(res);
    
    % show the FFT
    subplot(2, 2, 2);
%     F = fft2(res) - 0.5*(N);
    F = fft2(res);
%     N_temp_prev = N_temp;
%     N_temp = F;
%     F = F - 0.5*N_temp_prev;
%     F = F - N_temp_prev;
    F(abs(F) < prctile(abs(reshape(F, 1,  numel(F))), 90)) = 0;
    % plot the DFT
    normalised_ft = 100*log(1+abs(fftshift(F)));
%     if i ~= 1
%         normalised_ft_smooth = (normalised_ft + F_prev)./2;
%         F_prev = normalised_ft;
%     else
        normalised_ft_smooth = normalised_ft;
%         F_prev = normalised_ft;
%     end

    imagesc(normalised_ft_smooth);
    subplot(2, 2, 3);
    lin = ImToPolar(normalised_ft, 0.1, 1, 72, 128);
    imshow(lin);
    subplot(2, 2, 4);
    
    filt_a = 1;
    filt_b = ones(1, 16) .* 1/16;
    smooth = filter(filt_b, filt_a, sum(lin));
    plot(smooth);
end
