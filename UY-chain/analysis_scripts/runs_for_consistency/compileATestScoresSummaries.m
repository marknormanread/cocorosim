% Matlab script is designed to be run within a directory containing a bunch of crude_analysis_-_ScoresATestSummary_XXX files, where XXX should be named
% to the number of samples used in each set of data. These files contain four columns: response_name, max, median, mean. 
% This script reads in all those data in those files, and draws two graphs: how the sample size (xaxis) changes the a test scores, for both the medians and maximums.
%
%
%
%


path = pwd;
k = findstr('output',path);
headDir = path(1:k(end)-1);                     % dynamically locate where teh data analysis file is located, based in searching for 'Treg_2D' in the current working dir. 


addpath(genpath([headDir '/output/analysis_scripts/matlab_helper_functions']));

LineWidth = 1.0;
FontSize = 12;

markerInterval = 48;
markerSize = 9;


files = dir(['robustness_analysis' '*']);
[unused,order] = sortn({files(:).name});
files(:) = files(order)

data = [];

for i = 1:length(files)
  fid = fopen(files(i).name);
  data(i).val = files(i).name;
  data(i).data = textscan(fid,'%*s %f %f %f', 'commentStyle', '#');         % data contains four columns: response_name, max, median, mean. 
  fclose(fid);
end

maximum = [];
median = [];
index = [];
for i = 1:length(data)
  [maximum(i),index(i)] = max(data(i).data{1});
  [median(i),index(i)] = max(data(i).data{2});
end

maximum
median
index


clf;
hold on;
Responses = {'Collisions', 'Wall Collisions', 'Lost Swarm Instances', 'Avg AUV Spd', 'Swarm Spd', 'Avg Swarm Sep', 'Max Swarm Sep', 'Min Swarm Sep', 'IRQ Swarm Sep'};

Xs = [1, 5, 10, 50, 100, 200, 300, 400, 500];


col = [];
wall_col = [];
lost = [];
avg_auv_spd = [];
swarm_spd = [];
avg_swarm_sep = [];
max_swarm_sep = [];
min_swarm_sep = [];
irq_swarm_sep = [];


for sampleSize = 1:length(data)
  col(sampleSize)                  = data(sampleSize).data{1}(1);
  wall_col(sampleSize)             = data(sampleSize).data{1}(2);
  lost(sampleSize)                 = data(sampleSize).data{1}(3);
  avg_auv_spd(sampleSize)          = data(sampleSize).data{1}(4);
  swarm_spd(sampleSize)            = data(sampleSize).data{1}(5);
  avg_swarm_sep(sampleSize)        = data(sampleSize).data{1}(6);
  max_swarm_sep(sampleSize)        = data(sampleSize).data{1}(7);
  min_swarm_sep(sampleSize)        = data(sampleSize).data{1}(8);
  irq_swarm_sep(sampleSize)        = data(sampleSize).data{1}(9);
end


leg1 = plot(Xs, col, 'r-s', 'MarkerSize',markerSize,'LineWidth', LineWidth); 
leg2 = plot(Xs, wall_col, 'r-.s', 'MarkerSize',markerSize,'LineWidth', LineWidth);
leg3 = plot(Xs, lost, 'm-o', 'MarkerSize',markerSize,'LineWidth', LineWidth);
leg4 = plot(Xs, avg_auv_spd, 'm-.o' , 'MarkerSize',markerSize,'LineWidth', LineWidth); 
leg5 = plot(Xs, swarm_spd, 'b-^', 'MarkerSize',markerSize,'LineWidth', LineWidth); 
leg6 = plot(Xs, avg_swarm_sep, 'b-.^', 'MarkerSize',markerSize,'LineWidth', LineWidth); 
leg7 = plot(Xs, max_swarm_sep, 'g-v', 'MarkerSize',markerSize,'LineWidth', LineWidth); 
leg8 = plot(Xs, min_swarm_sep, 'g-.v', 'MarkerSize',markerSize,'LineWidth', LineWidth); 
leg9 = plot(Xs, irq_swarm_sep, 'k-*', 'MarkerSize',markerSize,'LineWidth', LineWidth); 


text(450,0.715,'large effect','FontSize',FontSize);
line([Xs(1), Xs(end)], [0.71, 0.71], 'color', 'k', 'LineStyle', ':','LineWidth',1.0)   % draw the large effect magnitude line
text(450,0.645,'medium effect','FontSize',FontSize);
line([Xs(1), Xs(end)], [0.64, 0.64], 'color', 'k', 'LineStyle', ':','LineWidth',1.0)   % draw the medium effect magnitude line
text(450,0.565,'small effect','FontSize',FontSize);
line([Xs(1), Xs(end)], [0.56, 0.56], 'color', 'k', 'LineStyle', ':','LineWidth',1.0)   % draw the small effect magnitude line
%B = [Xs(1), Xs(end), 0.5, 0.75];                     % axis ranges, [xmin, xmax, ymin, ymax].
B = axis();
B(end) = 0.75;
axis(B);                                            % replot with differen mins and maxes for axes
set(gca,'box','on');
set(gca,'LineWidth',1.0);
set(gca,'FontSize',12)
xlabel('sample size','FontSize',12);
ylabel('A test score','FontSize',12);
legend([leg1,leg2,leg3,leg4,leg5,leg6,leg7,leg8,leg9],Responses,'FontSize',FontSize);

hold off;

print('-dpng', '-r300', ['sampleSizeEffectOnATestScores-Maximum.png'])    % write the graph to the file system. 

clf;


