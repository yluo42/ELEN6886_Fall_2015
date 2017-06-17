function [spec_block, block_type, vocal] = vocal_detection(filename, T)
    %%% singing voice detection using MELODIA[1].
    % [1] J. Salamon and E. G¨®mez, "Melody Extraction from Polyphonic Music 
    % Signals using Pitch Contour Characteristics", IEEE Transactions on 
    % Audio, Speech and Language Processing, 20(6):1759-1770, Aug. 2012.
    % Returns vocal index and nonvocal index of the recording.
    
    name = strsplit(filename,'/');
    
    name = name{end};
    r_name = strsplit(name, '.');
    name = r_name{1};
    detect_comm = dos(strcat(['$HOME/Library/Audio/Plug-Ins/Vamp/vamp-simple-host mtg-melodia:melodia ',...
        filename, ' -o ', name, '.txt']));
    
    % read the time and corresponding pitch
    
    fid = fopen(strcat(name,'.txt'));
    time_pitch = zeros(0,0);

    tline = fgetl(fid);
    while ischar(tline)
        t = strsplit(tline, ':');
        time = str2double(t(1));
        pitch =str2double(t(2));
        time_pitch(end+1,:) = [time, pitch];
        tline = fgetl(fid);
    end
    fclose(fid);
    delete(strcat(name, '.txt'));
    
    % detect vocal regions, which has a positive pitch
    time_len = size(time_pitch, 1);
    time = time_pitch(:,1);
    pitch = time_pitch(:,2);
    vocal = pitch > 0;
    nonvocal = ~vocal;
    % find the exact time for onset and offset of vocal and nonvocal
    % regions
    vocal_onset = [];
    vocal_offset = [];
    
    if vocal(1)
        vocal_onset(end+1) = time(1);
    end
    for i = 2:time_len-1
        if vocal(i) && ~vocal(i-1)
            vocal_onset(end+1) = time(i);
        elseif vocal(i) && ~vocal(i+1)
            vocal_offset(end+1) = time(i);
        end
    end
    if size(vocal_offset,2) < size(vocal_onset,2)
        vocal_offset(end+1) = T(end);
    end
    
    % MELODIA uses blocksize 2048 and overlap 128, but our STFT use 1024
    % and 256. Hence need to transfer the time to correct time in STFT.
    
    region_cnt = size(vocal_onset,2);
    fprintf('%d vocal regions detected.\n', region_cnt);
    
    vocal_onset_t = zeros(size(vocal_onset));
    vocal_offset_t = zeros(size(vocal_offset));
    time_len_t = size(T,2);
    onset_cnt = 1;
    offset_cnt = 1;
    
    
    % combine all the regions before T(1)
    if vocal_onset(onset_cnt) < T(1)
        vocal_onset_t(1) = 1;
        while vocal_offset(offset_cnt) < T(1)
            offset_cnt = offset_cnt+1;
        end
        if offset_cnt > 1
            vocal_offset_t(1) = offset_cnt - 1;
            onset_cnt = offset_cnt;
        else
            onset_cnt = onset_cnt + 1;
        end
    end
    
    for i = 2:time_len_t-1
        if onset_cnt <= region_cnt
            if T(i-1) < vocal_onset(onset_cnt) && T(i) >= vocal_onset(onset_cnt)
                vocal_onset_t(onset_cnt) = i;
                onset_cnt = onset_cnt + 1;
            end
        end
        if offset_cnt <= region_cnt
            if T(i) <= vocal_offset(offset_cnt) && T(i+1) > vocal_offset(offset_cnt)
                vocal_offset_t(offset_cnt) = i;
                offset_cnt = offset_cnt + 1;
            end
        end
        if offset_cnt > region_cnt
            break
        end
    end
    if vocal_offset_t(end) == 0
        vocal_offset_t(end) = time_len_t;
    end
    
    % remove onsets and offsets who has the same time
    
    
    % change to bool array
    
    vocal = zeros(size(T));
    for i = 1:region_cnt
        vocal(vocal_onset_t(i):vocal_offset_t(i)) = ones(1, vocal_offset_t(i)-vocal_onset_t(i)+1);
    end
    
    
    % the same to nonvocal regions
    nonvocal = ~vocal;
    non_region_onset = [];
    non_region_offset = [];
    cnt = 1;
    while cnt <= size(T,2)
        if nonvocal(cnt) == 1
            non_region_onset(end+1) = cnt;
            cnt = cnt + 1;
            % search through next 0
            while cnt < size(T,2) && nonvocal(cnt) == 1
                cnt = cnt + 1;
            end
            non_region_offset(end+1) = cnt-1;
        else
            cnt = cnt + 1;
        end
    end
    %{
    % remove onsets and offsets who has the same time
    same_time = (non_region_onset ~= non_region_offset);
    non_region_onset = non_region_onset(same_time);
    non_region_offset = non_region_offset(same_time);
    %}
    
    non_region_cnt = size(non_region_onset,2);
    
    % combine together, make a single cell
    spec_block = cell(0);
    v_cnt = 0;
    non_cnt = 0;
    total_cnt = region_cnt + non_region_cnt;
    block_type = zeros(1,total_cnt);
    while v_cnt + non_cnt <= total_cnt
        if v_cnt < region_cnt && non_cnt < non_region_cnt
            if vocal_onset_t(v_cnt+1) < non_region_onset(non_cnt+1)
                v_cnt = v_cnt + 1;
                block_type(v_cnt + non_cnt) = 1;
                vocal_b = zeros(size(T));
                vocal_b(vocal_onset_t(v_cnt):vocal_offset_t(v_cnt)) = ones(1, vocal_offset_t(v_cnt)-vocal_onset_t(v_cnt)+1);
                spec_block{end+1} = vocal_b;

            else
                non_cnt = non_cnt + 1;
                nonvocal_b = zeros(size(T));
                nonvocal_b(non_region_onset(non_cnt):non_region_offset(non_cnt)) = ones(1, non_region_offset(non_cnt)-non_region_onset(non_cnt)+1);
                spec_block{end+1} = nonvocal_b;
            end
        elseif v_cnt >= region_cnt
            for i = non_cnt+1:non_region_cnt
                nonvocal_b = zeros(size(T));
                nonvocal_b(non_region_onset(i):non_region_offset(i)) = ones(1, non_region_offset(i)-non_region_onset(i)+1);
                spec_block{end+1} = nonvocal_b;
            end
            break
        elseif non_cnt >= non_region_cnt
            for i = v_cnt+1:region_cnt
                vocal_b = zeros(size(T));
                vocal_b(vocal_onset_t(i):vocal_offset_t(i)) = ones(1, vocal_offset_t(i)-vocal_onset_t(i)+1);
                spec_block{end+1} = vocal_b;
            end
            break
        end
    end
    
end
    
            
        
        