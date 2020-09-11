% Script performs a robustness analysis with distribution data files. Each row in a distribution file should represent a simulation
% execution, and each column represents some response being measured. 
%
%
%
% The script is a function, such that command line arguments may be provided. These should take the form 
% "robustness_analysis('-units probability')"

function robustness_analysis(ARGS)
%ARGS = '-units dummy' 

drawGraphs = true;
FontSize = 18;
LineWidth = 2.0;
MarkerSize = 12.0;

path = pwd;
k = findstr('output',path);
headDir = path(1:k(end)-1);            % dynamically find absolute paths to the current working directories of cocorosim. 

addpath(genpath([headDir '/analysis_scripts/']));
addpath(genpath([headDir '/analysis_scripts/matlab_helper_functions']));


%---------------------------
% calculate the name of the current parameter. 
outputPostfix = pwd;                                % output postfix will appear on the end of the graphs generated in this script. 
temp = find( pwd == '/' );                          % find locations of all the forward slashes in the pwd.  
outputPostfix = outputPostfix( temp(end-1)+1 : temp(end)-1 );     % assign outputPostfix to everything following the last slash             
%---------------------------



%
% Read arguments
%
args = split_str([' '], ARGS)        % split the arguments string acording to spaces. 

paramUnitsProvided = false
paramUnits = ''
for i = 1 : length(args)             % go through each argument in turn
  if strcmp(args{i}, '-units')       % permits the provision of units for parameter that is subject to the current analysis. 
    paramUnits = args{i+1} 
    paramUnitsProvided = true        % this stops matlab attempting to automatically derive the units from the metadata parameters xml file. 
  end
end
paramUnits

dataPrefix = 'cocorosim-responses'   % the prefix for files that contain response data
files = dir([dataPrefix '*'])        % the '*' is a wild wild card. Specifying 'robustness_analysis...' will stop '.' and '..' appearing in the list. 
defaultFile = []                     % we will store the default file in this variable.
data = [];                           % store for all the data. data[n].paramVal will give the parameter value. data[n].data will give the associated data. 

responses = {'collisions', 'Wall-Collisions', 'lost swarm', 'boid speed', 'shoal speed', 'shoal separation', 'Max-shoal-Sep', 'Min-shoal-Sep', 'IRQ-shoal-Sep','polarisation','angular velocity','number shoals'};


aTestBoundsMin = 0.29; 
aTestBoundsMax = 0.71;


% remove the default file from the list, and store that separately. This assumes there is only one such file!
for p = 1:length(files)                         % arrays in matlab run from 1..size, not from zero.
  k = findstr(files(p).name, 'default');        % attempt to find the string 'default' in the file name. 
  if isempty(k) == 0                            % if the above succeeded, then 'k' will contain the index of where 'default' starts in the file name. 
    defaultFile = files(p);                     % save the default file.
    files(p) = [];                              % remove the default item from the 'files' array.
    break;
  end
end


% fetch the parameter value associated with each name.
for p = 1:length(files)                         % do this for all of the files found.
  name = files(p).name;                         % store the name of the file in a more convenient place.
  k = findstr('_',name);                        % creates a vector containing indexes of '_'
  data(p).paramVal = str2num(name(k(end)+1 : end))   % convert the string value to a number, and store.
end




% read each of the files found, and store their data in a struct array along with their parameter value.
for p = 1:length(files)
  fid = fopen(files(p).name, 'r');
  comments = fgetl(fid);                       % retrieve the first line from the file. This will be a comment, and so we drop it by reading and ignoring it.
  data(p).data = textscan(fid, '%f %f %f %f %f %f %f %f %f %f %f %f');    % read in responses
  fclose(fid);
end



% 'unused' stores an array of the sorted ParamVals, but we want to sort the entire structure based on those values, not those values alone. 
% So we are interested in 'order'
% This is necessary for plotting the data. Lines are drawn between consequtive items passed to the plot command. 
% If they're not sorted according to domain then you get strange artifacts. 
[unused, order] = sort([data(:).paramVal]);     
data = data(order);                              % reassign 'data' based on the correct ordering

% read the data for the default parameter value
fid = fopen(defaultFile.name, 'r');
  comments = fgetl(fid);                       % retrieve the first line from the file. This will be a comment, and so we drop it by reading and ignoring it.
  defaultData.data = textscan(fid, '%f %f %f %f %f %f %f %f %f %f %f %f');    % read in 9 responses
  underscoreLocations = find(defaultFile.name == '_');               % returns an array containing the locations of all the underscores in the string 'name'
  defaultData.paramVal = defaultFile.name(underscoreLocations(end) + 1 : end);    % the parameter value is the last thing in the name string following directly from the last underscore. 
