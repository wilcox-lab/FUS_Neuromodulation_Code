%%filereader
%Takes all the acq files in a folder and feeds them to the file converter
%program

matFiles = dir('*.mat'); 
numfiles = length(matFiles);


for k = 1:numfiles 
   
    file_converter_timing_script_updatedV3(matFiles(k).name); 
   
end