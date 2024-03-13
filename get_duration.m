function [duration] = get_duration(input_data)
% Retrives duration for each event from gui csv 
n = 1;
duration = zeros([1,length(input_data(:,1))]);
while n <= length(input_data(:,1))
    duration(n) = input_data(n,13);
    n = n+1;
end 

