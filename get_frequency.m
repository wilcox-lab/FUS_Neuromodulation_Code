function [frequency] = get_frequency(Data,mat_data,trdata,duration)
% sums event frequency by loading csv data 
n = 1; 
start_time = datevec(trdata.timestamp(1,1));
while n<= length(Data(:,1))
    start_event = [Data(n,1),Data(n,2),Data(n,3),Data(n,4),Data(n,5),Data(n,6)]; 
    current_event_start = start_event-start_time; 
    seconds_post = (current_event_start(1,4)*3600)+(current_event_start(1,5)*60)+(current_event_start(1,6));
    converted_seconds_post = seconds_post*5000;
    end_event_converted = converted_seconds_post + duration(n)*5000;
    event_data = mat_data(converted_seconds_post:end_event_converted,1);
    negative_spike_count = Data(n,19);
    positive_spike_count = Data(n,18);
    total_spikes = negative_spike_count+positive_spike_count;
    frequency(n) = total_spikes/duration(n);
    n = n+1;
end