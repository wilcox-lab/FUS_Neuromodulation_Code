function [interictal_period] = interictal_periods(input_data)
n = 1;
interictal_period = zeros([1,length(input_data(:,1))]);
time_1 = 0;
time_2 = 0; 
while n < length(input_data(:,1))
    time_1 = (input_data(n,10)*3600)+(input_data(n,11)*60)+(input_data(n,12)); 
    time_2 = (input_data(n+1,4)*3600)+(input_data(n+1,5)*60)+(input_data(n+1,6)); 
    interictal_period(n) = time_2-time_1;
    n = n+1;
end 
interictal_period = interictal_period';
