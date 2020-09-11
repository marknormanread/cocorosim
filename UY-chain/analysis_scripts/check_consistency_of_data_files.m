%
% Matlab script designed to inspect all the cocorosim output data files in directory and ensure that the experiment completed correctly. 
% 
% Current checks (to which more may be added in time) are as follows:
% 1) That the correct number of files is found in the directory. The number is specified through a function argument. 
% 2) Checks that each file is present, and outputs which run numbers are missing. 
%

function check_consistency_of_data_files(ARGS)
ARGS


path = pwd;
k = findstr('cocorosim',path);
headDir = path(1:k(end)-1);           % dynamically locate where teh data analysis file is located, based in searching for 'Treg_2D' in the current working dir. 

addpath(genpath([headDir 'cocorosim/boids6-profiling/output/analysis_scripts/matlab_helper_functions']))


numRuns = -1;                         % this must be supplied as an argument, so it is set as an impossible number here. 
%----------------------
% read in function arguments
args = split_str([' '], ARGS);        % split the arguments string acording to spaces. 

for i = 1 : length(args)              % go through each argument in turn
  if strcmp(args{i}, '-numRuns')      % input the number of runs expected. This corresponds with the number of single run data files expected to be found. 
    numRuns = str2num(args{i+1}); 
  end
end
%----------------------



dataPrefix = 'cocorosim-output_-_';               % prefix for the cocorosim output files. 

files = dir([dataPrefix '*']);
[unused,order] = sortn({files(:).name});          % sortn will sort strings and treat number characters as numbers, so 'c10' will come before 'c101'. 
files(:) = files(order);                          % reorder files such that they are sorted in ascending order. 


failureFound = false;                              % the default case, errors may however be caught during this script's execution, changing this variables state.

fid_res = fopen('consistency_of_data_result','w');

tmp = split_str(['/'], pwd);                      % extract the last part of the directory name, used in locating the source of errors when outputting. 
dirName = tmp{end};                 

% -------
% first test, are the expected number of simulation runs' data present?
if length(files) ~= numRuns
  failureFound = true
  fprintf(2, 'FAIL: %s - found only %u cocorosim data files, but was expecting %u\n',dirName, length(files), numRuns);
  fprintf(fid_res, 'Fail: %s - found only %u cocorosim data files, but was expecting %u\n',dirName, length(files), numRuns);
end
% -------


% -------
% second test: are the cocoro data files well ordered? No missing file names?
numbersPresent = [];                              % will extract all the run numbers present and place their integer values in this array. 
for f = 1:length(files)
  tmp = split_str(['_'],files(f).name);
  numbersPresent(end + 1) = str2num(tmp{end});
end

for expected = 1:numRuns
  if ~any(expected == numbersPresent)             % failed to find the expected run number in the array of numbers present.
    fprintf(1, 'FAIL: %s - this run number is missing from directory: %u\n', dirName, expected);
    fprintf(fid_res, 'FAIL: %s - this run number is missing from directory: %u\n', dirName, expected);
  end
end
% -------

if failureFound == false
  fprintf(1, 'PASS for directory %s\n', dirName);
  fprintf(fid_res, 'PASS for directory %s\n', dirName);
else
  fprintf(1,'FAIL for directory%s\n', dirName);
end


fclose(fid_res);
