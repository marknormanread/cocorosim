%
% Designed to sit within a robustness_sensitivity_analysis directory, script will read the A test scores for different dummy parameters,
% stored in the robustness_analysis_-_ScoresATest file, and for reach response, will calculate the maximum, median and mean scores. 
% Note that scores below 0.5 are flipped to their corresponding values above 0.5. 

% This data is written to an output file, containing four columns: response_name, max, median, mean. 

fid = fopen('robustness_analysis_-_ScoresATest','r');
  scores = textscan(fid,'%f %f %f %f %f %f %f %f %f %f ','commentStyle','#'); % first column of scores contains only the dummy parameter number. this may be ignored.


responseNames = {'Collisions', 'Wall-Collisions', 'Lost-Swarm-Instances', 'Avg-AUV-Spd', 'Swarm-Spd', 'Avg-Swarm-Sep', 'Max-Swarm-Sep', 'Min-Swarm-Sep', 'IRQ-Swarm-Sep'};

medians = [];
means = [];
maximums = [];

for response = 1:9            
  values = scores{response + 1}(:);     % remember, first column of scores is only the dummer parameter number. 

  % flip elements below 0.5 onto corresponding values above 0.5.
  values = (abs(values - 0.5)) + 0.5;

  medians(response) = median(values);
  means(response) = mean(values);
  maximums(response) = max(values);
end


fid = fopen('robustness_analysis_-_ScoresATestSummary','w');
fprintf(fid,'#responseName, Maximum, Median, Mean\n');
for response = 1:length(medians)
  fprintf(fid,'%s %4.4f %4.4f %4.4f\n',responseNames{response},maximums(response),medians(response),means(response));
end
fclose(fid);