fclose(fid);

% transform the raw parameter value data onto real-world scales and units
if exist('robustness_analysis_map_domain.m')
  V = [data(:).paramVal]
  newV = robustness_analysis_map_domain(V) 
  for p = 1:length(data)
    data(p).paramVal = newV(p);
  end
end

% compile statistical information and tests based on the data read into 'data'. 
for p = 1:length(data)                                                                      % do for each parameter value
  fprintf(1,'compiling data for parameter %s\n', num2str(data(p).paramVal))                
  for r = 1:length(data(p).data)                                                            % iterate over responses
    data(p).stats(r).defaultMedian = median(defaultData.data{r});                           % store the default value median 
    data(p).stats(r).median = median(data(p).data{r});                                      % store the parameter value median
    data(p).stats(r).A = Atest(data(p).data{r}, defaultData.data{r});                               % perform and store the value of the A test between default and paramete data .
          % calculate if the results of the A test are "biologically significant" according to the predefined boundaries. 
    if data(p).stats(r).A < aTestBoundsMin | data(p).stats(r).A > aTestBoundsMax
      data(p).stats(r).ATestSignificant = true;
    else      
      data(p).stats(r).ATestSignificant = false;
    end
    data(p).stats(r).IQR = iqr(data(p).data{r});                                            % calculate and store the interquartile range.   
  end
end


% pull data from the 'data' structure and place it in arrays that are more suitable for plotting graphs with. 
Ps = [];
As = [];
for p = 1:length(data)             % iterate through each parameter value
  for r = 1:length(data(p).stats)  % we start from 2, because the first column is not a reponse, it is the run number
    As(p, r) = data(p).stats(r).A;
    Ps(p) = data(p).paramVal;
  end
end
As                                 % uncomment if you want to see the data being generated. 
Ps



if drawGraphs
  clf;                                                % clear the figure of anything that might previously have been displayed. 

  % plot a graph of parameter values against A test scores. 
  hold on;
  plot(Ps, As(:, 1), 'k-s', 'LineWidth', LineWidth, 'MarkerSize',MarkerSize);     % Collisions
%  plot(Ps, As(:, 2), 'r-.s', 'LineWidth', LineWidth, 'MarkerSize',MarkerSize);    % Wall-Collisions
  plot(Ps, As(:, 3), 'k-o', 'LineWidth', LineWidth, 'MarkerSize',MarkerSize);     % Lost-Swarm-Instances
  plot(Ps, As(:, 4), 'k:x' , 'LineWidth', LineWidth, 'MarkerSize',MarkerSize);   % Avg-AUV-Spd
  plot(Ps, As(:, 5), 'k:+', 'LineWidth', LineWidth, 'MarkerSize',MarkerSize);     % Swarm-Spd
  plot(Ps, As(:, 6), 'k--p', 'LineWidth', LineWidth, 'MarkerSize',MarkerSize);    % Avg-Swarm-Sep
%  plot(Ps, As(:, 7), 'g-v', 'LineWidth', LineWidth, 'MarkerSize',MarkerSize);     % Max-Swarm-Sep
%  plot(Ps, As(:, 8), 'g-.v', 'LineWidth', LineWidth, 'MarkerSize',MarkerSize);    % Min-Swarm-Sep
%  plot(Ps, As(:, 9), 'k--*', 'LineWidth', LineWidth, 'MarkerSize',MarkerSize);     % IRQ-Swarm-Sep
  plot(Ps, As(:,10), 'k-.^', 'LineWidth', LineWidth, 'MarkerSize',MarkerSize);     % Swarm polarisation
  plot(Ps, As(:,11), 'k-.v', 'LineWidth', LineWidth, 'MarkerSize',MarkerSize);     % Swarm Angular Velocity
  plot(Ps, As(:,12), 'k-d' , 'LineWidth', LineWidth, 'MarkerSize',MarkerSize);

  set(gca,'box','on');
  set(gca,'LineWidth',LineWidth);                       % draw a thicker box around the plot. 
  hold off;

   
  line([Ps(1), Ps(length(Ps))], [0.71, 0.71], 'color', 'k', 'LineStyle', ':','LineWidth',LineWidth)   % draw the 0.71 effect magnitude line
  line([Ps(1), Ps(length(Ps))], [0.29, 0.29], 'color', 'k', 'LineStyle', ':','LineWidth',LineWidth)   % draw the 0.29 effect magnitude line

  B = [Ps(1), Ps(end), 0.0, 1.0];                     % axis ranges, [xmin, xmax, ymin, ymax].
  axis(B);                                            % replot with differen mins and maxes for axes
  graph_legend = responses;                           % not all responses are to be plotted. 
  graph_legend([2,7,8,9]) = [];                           % remove response names from legend
