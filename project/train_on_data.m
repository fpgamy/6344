load('TrainingData.mat');
XTraining = XTrain;
YTraining = YTrain;
n = size(XTraining, 1);
m = n/4 ;
P = 0.80 ;
idx = randperm(m);
XTrain1 = XTraining(idx(1:round(P*m)),:) ; 
XTest1 = XTraining(idx(round(P*m)+1:end),:) ;
YTrain1 = YTraining(idx(1:round(P*m)),:) ; 
YTest1 = YTraining(idx(round(P*m)+1:end),:) ;

XTrain2 = XTraining(m + idx(1:round(P*m)),:) ; 
XTest2 = XTraining(m + idx(round(P*m)+1:end),:) ;
YTrain2 = YTraining(m + idx(1:round(P*m)),:) ; 
YTest2 = YTraining(m + idx(round(P*m)+1:end),:) ;

XTrain3 = XTraining(2*m + idx(1:round(P*m)),:) ; 
XTest3 = XTraining(2*m + idx(round(P*m)+1:end),:) ;
YTrain3 = YTraining(2*m + idx(1:round(P*m)),:) ; 
YTest3 = YTraining(2*m + idx(round(P*m)+1:end),:) ;

XTrain4 = XTraining(3*m + idx(1:round(P*m)),:) ; 
XTest4 = XTraining(3*m + idx(round(P*m)+1:end),:) ;
YTrain4 = YTraining(3*m + idx(1:round(P*m)),:) ; 
YTest4 = YTraining(3*m + idx(round(P*m)+1:end),:) ;

XTrain = [XTrain1 ; XTrain2 ; XTrain3 ; XTrain4];
XTest = [XTest1 ; XTest2 ; XTest3 ; XTest4];
YTrain = [YTrain1 ; YTrain2 ; YTrain3 ; YTrain4];
YTest = [YTest1 ; YTest2 ; YTest3 ; YTest4];

clearvars -except XTrain XTest YTrain YTest numHiddenUnits
numFeatures = 48;
numClasses = 3;
% epochs = 800;
% l2Reg = 75e-5;
% numHiddenUnits = 10;
% dropout = 0.6;


epochs = 200;
t = [];
count = 0;
for l2Reg = 25e-5:25e-5:75e-5
        for dropout = 0:0.3:0.9
            count = count + 1;
options = trainingOptions('adam', ...
    'MaxEpochs',epochs, ...
    'GradientThreshold',2, ...
    'Verbose',0, ...
    'Shuffle','every-epoch', ...
    'L2Regularization',l2Reg, ...
    'ValidationData',{XTest,YTest});

layers = [ ...
    sequenceInputLayer(numFeatures)
    dropoutLayer(dropout)
    bilstmLayer(numHiddenUnits,'OutputMode','sequence')
    fullyConnectedLayer(numClasses)
    softmaxLayer
    classificationLayer];

net.trainParam.showWindow = false;
Net.trainParam.showWindow = false;
[net1,tinfo] = trainNetwork(XTrain,YTrain,layers,options);
t = [t tinfo];
save('tinfofile', 't');
disp('L2')
disp(l2Reg)
disp('dropout')
disp(dropout)
        end
end