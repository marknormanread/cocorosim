%
% Script identifies all cocorosim output files in a directory, reads them, and compiles their median values, which 
% are then written to another file. 
%
%


path = pwd;
k = findstr('cocorosim',path);
headDir = path(1:k(end)-1);          % dynamically locate where teh data analysis file is located, based in searching for 'Treg_2D' in the current working dir. 

addpath(genpath([headDir 'cocorosim/boids6-profiling/output/analysis_scripts/matlab_helper_functions']))


dataPrefix = 'cocorosim-output_-_';   % prefix for cocorosim output files. 
medianDataFileName = 'cocorosim-median.txt'; % the name of the file that the median data will be written to.

files = dir([dataPrefix '*'])         % '*' is a wild card, this is matlabs way of finding all file names that start with a particular string.

[unused,order] = sortn({files(:).name}); % sortn will sort strings and treat number characters as numbers, so 'c10' will come before 'c101'. 
files(:) = files(order);              % reorder files such that they are sorted in ascending order. 


% 
%------------------------------------------------
% Open an example file and find out how many rows and lines the table contains.
% In this manner the contents of the tables can change (because more information was wanted at a later date) without breaking
% this script. 
fid = fopen(files(1).name, 'r');      % open up one of the input files. 
comments = fgetl(fid);               % retrieve the first line from the file. This will be a comment, and so we drop it by reading and ignoring it.
firstLine = fgetl(fid);               % read in a line of actual data. s
numCols = length(find(firstLine == ' ')); % each data item in the table should be followed by a space, so number of collumns corresponds to number of spaces.
fclose(fid);

fid = fopen(files(1).name, 'r');      % will now find how many rows there are in the table
firstlLine = fgetl(fid);              % drop the first line, which is a comment. 
example = fscanf(fid, '%f ', [numCols, Inf]); % scans in the file, with the first line (comment) removed, and loads the data into a matrix. 
numRows = length(example(1,:));       % count the number of rows in the matrix
fclose(fid);
%------------------------------------------------


% This data structure will hold all the data from all the data files found in the current directory. 
% It has three dimensions: file_number X columns X rows. 
allData = zeros(length(files), numCols, numRows);
for run = 1:length(files)             % read in one file at a time
  files(run).name
  fid = fopen(files(run).name, 'r');
    fgetl(fid);                       % throw away the first line, its only a comment. 
    allData(run,:,:) = fscanf(fid, '%f ',[numCols,Inf]); % load in the entire data file. 
  fclose(fid); 
end  

% Create a separate data structure for the median data to be stored in. 
medians = zeros(numCols, numRows);

for col = 1:numCols
  for row = 1:numRows
   medians(col,row) = median(allData(:,col,row));   % calculate the median for this data item across all files. 
  end
end

% write the median data to the file system
fid = fopen(medianDataFileName, 'w');
fprintf(fid,'%s\n', comments);
for row = 1:numRows
  for col = 1:numCols
    fprintf(fid, '%g ', medians(col,row));
  end
  fprintf(fid, '\n');
end
fclose(fid);
