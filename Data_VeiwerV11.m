%% preamble 
% 04/11/23 - fixed for param 34, wouldn't plot for two files. 
%04/10/23 - Made it work for parameter set 34(edge case with event occuring at start of file )
% Updated 04/04/23 - Checked for event to be the same size 
% Updated 03/30/23 - Fixed offset of events
% Updated 03/26/23 - only one figure appears now when viewing
% Updated 03/19/23 - include number of seconds determined by user before 
% and after each sevent, save a .fig and .jpg for each event confirmed as 
% yes, updated to show event in red and baseline in blue
% Updated 12/09/22 - include the HH:MM:SS on the x-axis of the raw eeg file 
% to allow for comparison btw dv event and raw eeg
%%https://onlinelibrary.wiley.com/doi/full/10.1002/epi4.2 
% link to paper onclassification on HVSWs and HPDs by Dr. Löscher
clc, clear all, close all


%% Get Files 

[data, index] = get_single_file; 
[filename, pathname] = uigetfile("*.mat","Select Files", 'MultiSelect', 'on');
fullpath = fullfile(pathname, filename);  %creates full path w/ name and in order
load(string(fullpath));


%% Cut offs
fs = 5000;
while 1 
    answer1 = input("Would you like to add cut offs for the duration? (y/n): ",'s');
    if answer1 == 'n'
        Data = data;
        break 
    elseif answer1 == 'y'
            answer2 = input('enter lower limit: ');
            answer3 = input('enter upper limit: ');
            l = 1;
            d = 1;
            while l <= length(data(:,1))
                if data(l,13) <= answer3 & data(l,13) >= answer2;
                    Data(d,:) = data(l,:);
                    d = d+1; 
                else
                
                end
                l = l+1; 
            end
            break
    else
        disp('Type either y or n');
    end
end

%% Durations 
n = 1; 
while n <= length(Data(:,1))
    duration(n) = Data(n,13);
    n = n+1;
end 
average_duration = mean(duration);
longest_duration = (max(duration));

%% include HPDS?
HPD_answer = input('Would you like to review HPDS? (y/n): ','s');

%%
wanted_seconds = input('Enter the number of seconds you want before/after the event: ');
%% Make new files for pictures
jpeg_name = append(filename,'_jpg_folder');
fig_folder = append(filename,'_fig_folder');
mkdir(jpeg_name);
mkdir(fig_folder);
current_directory = pwd; 
%% plotter 
hvsw_data = zeros(length(data(:,1)),30); % preallocating to allow for instance in which no HVSWs occur. 
hpd_data = zeros(length(data(:,1)),30); 

start_time = datevec(trdata(1).timestamp(1,1));
s_date_time = datetime(start_time);
s_date_time.Format = 'hh:mm:ss.SSSS';

end_time = datevec(trdata(1).timestamp(1,2));
e_date_time = datetime(end_time);
e_date_time.Format = 'hh:mm:ss.SSSS';

length_of = end_time - start_time;
length_seconds  = (length_of(1,4)*3600)+(length_of(1,5)*60)+(length_of(1,6));
length_converted = length_seconds*5000;

n = 1;
q = 1; 
w = 1;