col = [];
wall_col = [];
lost = [];
avg_auv_spd = [];
swarm_spd = [];
avg_swarm_sep = [];
max_swarm_sep = [];
min_swarm_sep = [];
irq_swarm_sep = [];


for sampleSize = 1:length(data)
  col(sampleSize)                  = data(sampleSize).data{2}(1);
  wall_col(sampleSize)             = data(sampleSize).data{2}(2);
  lost(sampleSize)                 = data(sampleSize).data{2}(3);
  avg_auv_spd(sampleSize)          = data(sampleSize).data{2}(4);
  swarm_spd(sampleSize)            = data(sampleSize).data{2}(5);
  avg_swarm_sep(sampleSize)        = data(sampleSize).data{2}(6);
  max_swarm_sep(sampleSize)        = data(sampleSize).data{2}(7);
  min_swarm_sep(sampleSize)        = data(sampleSize).data{2}(8);
  irq_swarm_sep(sampleSize)        = data(sampleSize).data{2}(9);
end

hold on
leg1 = plot(Xs, col, 'r-s', 'MarkerSize',markerSize,'LineWidth', LineWidth); 
leg2 = plot(Xs, wall_col, 'r-.s', 'MarkerSize',markerSize,'LineWidth', LineWidth);
leg3 = plot(Xs, lost, 'm-o', 'MarkerSize',markerSize,'LineWidth', LineWidth);
leg4 = plot(Xs, avg_auv_spd, 'm-.o' , 'MarkerSize',markerSize,'LineWidth', LineWidth); 
leg5 = plot(Xs, swarm_spd, 'b-^', 'MarkerSize',markerSize,'LineWidth', LineWidth); 
leg6 = plot(Xs, avg_swarm_sep, 'b-.^', 'MarkerSize',markerSize,'LineWidth', LineWidth); 
leg7 = plot(Xs, max_swarm_sep, 'g-v', 'MarkerSize',markerSize,'LineWidth', LineWidth); 
leg8 = plot(Xs, min_swarm_sep, 'g-.v', 'MarkerSize',markerSize,'LineWidth', LineWidth); 
leg9 = plot(Xs, irq_swarm_sep, 'k-*', 'MarkerSize',markerSize,'LineWidth', LineWidth); 

text(450,0.715,'large effect','FontSize',FontSize);
line([Xs(1), Xs(end)], [0.71, 0.71], 'color', 'k', 'LineStyle', ':','LineWidth',1.0)   % draw the large effect magnitude line
text(450,0.645,'medium effect','FontSize',FontSize);
line([Xs(1), Xs(end)], [0.64, 0.64], 'color', 'k', 'LineStyle', ':','LineWidth',1.0)   % draw the medium effect magnitude line
text(450,0.565,'small effect','FontSize',FontSize);
line([Xs(1), Xs(end)], [0.56, 0.56], 'color', 'k', 'LineStyle', ':','LineWidth',1.0)   % draw the small effect magnitude line
%B = [Xs(1), Xs(end), 0.5, 0.75];                     % axis ranges, [xmin, xmax, ymin, ymax].
B = axis();
B(end) = 0.75;
axis(B);                                            % replot with differen mins and maxes for axes
set(gca,'box','on');
set(gca,'LineWidth',1.0);
set(gca,'FontSize',12)
xlabel('sample size','FontSize',12);
ylabel('A test score','FontSize',12);
legend([leg1,leg2,leg3,leg4,leg5,leg6,leg7,leg8,leg9],Responses,'FontSize',FontSize);

hold off;

print('-dpng', '-r300', ['sampleSizeEffectOnATestScores-Median.png'])    % write the graph to the file system. 



%
% Pulling out some data to put into the paper. The max and median values for the CD4Th1Max response. 
%

med = [];
maximum = [];
for i = 1 : length(data)
  maximum(i) = data(i).data{1}(1);
  med(i) = data(i).data{2}(1);
end
med
maximum


% This loop will write a latex-readable text file that details what the maximum A test score was, for each response, at each sample size. 
%
%
% This is the sturcture of the 'data' variable.
% data(samplesize).data{[max,med,mean]}(response)
%
fid = fopen('latexTable_max','w');
for response = 1:length(Responses)
  fprintf(fid,'\\emph{%16s} & ', Responses{response});
  for sampleSize = 2:length(data)     % this will cycle through sample sizes. 
    maxVal = data(sampleSize).data{1}(response);
    significanceString = '    ';
    twosigMaxVal = round(maxVal*100) / 100;     % this will (almost exactly) round to 2 sig figures. 
    if twosigMaxVal <= 0.56
      significanceString = '$^*$';
    end
    fprintf(fid, '%3.2f%s & ', maxVal, significanceString); 
  end
  fprintf(fid,' \\\\ \n');
end
%
%
% This loop will do the same, but for median A test scores, rather than maximums. 
%
%
fid = fopen('latexTable_median','w');
for response = 1:length(Responses)
  fprintf(fid,'\\emph{%16s} & ', Responses{response});
  for sampleSize = 2:length(data)     % this will cycle through sample sizes. 
    maxVal = data(sampleSize).data{2}(response);
    significanceString = '    ';
    twosigMaxVal = round(maxVal*100) / 100;     % this will (almost exactly) round to 2 sig figures. 
    if twosigMaxVal <= 0.56
      significanceString = '$^*$';
    end
    fprintf(fid, '%3.2f%s & ', maxVal, significanceString); 
  end
  fprintf(fid,' \\\\ \n');
end
fclose(fid);
