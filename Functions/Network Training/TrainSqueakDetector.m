function [detector layers options] = TrainSqueakDetector(TrainingTables,layers)

% Specify layers if not transfering from previous network
if nargin == 1
        layers = [
            imageInputLayer([30 50 1])
            
            convolution2dLayer([5 5], 16, 'Padding', 1, 'Stride', [2 2])
            batchNormalizationLayer
            leakyReluLayer(0.1)
            
            convolution2dLayer([5 5], 20, 'Padding', 1, 'Stride', [2 2])
            batchNormalizationLayer
            leakyReluLayer(0.1)
            
            convolution2dLayer([3 3], 32)
            batchNormalizationLayer
            leakyReluLayer(0.1)
            
            maxPooling2dLayer(2, 'Stride',2)
            
            fullyConnectedLayer(64)
            reluLayer()
            fullyConnectedLayer(width(TrainingTables))
            softmaxLayer()
            classificationLayer()
            ];
end

% Matlab 2018b changed neural network training, so adjust the
% settings accordingly.
if verLessThan('matlab','9.5')
    MiniBatchSize = 32;
else
    MiniBatchSize = 1;
end

if canUseGPU()
    
    optionsStage1 = trainingOptions('sgdm', ...
        'MaxEpochs', 8, ...
        'InitialLearnRate', 1e-3,'MiniBatchSize',MiniBatchSize);
    
    optionsStage2 = trainingOptions('sgdm', ...
        'MaxEpochs', 8, ...
        'InitialLearnRate', 1e-3,'MiniBatchSize',MiniBatchSize);
    
    optionsStage3 = trainingOptions('sgdm', ...
        'MaxEpochs', 8,...
        'InitialLearnRate', 1e-4,'MiniBatchSize',MiniBatchSize);
    
    optionsStage4 = trainingOptions('sgdm', ...
        'MaxEpochs', 8, ...
        'InitialLearnRate', 1e-4,'MiniBatchSize',MiniBatchSize);
    
else % parallelize
    
    optionsStage1 = trainingOptions('sgdm', ...
        'MaxEpochs', 8, 'ExecutionEnvironment','parallel',...
        'InitialLearnRate', 1e-3,'MiniBatchSize',MiniBatchSize);
    
    optionsStage2 = trainingOptions('sgdm', ...
        'MaxEpochs', 8, 'ExecutionEnvironment','parallel', ...
        'InitialLearnRate', 1e-3,'MiniBatchSize',MiniBatchSize);
    
    optionsStage3 = trainingOptions('sgdm', ...
        'MaxEpochs', 8, 'ExecutionEnvironment','parallel',...
        'InitialLearnRate', 1e-4,'MiniBatchSize',MiniBatchSize);
    
    optionsStage4 = trainingOptions('sgdm', ...
        'MaxEpochs', 8, 'ExecutionEnvironment','parallel', ...
        'InitialLearnRate', 1e-4,'MiniBatchSize',MiniBatchSize);
end

options = [
    optionsStage1
    optionsStage2
    optionsStage3
    optionsStage4
    ];

% 2021 added 'TrainingMethod','four-step' for backward compatability
detector = trainFasterRCNNObjectDetector(TrainingTables, layers, options, ...
    'NegativeOverlapRange', [0 0.4], ...
    'PositiveOverlapRange', [0.6 1], ...
    'BoxPyramidScale', 1.8,'NumStrongestRegions',Inf,...
     'TrainingMethod','four-step',...
     'FreezeBatchNormalization', false);
 
end

