% Last update 12/06/22 fixed NaN issues 
%% preamble 
clc, clear all, close all

%% Get Files

[list,tf] = listdlg('PromptString','Select files to analyze','ListString',{'HVSW/HPD','HVSW only','HPD only'});

if ismember(1,list)
    disp('Input HVSW files ')
    [swData, swindex] = get_single_file;
    [filename, pathname] = uigetfile("*.mat","Select Files", 'MultiSelect', 'on');
    fullpath = fullfile(pathname, filename);  %creates full path w/ name and in order
    load(string(fullpath));
    disp('Input HPD files')
    [hpdData, hpdindex] = get_single_file;
    swData(isnan(swData)) = 0;
    swData(all(~swData,2),:) = [];
    hpdData(isnan(hpdData)) = 0;
    hpdData(all(~hpdData,2),:) = [];
    
elseif ismember(2,list)
        disp('Input HVSW files ')
    [swData, swindex] = get_single_file;
    [filename, pathname] = uigetfile("*.mat","Select Files", 'MultiSelect', 'on');
    fullpath = fullfile(pathname, filename);  
    load(string(fullpath));
    swData(all(~swData,2),:) = [];
   
elseif ismember(3,list)
        disp('Input HPD files')
    [hpdData, hpdindex] = get_single_file;
    [filename, pathname] = uigetfile("*.mat","Select Files", 'MultiSelect', 'on');
    fullpath = fullfile(pathname, filename); 
    load(string(fullpath));
    hpdData(all(~hpdData,2),:) = [];
end
%% interictal periods 
if ismember(1,list)
    hvsw_interictal_period = interictal_periods(swData);
    hpd_interictal_period = interictal_periods(hpdData);
elseif ismember(2,list)
    hvsw_interictal_period = interictal_periods(swData);
elseif ismember(3,list)
    hpd_interictal_period = interictal_periods(hpdData);
end

%% Durations 
if ismember(1,list)
    hvsw_duration = get_duration(swData);
    hpd_duration = get_duration(hpdData);
elseif ismember(2,list)
    hvsw_duration = get_duration(swData);
elseif ismember(3,list)
    hpd_duration = get_duration(hpdData);
end

%% Amplitude 
% not given by the CSV
%start and end time of file are found in 'trdata’ from the original .mat
%file entered into the gui (combined.mat) if you use datevec comand on
%'trdata.timestamp(1,1)'(starttime) or 'trdata.timestamp(1,2)(endtime) you
%will have the start time and end time. 
if ismember(1,list)
    [hvsw_avg_pos_amp,hvsw_avg_neg_amp,hvsw_norm_pos_amp,hvsw_norm_neg_amp] = get_amplitude(swData,sbuf,trdata,hvsw_duration,fs);
    [hpd_avg_pos_amp, hpd_avg_neg_amp, hpd_norm_pos_amp, hpd_norm_neg_amp] = get_amplitude(hpdData,sbuf,trdata,hpd_duration,fs);
elseif ismember(2,list)
    [hvsw_avg_pos_amp,hvsw_avg_neg_amp,hvsw_norm_pos_amp,hvsw_norm_neg_amp] = get_amplitude(swData,sbuf,trdata,hvsw_duration,fs);
elseif ismember(3,list)
    [hpd_avg_pos_amp, hpd_avg_neg_amp, hpd_norm_pos_amp, hpd_norm_neg_amp] = get_amplitude(hpdData,sbuf,trdata,hpd_duration,fs);
end

%% Widths 
if ismember(1,list)
    [hvsw_avg_width,hvsw_norm_width] = get_widths(swData,sbuf,trdata,fs,hvsw_duration);
    [hpd_avg_width,hpd_norm_width] = get_widths(hpdData,sbuf,trdata,fs,hpd_duration);
elseif ismember(2,list)
    [hvsw_avg_width,hvsw_norm_width] = get_widths(swData,sbuf,trdata,fs,hvsw_duration);
elseif ismember(3,list)
    [hpd_avg_width,hpd_norm_width] = get_widths(hpdData,sbuf,trdata,fs,hpd_duration);
end

%% event Frequency 
if ismember(1,list)
    [hvsw_frequency] = get_frequency(swData,sbuf,trdata,hvsw_duration);
    [hpd_frequency] = get_frequency(hpdData,sbuf,trdata,hpd_duration);
elseif ismember(2,list)
    [hvsw_frequency] = get_frequency(swData,sbuf,trdata,hvsw_duration);
elseif ismember(3,list)
    [hpd_frequency] = get_frequency(hpdData,sbuf,trdata,hpd_duration);
