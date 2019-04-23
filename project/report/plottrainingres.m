figure
subplot(1, 2, 1)

col = jet(12);
title('Training (Line) and Validation (Marker) Accuracy for Hidden Layers = 10');
xlabel('Iteration');
ylabel('Percentage');
hold on
for i = 1:12
plot(t(i).TrainingAccuracy, 'LineWidth', 0.5, 'LineStyle', '-', 'color', col(i,:))
end

for i = 1:12
temp = t(i).ValidationAccuracy;
temp(isnan(temp)) = -1;
scatter(1:size(temp, 2), temp, 100,   col(i,:), '*');
end

hold off
ylim([20 95])

subplot(1, 2, 2)

title('Training (Line) and Validation (Marker) Loss for Hidden Layers = 10');
xlabel('Iteration');
ylabel('Cross Entropy Loss');
hold on
for i = 1:12
plot(t(i).TrainingLoss, 'LineWidth', 0.5, 'LineStyle', '-',  'color', col(i,:))
end

for i = 1:12
temp = t(i).ValidationLoss;
temp(isnan(temp)) = -1;
scatter(1:size(temp, 2), temp, 100,  col(i,:), '*');
end

hold off
ylim([0.2 1.2])

set(findall(gcf,'-property','FontSize'),'FontSize',18);

legend(gca, {'L2 Reg: 2.5e-4,  Dropout: 0.0', ...
    'L2 Reg: 2.5e-4,  Dropout: 0.3', ...
    'L2 Reg: 2.5e-4,  Dropout: 0.6', ...
    'L2 Reg: 2.5e-4,  Dropout: 0.9', ...
    'L2 Reg: 5.0e-4,  Dropout: 0.0', ...
    'L2 Reg: 5.0e-4,  Dropout: 0.3', ...
    'L2 Reg: 5.0e-4,  Dropout: 0.6', ...
    'L2 Reg: 5.0e-4,  Dropout: 0.9', ...
    'L2 Reg: 7.5e-4,  Dropout: 0.0', ...
    'L2 Reg: 7.5e-4,  Dropout: 0.3', ...
    'L2 Reg: 7.5e-4,  Dropout: 0.6', ...
    'L2 Reg: 7.5e-4,  Dropout: 0.9' ...
    }, 'location', 'bestoutside', 'NumColumns', 4);

set(findall(gcf,'-property','LineWidth'),'LineWidth',2);