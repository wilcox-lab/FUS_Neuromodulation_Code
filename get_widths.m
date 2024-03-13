function [avg_width,norm_widths] = get_widths(input_data,mat_data,trdata,fs,duration)

n = 1; 
[~, ~, positiveWBaseline, ~] =findpeaks(mat_data(:,1));
[~, ~, negativeWBaseline, ~] =findpeaks(-mat_data(:,1));
start_time = datevec(trdata.timestamp(1,1));

baseline_width = (mean(positiveWBaseline)+ mean(negativeWBaseline))/fs;

while n<= length(input_data(:,1))
    start_event = [input_data(n,1),input_data(n,2),input_data(n,3),input_data(n,4),input_data(n,5),input_data(n,6)]; 
   
    current_event_start = start_event - start_time; 
    seconds_post = (current_event_start(1,4)*3600)+(current_event_start(1,5)*60)+(current_event_start(1,6));
    converted_seconds_post = seconds_post*fs;
    end_event_converted = converted_seconds_post + duration(n)*fs;
    event_data = mat_data(converted_seconds_post:end_event_converted,1);
    
    [~,~,pos_widths,~] = findpeaks(event_data);
    [~,~,neg_widths,~] = findpeaks(-event_data);
    avg_width(n) = (mean(pos_widths)+ mean(neg_widths))/fs;
    n = n+1;
end

norm_widths = (avg_width./baseline_width) * 100;