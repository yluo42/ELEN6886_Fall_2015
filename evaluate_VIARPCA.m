function [GNSDR,GSIR,GSAR] = evaluate_VIARPCA(D_v, D_bgm)

% load test files
    clc;
    %parpool(4);
    addpath(genpath('bss_eval'));
    filename = 'MIR1K_test.txt';
    % load file names for training vocals
    fid = fopen(filename);
    test_file = cell(0);
    cnt = 1;

    tline = fgetl(fid);
    while ischar(tline)
        test_file{cnt} = tline;
        cnt = cnt + 1;
        tline = fgetl(fid);
    end
    fclose(fid);
    
    
    % open each file and create spectrogram
    file_cnt = size(test_file, 2);
    
    NSDR = zeros(2,file_cnt);
    NSIR = zeros(2,file_cnt);
    NSAR = zeros(2,file_cnt);
    sig_len = zeros(1,file_cnt);
    
    for i = 1:file_cnt
        name = test_file{i};
        fprintf('%d of %d, %s\n',i, file_cnt, name);
        [y, fs] = audioread(name);
        
        
        sig_len(i) = size(y,1)/1e4;
        
        % VIARPCA
        t_vocal = y(:,2);
        t_accom = y(:,1);
        mixture = y(:,1)+y(:,2);
        [accompaniment, vocals] = VIARPCA(mixture, D_v, D_bgm, fs);
        
        % for each file, evaluate
        fprintf('Evaluating...');
        [SDR, SIR, SAR] = bss_eval_sources([vocals accompaniment ]' / norm(vocals + accompaniment), [t_vocal t_accom]' / norm(t_vocal + t_accom));
        [t_NSDR, t_NSIR, t_NSAR] = bss_eval_sources([mixture mixture]' / norm(mixture + mixture), [t_vocal t_accom]' / norm(t_vocal + t_accom));
        NSDR(:,i) = SDR - t_NSDR;
        NSIR(:,i) = SIR;
        NSAR(:,i) = SAR;
        clear SDR SIR SAR t_NSDR t_NSIR t_NSAR
        %{
        evaluation_results = eval_MIR1K(y(:,1), y(:,2), accompaniment, vocals)
        norm_results = eval_MIR1K(y(:,1), y(:,2), mixture, mixture)
        NSDR(i) = evaluation_results.SDR - norm_results.SDR;
        NSIR(i) = evaluation_results.SIR - norm_results.SIR;
        NSAR(i) = evaluation_results.SAR - norm_results.SAR;
        %}
        fprintf('done.\n');
        
        fprintf('NSDR: vocal = %.4f, bgm = %.4f\n', NSDR(1,i), NSDR(2,i));
        fprintf('SIR: vocal = %.4f, bgm = %.4f\n', NSIR(1,i), NSIR(2,i));
        fprintf('SAR: vocal = %.4f, bgm = %.4f\n', NSAR(1,i), NSAR(2,i));
    end
    
    GNSDR.vocal = sum(sig_len .* NSDR(1,:)) / sum(sig_len)
    GNSDR.bgm = sum(sig_len .* NSDR(2,:)) / sum(sig_len)
    GSIR.vocal = sum(NSIR(1,:)) / length(sig_len)
    GSIR.bgm = sum(NSIR(2,:)) / length(sig_len)
    GSAR.vocal = sum(NSAR(1,:)) / length(sig_len)
    GSAR.bgm = sum(NSAR(2,:)) / length(sig_len)
    
    fprintf('GNSDR: vocal = %.4f, bgm = %.4f\n', GNSDR.vocal, GNSDR.bgm);
    fprintf('GSIR: vocal = %.4f, bgm = %.4f\n', GSIR.vocal, GSIR.bgm);
    fprintf('GSAR: vocal = %.4f, bgm = %.4f\n', GSAR.vocal, GSAR.bgm);
    
end
    
    