%  legend(graph_legend,'Location','NorthEast','FontSize',FontSize) % write the legend, which lines are which responses.

  set(gca,'FontSize',FontSize);
  x_Label = ['Parameter value (' paramUnits ')'];

  ylabel('A test score','FontSize',FontSize);
  xlabel(x_Label,'FontSize',FontSize);


  print('-dpng', '-r300', [pwd '/' 'Atest'])    % write the graph to the file system. 


  % for each response, plot the medians in terms of the actual response data, showing medians, IRQs, extereme values, and outliers. 
  for r = 1:length(responses)
    name = responses{r};
    name(ismember(name,' ')) = []                                 % the function around 'name' here removes all the spaces from the string

    y_Label = 'response value';

    robustness_analysis_plot_response_distribution(data, Ps, defaultData, r, name, '', x_Label, y_Label)
  end




  %----------------------------
  % Print the responses for each parameter value to the file system. 
  fid = fopen('robustness_analysis_-_ScoresATest','w');
  fprintf(fid,'#param value, Collisions Wall-Collisions Lost-Swarm-Instances Avg-AUV-Spd Swarm-Spd Avg-Swarm-Sep Max-Swarm-Sep Min-Swarm-Sep IRQ-Swarm-Sep Polarisation Ang-Velo\n');
  for p = 1:length(data)
    fprintf(fid,'%u ', data(p).paramVal);
    for r = 1:length(data(p).data)                   
      fprintf(fid,'%g ', data(p).stats(r).A);
    end
    fprintf(fid,'\n');
  end
  fclose(fid);
  %----------------------------
end

%=======================================
%=======================================
% Calculate robustness indexes, based on exactly where the response A test values cross the 0.71 and 0.29 significance boundaries
robustnessIndexes = [];

defaultIndex = find([data(:).paramVal] == str2num(defaultData.paramVal));      % this must exist, and only once. 

for r = 1:length(responses)
  name = responses{r};
  name(find(name == ' ')) = [];                             % remove all the spaces from the name.
  robustnessIndexes(r).name = name;
  robustnessIndexes(r).lowerBoundary = NaN;
  robustnessIndexes(r).upperBoundary = NaN;
  robustnessIndexes(r).lowerDirection = '.';
  robustnessIndexes(r).upperDirection = '.';

  % -------------------------------------
  % calculate higher end robustness index. 
  for p = defaultIndex + 1 : length(data)  
    % move out from the default to the extreme, operating over each range of response data values
    x_lo = data(p-1).paramVal;
    x_hi = data(p).paramVal;
    y_lo = data(p-1).stats(r).A;
    y_hi = data(p).stats(r).A;

    u_lo = data(1).paramVal;
    u_hi = data(end).paramVal;
    v_lo = 0.71;     v_hi = 0.71;

    % perform the line cross test
    [flag, x_cross, y_cross] = IntersectionOfLines(x_lo, y_lo, x_hi, y_hi, u_lo, v_lo, u_hi, v_hi);
    if flag == 1
      % if the point at which the lines cross is within the range of response data values, then stop, the point is found  
      if x_cross >= x_lo & x_cross <= x_hi
        robustnessIndexes(r).upperBoundary = x_cross;
        robustnessIndexes(r).upperDirection = '+';
        break
      end
    end
    
    v_lo = 0.29;     v_hi = 0.29;
    [flag, x_cross, y_cross] = IntersectionOfLines(x_lo, y_lo, x_hi, y_hi, u_lo, v_lo, u_hi, v_hi);
    if flag == 1
      % if the point at which the lines cross is within the range of response data values, then stop, the point is found
      if x_cross >= x_lo & x_cross <= x_hi
        robustnessIndexes(r).upperBoundary = x_cross;
        robustnessIndexes(r).upperDirection = '-';
        break
      end
    end
  end
  % -------------------------------------

  % -------------------------------------
  % calculate the lower end robustness index
  for p = defaultIndex -1 :-1: 1 % cycle backwards, from default downwards. 
    x_lo = data(p).paramVal;
    x_hi = data(p + 1).paramVal;
    y_lo = data(p).stats(r).A;
    y_hi = data(p + 1).stats(r).A;

    u_lo = data(1).paramVal;
    u_hi = data(end).paramVal;
    v_lo = 0.71;     v_hi = 0.71;

    % perform the line cross test
    [flag, x_cross, y_cross] = IntersectionOfLines(x_lo, y_lo, x_hi, y_hi, u_lo, v_lo, u_hi, v_hi);
    if flag == 1
      % if the point at which the lines cross is within the range of response data values, then stop, the point is found  
      if x_cross >= x_lo & x_cross <= x_hi
        robustnessIndexes(r).lowerBoundary = x_cross;
        robustnessIndexes(r).lowerDirection = '+';
        break
      end
    end
    
    v_lo = 0.29;     v_hi = 0.29;
    [flag, x_cross, y_cross] = IntersectionOfLines(x_lo, y_lo, x_hi, y_hi, u_lo, v_lo, u_hi, v_hi);
    if flag == 1
      % if the point at which the lines cross is within the range of response data values, then stop, the point is found
      if x_cross >= x_lo & x_cross <= x_hi
        robustnessIndexes(r).lowerBoundary = x_cross;
        robustnessIndexes(r).lowerDirection = '-';
        break
      end
    end
  end
  % -------------------------------------
