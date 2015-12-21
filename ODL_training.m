function D = ODL_training(filename)
    %%% Train the dictionary through online dictionary learning algorithm[1].
    % This algorithm is implemented with SPAMS toolbox[2].
    % Returns the m x p dictionary, where m is the size of a codeword and p
    % is the size of the dictionary.
    % [1] Mairal J, Bach F, Ponce J, et al. Online learning for matrix 
    % factorization and sparse coding[J]. The Journal of Machine Learning Research, 
    % 2010, 11: 19-60.
    % [2] http://spams-devel.gforge.inria.fr/
    %%%
    
    clc;
    addpath(genpath('spams-matlab'));
    % load file names for training vocals
    fid = fopen(filename);
    training_file = cell(0);
    cnt = 1;

    tline = fgetl(fid);
    while ischar(tline)
        training_file{cnt} = tline;
        cnt = cnt + 1;
        tline = fgetl(fid);
    end
    fclose(fid);
    
    % open each file and create spectrogram
    % vocal
    train_spec = cell(0);
    cnt = 1;
    file_cnt = size(training_file, 2);
    for i = 1:file_cnt
        name = training_file{file_cnt};
        [y, fs] = audioread(name);
        [S, F, T] = spectrogram(y(:,1), hamming(1024), 256, 1024, fs);
        train_spec{cnt} = S(:,all(S,1)); % delete zero columns
        fprintf('%d out of %d files read\n', cnt, file_cnt);
        cnt = cnt + 1;
    end
    dictionary_input = abs([train_spec{:}]); % input signals for dictionary learning
    clearvars train_spec
    
    % train the dictionary
    param.K=100; % learns a dictionary with 100 elements
    param.lambda=0.5;
    param.numThreads=-1; % number of threads
    param.batchsize=400;
    param.verbose=false;
    param.iter=1000;
    param.mode=6;
    param.modeD=0;
    param.modeParam=0;
    
    fprintf('Begin learning the dictionary...\n');
    tic
    D = mexTrainDL(dictionary_input,param);
    t=toc;
    fprintf('time of computation for Dictionary Learning: %f\n',t);
    %figure;
    %surf(1:100, F(1:190), D(1:190,:), 'EdgeColor','none');
    %colormap(hot); view(0,90);
    
        