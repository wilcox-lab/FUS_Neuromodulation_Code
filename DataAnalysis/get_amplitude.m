function [avg_pos_amplitude,avg_neg_amplitude,norm_pos_amp,norm_neg_amp] = get_amplitude(input_data,mat_data,trdata,duration,fs)

start_time = datevec(trdata.timestamp(1,1));

n = 1;
while n<= length(input_data(:,1))
    start_event = [input_data(n,1),input_data(n,2),input_data(n,3),input_data(n,4),input_data(n,5),input_data(n,6)]; 
   
    current_event_start = start_event-start_time; 
    seconds_post = (current_event_start(1,4)*3600)+(current_event_start(1,5)*60)+(current_event_start(1,6));
    converted_seconds_post = seconds_post*fs;
    end_event_converted = converted_seconds_post + duration(n)*fs;
    event_data = mat_data(converted_seconds_post:end_event_converted,1);
    j = 1;
    w = 1;
    k = 1; 

    while j <= length(event_data)
        if event_data(j) < 0
            negative_data(w) = event_data(j);
            w = w+1;
        elseif event_data(j) > 0 
            positive_data(k) = event_data(j);
            k = k+1;
        else
        end
        j = j+1;
    end
    avg_pos_amplitude(n) = mean(positive_data);
    avg_neg_amplitude(n) = mean(negative_data);
    n = n+1;
end

neg_base_ind = mat_data(:,1) < 0; 
pos_base_ind = mat_data(:,1) > 0; 

pos_base = mean(mat_data(pos_base_ind));
neg_base = mean(mat_data(neg_base_ind));

norm_pos_amp = (avg_pos_amplitude./pos_base) * 100; 
norm_neg_amp = (avg_neg_amplitude./neg_base) * 100;