end

%-------------------------------
% This code will calculate percentage boundaries for parameter perturbations resulting in significant behavioural deviations. 
default = data(defaultIndex).paramVal;
for r = 1:length(robustnessIndexes)

  robustnessIndexes(r).upperPercent = abs(abs(default - robustnessIndexes(r).upperBoundary) / default) * 100;
  robustnessIndexes(r).lowerPercent = abs(abs(default - robustnessIndexes(r).lowerBoundary) / default) * 100;

  % boundaries can have values of either a number, Inf, or NaN. I wish for Inf to rank in front of NaN (which it does by default). However, NaN in these
  % calculations does not compute properly, as such we have to do these explicit checks first. 
  if isnan(robustnessIndexes(r).upperBoundary) & ~isnan(robustnessIndexes(r).lowerBoundary)
    robustnessIndexes(r).closestBoundary = robustnessIndexes(r).lowerBoundary;
    robustnessIndexes(r).closestPercent = robustnessIndexes(r).lowerPercent;  

  elseif ~isnan(robustnessIndexes(r).upperBoundary) & isnan(robustnessIndexes(r).lowerBoundary)
    robustnessIndexes(r).closestBoundary = robustnessIndexes(r).upperBoundary;
    robustnessIndexes(r).closestPercent = robustnessIndexes(r).upperPercent;

  else                % if both upperBoundary and lowerBoundary are NaN, this still works. If neither of them are,then this works too. 
    if abs(default - robustnessIndexes(r).upperBoundary) < abs(default - robustnessIndexes(r).lowerBoundary)
      robustnessIndexes(r).closestBoundary = robustnessIndexes(r).upperBoundary;
      robustnessIndexes(r).closestPercent = robustnessIndexes(r).upperPercent;
    else
      robustnessIndexes(r).closestBoundary = robustnessIndexes(r).lowerBoundary;
      robustnessIndexes(r).closestPercent = robustnessIndexes(r).lowerPercent;
    end
  end
end
%-------------------------------


fid = fopen(['robustness_indexes_-_' outputPostfix],'w');
fprintf(fid,'%40s %10s %10s %10s %10s %10s %10s %10s %10s %10s %10s\n','#Response', 'close_P', 'close_B', 'low_P', 'up_P', 'low_B', 'low_dir', 'default', 'up_B', 'up_dir', 'units');
for r = 1:length(robustnessIndexes)
  fprintf(fid, '%40s ', robustnessIndexes(r).name);
  fprintf(fid, '%10.4G ', robustnessIndexes(r).closestPercent);
  fprintf(fid, '%10.4G ', robustnessIndexes(r).closestBoundary);
  fprintf(fid, '%10.4G ', robustnessIndexes(r).lowerPercent);
  fprintf(fid, '%10.4G ', robustnessIndexes(r).upperPercent);
  fprintf(fid, '%10.4G ', robustnessIndexes(r).lowerBoundary);
  fprintf(fid, '%10s '  , robustnessIndexes(r).lowerDirection);
  fprintf(fid, '%10.4G ', default);
  fprintf(fid, '%10.4G ', robustnessIndexes(r).upperBoundary);
  fprintf(fid, '%10s '  , robustnessIndexes(r).upperDirection);
  fprintf(fid, '%10s '   , paramUnits);
  fprintf(fid, '\n');
end
fclose(fid);