end
%% 
if ismember(1,list)
    hvsw_label = repmat({'hvsw'},length(swData(:,1)),1);
    hpd_label = repmat({'hpd'},length(hpdData(:,1)),1);
elseif ismember(2,list)
    hvsw_label = repmat({'hvsw'},length(swData(:,1)),1);
elseif ismember(3,list)
    hpd_label = repmat({'hpd'},length(hpdData(:,1)),1);
end 

%%
nmod_number = input('enter nmod number: ','s');
parameter_number = input('enter parameter number: ','s');
condition = input('Enter treatment condition(ie fus_true_sham): ','s');
if ismember(1,list)
    animal_vector = (repmat(string(nmod_number),(length(hpdData(:,1))+length(swData(:,1))),1));
    parameter_vector = (repmat(string(parameter_number),(length(hpdData(:,1))+length(swData(:,1))),1));
    condition_vector = (repmat(string(condition),(length(hpdData(:,1))+length(swData(:,1))),1));
elseif ismember(2,list)
    animal_vector = (repmat(string(nmod_number),length(swData(:,1)),1));
    parameter_vector = (repmat(string(parameter_number),length(swData(:,1)),1));
    condition_vector = (repmat(string(condition),length(swData(:,1)),1));
    hpdData = [];
elseif ismember(3,list)
    animal_vector = (repmat(string(nmod_number),length(hpdData(:,1)),1));
    parameter_vector = (repmat(string(parameter_number),length(hpdData(:,1)),1));
    condition_vector = (repmat(string(condition),length(hpdData(:,1)),1));
    swData = [];
end 
%%
if ismember(1,list)
    interictal_period = [hvsw_interictal_period; hpd_interictal_period];
    duration = [hvsw_duration, hpd_duration];
    avg_negative_amplitude = [hvsw_avg_neg_amp, hpd_avg_neg_amp];
    avg_positive_amplitude = [hvsw_avg_pos_amp, hpd_avg_pos_amp];
    avg_width = [hvsw_avg_width,hpd_avg_width];
    norm_pos_amp = [hvsw_norm_pos_amp hpd_norm_pos_amp];
    norm_neg_amp = [hvsw_norm_neg_amp hpd_norm_neg_amp];
    norm_widths = [hvsw_norm_width,hpd_norm_width];
    frequency  = [hvsw_frequency hpd_frequency];
    label = [hvsw_label;hpd_label];
    percent_hvsw = (length(swData(:,1))/(length(hpdData(:,1))+length(swData(:,1)))) * 100;
    disp(append(num2str(percent_hvsw),'% of events are HVSWs'))
elseif ismember(2,list)
    interictal_period = [hvsw_interictal_period];
    duration = [hvsw_duration];
    avg_negative_amplitude = [hvsw_avg_neg_amp];
    avg_positive_amplitude = [hvsw_avg_pos_amp];
    avg_width = [hvsw_avg_width];
    norm_pos_amp = [hvsw_norm_pos_amp];
    norm_neg_amp = [hvsw_norm_neg_amp];
    norm_widths = [hvsw_norm_width];
    frequency  = [hvsw_frequency];
    label = [hvsw_label];
elseif ismember(3,list)
    interictal_period = [hpd_interictal_period];
    duration = [hpd_duration];
    avg_negative_amplitude = [hpd_avg_neg_amp];
    avg_positive_amplitude = [hpd_avg_pos_amp];
    avg_width = [hpd_avg_width];
    norm_pos_amp = [hpd_norm_pos_amp];
    norm_neg_amp = [hpd_norm_neg_amp];
    norm_widths = [hpd_norm_width];
    frequency  = [hpd_frequency];
    label = [hpd_label];
end 
%%
param_table = table(animal_vector,parameter_vector,condition_vector,interictal_period,duration',avg_negative_amplitude',avg_positive_amplitude',avg_width',norm_pos_amp',norm_neg_amp',norm_widths',frequency',label,'VariableNames',{'Animal Number','Parameter Set','Treatment Condition','Interictal Period','Duration','Average Negative Peak','Average Positive Peak','Average Width','Normalized Negative Amplitude','Normalized Positive Amplitude','Normalized Width','frequency','Event Type'});
number_table = table(animal_vector(1,1),parameter_vector(1,1),condition_vector(1,1),length(swData(:,1)),length(hpdData(:,1)),'VariableNames',{'Animal Number','Parameter Set','Treatment Condition','HVSW Count','HPD Count'});
%% Saving Files 
filename = input('Enter file name: ', 's');
save(append(filename,'.mat'),'param_table','number_table');



