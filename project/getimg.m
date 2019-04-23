% I = snapshot(cam);
% I = I(:,:,3);
% raw = imresize(I, 0.5);
% raw = double(raw)/256;
% figure;
% subplot(2, 1, 1);
% imshow(raw)
% title('Raw Image')
% subplot(2, 1, 2);
% eq = histeq(raw);
% imshow(eq)
% title('Equalized Image');
% 
% set(findall(gcf,'-property','FontSize'),'FontSize',18);
% 
% figure;
% 
% subplot(2, 1, 1);
% imshow(eq)
% title('Image Before Sobel');
% subplot(2, 1, 2);
% sob = edge(eq, 'Sobel');
% imshow(sob)
% title('Image After Sobel');
% 
% set(findall(gcf,'-property','FontSize'),'FontSize',18);

% figure;
% 
% gausseq = imgaussfilt(eq, 5);
% smoothsob = edge(gausseq, 'Sobel');
% imshow(smoothsob)
% title('Sobel with Pre-smoothing');
% set(findall(gcf,'-property','FontSize'),'FontSize',18);
% 
% figure;
F = fftshift(fft2(smoothsob));
% normalised_ft = 100*log(1+abs(F));
% imagesc(normalised_ft);
% title('2D-DFT Magnitude Spectrum');
% colorbar;
% set(findall(gcf,'-property','FontSize'),'FontSize',18);

% figure;
% T = F;
% T(abs(F) < prctile(abs(reshape(F, 1,  numel(F))), 75)) = 0;
% normalised_ft = 100*log(1+abs(T));
% imagesc(normalised_ft);
% title('Modified 2D-DFT Magnitude Spectrum');
% colorbar;
% set(findall(gcf,'-property','FontSize'),'FontSize',18)

figure;
subplot(2, 1, 1);
lin = ImToPolar(abs(T), 0, 1, 64, 256);
imagesc(lin);
title('Transformed 2D-DFT Magnitude Spectrum');
colorbar;

subplot(2, 1, 2);
lin = ImToPolar(abs(T), 0.5, 1, 64, 256);
imagesc(lin);
title('Transformed 2D-DFT Magnitude Spectrum High Frequencies only');
colorbar;
set(findall(gcf,'-property','FontSize'),'FontSize',18);

figure;
subplot(2, 1, 1);
peak_sum_in_x = sum(lin);
plot(peak_sum_in_x, 'LineWidth', 4);
title('Summation of Intensity Map');
xlabel('Angle');
ylabel('Sum Of Magnitude');
grid minor;
subplot(2, 1, 2);

no_taps = 32;
filt_a = 1;
filt_b = ones(1, no_taps);
for i=1:no_taps
    filt_b(i:end) = filt_b(i:end).*delay_factor_weight;
end
filt_b = filt_b.*(1/sum(filt_b));

smooth = filter(filt_b, filt_a, peak_sum_in_x);

plot(smooth, 'LineWidth', 4);
title('Summation of Smoothed Intensity Map');
xlim([0 256]);
xlabel('Angle');
ylabel('Smoothed Sum Of Magnitude');
grid minor;
set(findall(gcf,'-property','FontSize'),'FontSize',18);

regions = 16;
r_width = 256/regions;

sum_arr_norm = sum(reshape(smooth,r_width,[]));

figure;
plot(sum_arr_norm, 'LineWidth', 4);
title('Block Integral');
xlabel('Index');
ylabel('Value');
grid minor
xlim([0 16]);

set(findall(gcf,'-property','FontSize'),'FontSize',18);