Total_time_vec = (s_date_time : milliseconds(0.2) : e_date_time).';
Total_time_vec.Format = 'hh:mm:ss.SSSS';
save_count = 1;
%%
while n <= length(Data(:,1))
    hold off
    start_event = [Data(n,1),Data(n,2),Data(n,3),Data(n,4),Data(n,5),Data(n,6)];
    end_event = [Data(n,7),Data(n,8),Data(n,9),Data(n,10),Data(n,11),Data(n,12)];
    s = datetime(start_event);
    s.Format = 'hh:mm:ss.SSSS';
    e = datetime(end_event);
    e.Format = 'hh:mm:ss.SSSS';

    
    negative_spike_count = Data(n,19);
    positive_spike_count = Data(n,18);
    total_spikes = negative_spike_count; % change here for positive or negative spike animals. 
    frequency = total_spikes/duration(n);
    
    condition_1 = s - seconds(wanted_seconds) > s_date_time;
    condition_2 = e + seconds(wanted_seconds) < e_date_time;
    if(condition_1 & condition_2)
        
        buffer_vec = [s - seconds(wanted_seconds):milliseconds(0.2):e + seconds(wanted_seconds)];
        event = [s:milliseconds(0.2):e];
  
        
    elseif(condition_1 & ~ condition_2 )
        
        buffer_vec = [s - seconds(wanted_seconds):milliseconds(0.2):e_date_time];
        event = [s:milliseconds(0.2):e];
        
        
    elseif(~condition_1 & condition_2)
        
        buffer_vec = [s_date_time:milliseconds(0.2):e + seconds(wanted_seconds)];
        event = [s:milliseconds(0.2):e];
        
    end
        ind_s_buffer = seconds(buffer_vec(1)-s_date_time) *fs;
        ind_e_buffer = seconds(buffer_vec(end)-s_date_time) *fs;
        ind_s_event = seconds(event(1)-s_date_time) *fs;
        ind_e_event = seconds(event(end)-s_date_time) *fs;
        event_1 =sbuf(ind_s_buffer+1:ind_e_buffer,1);
        event_2 =sbuf(ind_s_event+1:ind_e_event,1); 
        check1  = length(event_1) - length(buffer_vec);
        check2 = length(event_2) - length(event);
        if check1 < 0 
           buffer_vec(end+check1+1:end) = [];
        elseif check1 > 0 
            event_1(end-check1+1:end) = [];
        end
         if check2 < 0 
           event(end+check2+1:end) = [];
        elseif check2 > 0 
            event_2(end-check2+1:end) = [];
        end
    if HPD_answer == 'y' 
        if frequency <= 5 % reviewing HVSWs
            h = figure(1);
            plot(buffer_vec,event_1,'b')
            hold on,
            plot(event,event_2,'r'),
            x_ticks = unique([buffer_vec(1):seconds(wanted_seconds/3):buffer_vec(wanted_seconds*5000), event(1):seconds((length(event)/5000)/3):event(end), buffer_vec((wanted_seconds*5000)+length(event)):seconds(wanted_seconds/3):buffer_vec(end)]);
            x_ticks.Format('hh:mm:ss.S');
            xticks(x_ticks)
            legend(append(append(' HVSW #',num2str(n)),append(' positive spikes = ',num2str(positive_spike_count)),append(' negative spikes = ',num2str(negative_spike_count)), append(' duration = ',num2str(duration(n))), append(' frequency = ',num2str(frequency))));
            ylabel('EEG Voltage (mV)')
            xlabel('Time (seconds)')
            title(append('HVSW Occuring at, ',datestr(event(1))))
            while 1
                in = input('type y if is a HVSW press n if not: ','s');
                if in == 'y'
                    hvsw_data(q,:) = Data(n,:);
                    q = q+1;
                    saveas(h,append(current_directory,'/',jpeg_name,'/','HVSW_#',num2str(save_count),'.jpg'))
                    saveas(h,append(current_directory,'/',fig_folder,'/','HVSW_#',num2str(save_count)))
                    save_count = save_count+1; 
                    break;
                elseif in == 'n'
                    break;
                else
                    disp('please enter y or n')
                end
            end
            clf('reset')
        elseif frequency > 5 % review of HPDs
            h = figure(1);
            plot(buffer_vec,event_1,'b')
            hold on,
            plot(event,event_2,'r'),
            x_ticks = unique([buffer_vec(1):seconds(wanted_seconds/3):buffer_vec(wanted_seconds*5000), event(1):seconds((length(event)/5000)/3):event(end), buffer_vec((wanted_seconds*5000)+length(event)):seconds(wanted_seconds/3):buffer_vec(end)]);
            x_ticks.Format('hh:mm:ss.S');
            xticks(x_ticks)
            legend(append(append(' HVSW #',num2str(n)),append(' positive spikes = ',num2str(positive_spike_count)),append(' negative spikes = ',num2str(negative_spike_count)), append(' duration = ',num2str(duration(n))), append(' frequency = ',num2str(frequency))));
            ylabel('EEG Voltage (mV)')
            xlabel('Time (seconds)')
            title(append('HPD Occuring at, ',datestr(event(1))))
            while 1
                in = input('type y if is a HVSW press n if not: ','s');
                if in == 'y'
                    hpd_data(q,:) = Data(n,:);
                    q = q+1;
                    saveas(h,append(current_directory,'/',jpeg_name,'/','HPD_#',num2str(save_count),'.jpg'))
                    saveas(h,append(current_directory,'/',fig_folder,'/','HPD_#',num2str(save_count)))
                    save_count = save_count+1; 
                    break;
                elseif in == 'n'
                    break;
                else
                    disp('please enter y or n')
                end
            end
        end
        clf('reset')
    else
       h = figure(1);
            plot(buffer_vec,event_1,'b')
            hold on,
            plot(event,event_2,'r'),
            x_ticks = unique([buffer_vec(1):seconds(wanted_seconds/3):buffer_vec(wanted_seconds*5000), event(1):seconds((length(event)/5000)/3):event(end), buffer_vec((wanted_seconds*5000)+length(event)):seconds(wanted_seconds/3):buffer_vec(end)]);
            x_ticks.Format('hh:mm:ss.S');
            xticks(x_ticks)
            legend(append(append(' HVSW #',num2str(n)),append(' positive spikes = ',num2str(positive_spike_count)),append(' negative spikes = ',num2str(negative_spike_count)), append(' duration = ',num2str(duration(n))), append(' frequency = ',num2str(frequency))));
            ylabel('EEG Voltage (mV)')
            xlabel('Time (seconds)')
            title(append('HVSW Occuring at, ',datestr(event(1))))
            while 1
                in = input('type y if is a HVSW press n if not: ','s');
                if in == 'y'
                    hvsw_data(q,:) = Data(n,:);
                    q = q+1;
                    saveas(h,append(current_directory,'/',jpeg_name,'/','HVSW_#',num2str(save_count),'.jpg'))
                    saveas(h,append(current_directory,'/',fig_folder,'/','HVSW_#',num2str(save_count)))
                    save_count = save_count+1; 
                    break;
                elseif in == 'n'
                    break;
                else
                    disp('please enter y or n')
                end
            end
            clf('reset')
    end
    n = n+1;
end

close

%% saving updated csv files 
csvwrite(append(filename,'_HVSW.csv'),hvsw_data)