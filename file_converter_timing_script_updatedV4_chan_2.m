%4.6.23 adjusted to take out zero-ing out fus signal from channel 2, not
%needed for pre- and post-fus and it was zeroing out relevant eeg signal

function file_converter_timing_script_updatedV4_chan_2(n)
data  = load(n);
data1 = data.channels{1,1};
data2 = data.channels{1,2};
chan_1 = data1.data; %mouse_eeg
chan_2 = data2.data; %fus_eeg

% %Adding an offset to the mouse signal to prevent accidental cancelling out of
% %data
% if min(chan_1) < 0
%     chan_1_off = (-2*min(chan_1))+chan_1;
% else 
%     chan_1_off = min(chan_1)+chan_1;
% end

chan_2_bin = chan_2;

%Zero-ing out relevant data and making data binary signal for ease of
%processing

% chan_2_min = .5*min(chan_2_bin);
% chan_2_max = .5*max(chan_2_bin);
% chan_2_length = length(chan_2);
% i = 1; 
% if abs(min(chan_2)) > abs(max(chan_2))
%       chan_2_bin = chan_2 > chan_2_min;
% else
%       chan_2_bin = chan_2 < chan_2_max;
% end
%Combine signals
combined_signal = chan_2_bin;

sbuf = combined_signal(1,:);
sbuf = sbuf';
number_of_channels = size(combined_signal,2);

fs = data1.samples_per_second;

event_data = data.event_markers{1,1};
label = event_data.label;
split_label = split(label);
datestring = strrep(append(split_label(5),'-',split_label(4),'-',split_label(6),' ',split_label(7)),',','');
start_time = datenum(datestring);

j = 1;
while j <= length(data.channels) 
     trdata(j).timestamp = [start_time, (start_time + (size(chan_2, 2)-1)/(fs*3600*24))];
     j = j+1;
end
ext = 'combined';
new_name = append(n(1:end-4), ext);

save (new_name, 'sbuf', 'number_of_channels', 'fs', 'trdata', '-v7.3'); 


