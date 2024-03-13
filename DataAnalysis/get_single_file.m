function [data, size] = get_single_file

[filename, pathname] = uigetfile("*.csv","Select Files", 'MultiSelect', 'on');
fullpath = fullfile(pathname, filename);  %creates full path w/ name and in order
data = readmatrix(string(fullpath));
data;
size = [1];
