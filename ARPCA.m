function [accompaniment, vocals, mag_vocal, mag_bgm] = ARPCA(mixture, fs)
    %%% Adaptive RPCA with dictionary.
   
    
    addpath(genpath('MATLAB_TSM-Toolbox_1.0'));
    %{
    % First do the HPSS
    param.anaHop = 256;
    param.win = hamming(1024);
    [xHarm,xPerc,sideinfo] = hpSep(mixture,param);
    %}
    audiowrite('harmo.wav',mixture,fs);
    
    [S, F, T] = spectrogram(mixture(:,1), hamming(1024), 1024-256, 1024, fs);
    S = STFT_s(mixture(:,1),1024,hamming(1024),256,fs);
    %[S, F, T] = spectrogram(xHarm(:,1), hamming(1024), 1024-256, 1024, fs);
    
    % First detect the vocal and nonvocal part of the recording
    fprintf('Singing voice detection...');
    [spec_block, block_type, vocal] = vocal_detection('harmo.wav', T);
    fprintf('done.\n');
    %delete('harmo.wav');
    
    fprintf('Preprocess the vocal/nonvocal blocks...');
    
    vocal = logical(vocal);
    nonvocal = ~vocal;
    normalize = max(max(abs(S)));
    mag = abs(S)/normalize;
    phase = angle(S);
    block_len = length(block_type);
    
    
    singing = cell(0);
    bgm = cell(0);
    
    vocal_b_len = [];
    nonvocal_b_len = [];
    total_block = cell(0);
    
    for i = 1:block_len
        cur_b = spec_block{i};
        index = logical(spec_block{i});
        total_block{i} = mag(:,index);
        if block_type(i)
            singing{end+1} = mag(:,index);
            vocal_b_len(end+1) = size(cur_b(cur_b >= 1),2);
        else
            bgm{end+1} = mag(:,index);
            nonvocal_b_len(end+1) = size(cur_b(cur_b >= 1),2);
        end
    end
    
    %singing = [singing{:}];
    %bgm = [bgm{:}];
    
    vocals = cell(block_len);
    accompaniment = cell(block_len);
    
    fprintf('done.\n');
    
    % separation
    fprintf('Separating...\n');
    parfor i = 1:block_len
        %fprintf('%d out of %d blocks...', i, block_len);
        cur_block = total_block{i};
        if block_type(i)
            %fprintf('PRCAm for vocal part...\n');
            [mag_bgm_vocal, mag_singing_vocal] = RPCA(cur_block, 1/sqrt(max(size(cur_block))));
            vocals{i} = mag_singing_vocal;
            accompaniment{i} = mag_bgm_vocal;

            %fprintf(' done.\n');
        else
            
                %fprintf('RPCA for nonvocal part...\n');
                [mag_bgm_non, mag_singing_non] = RPCA(cur_block, 5/sqrt(max(size(cur_block))));
                %[mag_bgm_non, mag_singing_non] = RPCA(cur_block, .5);
                vocals{i} = mag_singing_non;
                accompaniment{i} = mag_bgm_non;
                %vocals{i} = cur_block;
                %accompaniment{i} = cur_block;
                %fprintf('done.\n');
        end
         
    end
    fprintf('done.\n');
    
    mag_vocal = [vocals{:}];
    mag_bgm = [accompaniment{:}];
    
    %{
    % combine
    mag_vocal = zeros(size(mag));
    mag_bgm = zeros(size(mag));
    vocal_cnt = 1;
    nvocal_cnt = 1;
    v_onset = 1;
    n_onset = 1;
    
    for i = 1:block_len
        cur_block = spec_block{i};
        current_onset = 1;
        
        while cur_block(current_onset) ~= 1
            current_onset = current_onset + 1;
        end

        if block_type(i)
            mag_vocal(:,current_onset:current_onset+vocal_b_len(vocal_cnt)-1) = mag_singing_vocal(:,v_onset:v_onset+vocal_b_len(vocal_cnt)-1);
            mag_bgm(:,current_onset:current_onset+vocal_b_len(vocal_cnt)-1) = mag_bgm_vocal(:,v_onset:v_onset+vocal_b_len(vocal_cnt)-1);
            v_onset = v_onset + vocal_b_len(vocal_cnt);
            vocal_cnt = vocal_cnt + 1;
            
        else           
            mag_vocal(:,current_onset:current_onset+nonvocal_b_len(nvocal_cnt)-1) = mag_singing_non(:,n_onset:n_onset+nonvocal_b_len(nvocal_cnt)-1);
            mag_bgm(:,current_onset:current_onset+nonvocal_b_len(nvocal_cnt)-1) = mag_bgm_non(:,n_onset:n_onset+nonvocal_b_len(nvocal_cnt)-1);
            n_onset = n_onset + nonvocal_b_len(nvocal_cnt);
            nvocal_cnt = nvocal_cnt + 1;
        end
    end
    %}

    % process for each channel
    vocals = zeros(size(mixture));
    accompaniment = zeros(size(mixture));
    
    
    % recover the signal
    spec_vocal = mag_vocal .* exp(phase.*1i);
    spec_bgm = mag_bgm .* exp(phase.*1i);
    recover_vocal = ISTFT_s(spec_vocal, 1024, hamming(1024), 256);
    recover_bgm = ISTFT_s(spec_bgm, 1024, hamming(1024), 256);
    
    signal_len = size(mixture,1);

    if size(recover_vocal,2) < signal_len
        recover_vocal = [recover_vocal, zeros(1,signal_len-size(recover_vocal,2))];
        recover_bgm = [recover_bgm, zeros(1,signal_len-size(recover_bgm,2))];
    end
 
    vocals(:,1) = transpose(recover_vocal);
    vocals = vocals / max(abs(vocals));
    accompaniment(:,1) = transpose(recover_bgm);
    accompaniment = accompaniment / max(abs(accompaniment));
    
    %sound(vocals,fs);
    %{
    figure;
    subplot(311);
    surf(1:size(mag,2), 1:50, mag(1:50,:), 'EdgeColor','none');
    colormap(hot); view(0,90);
    subplot(312);
    surf(1:size(mag,2), 1:50, mag_vocal(1:50,:), 'EdgeColor','none');
    colormap(hot); view(0,90);
    subplot(313);
    surf(1:size(mag,2), 1:50, mag_bgm(1:50,:), 'EdgeColor','none');
    colormap(hot); view(0,90);
    %}
    clearvars -except vocals accompaniment
    
    
end
    