function robustness_analysis_plot_response_distribution(data, Ps, defaultData, r, responseName, outputPrefix, xLabel, yLabel)
% This function plots and stores a graph that shows, for each parameter value in the crude analysis of interest, where the median values
% of a particular response lie. It also shows the interquartile range, and outliers. Parameter values that were found to be within the A test
% boundaries for biological significance and drawn in blue, those that are outside these bounds are drawn in red. 
%
% 'data' is the massive data structure that contains everything, from the crudeAnalysis script. 
% 'Ps' is the vector of parameter values that constitude this crude analysis. They form the x values against which box plots are plotted. 
% 'r' in this case is the index into the desired response data in the 'data' variable.
% 'responseName' is the name of the response for which this graph is being generated. It is used in the filename. 
%
%
clf;

Ys = zeros( length(data(1).data{1}), length(data) );      % first param to ones is the number of rows, the second is the number of columns. 
for p = 1:length(data)                                    % scan all parameter values. 
  Ys(:,p) = data(p).data{r};                              % extract the response data for the particular parameter value. 
  if data(p).stats(r).ATestSignificant                    % determine which colour the box should be, based on whether it was "biologically significant" 
    colours(p) = 'r';                                     % those that are biologically significant are red, 
  else 
    colours(p) = 'b';                                     % those that are not, are blue. 
  end
  if data(p).paramVal == str2num(defaultData.paramVal)    % if this data represents the default parameter value, then colour the boxplot in black. 
    colours(p) = 'k';
  end
end

boxplot(Ys,Ps,'plotstyle', 'compact','colors',colours);

%--------------------------------
% getting my tick marks to change font size has been a complete nightmare, the X axis is borked in matlab. 
% manually redefining the labels as has been done here seems to do the trick, but these tings must be done in this order. 
set(gca,'XTickLabel',Ps')                    % set the x axis tick labels (the numbers under the axis)
set(gca,'XTick',[1:length(Ps)])              % set the locations of the x axis labels, by standard a box is drawn by boxplot one every whole number
set(gca,'FontSize',12)  
%--------------------------------

set(gca,'box','on');
set(gca,'LineWidth',1.0);                    % draw a thicker box around the plot. 

%--------------------------------
% the boxplot function has another irritating 'feature'. When the fontsizes of the x axis tick marks are changed using the code above, the x axis label is not adjusted
% accordingly, meaning that the label and the tick marks overlap. It is possible to move the xaxis label position, however when saving (manually using the matlab gui,
% or using the print command below) this position is reset. This is not the case for the plot command, and I have absolutely no idea why the boxplot command behaves differently. 
% I have not found a work around for this using the xlabel function/matlab feature. The approach below is to create the xlabel as normal, and let matlab do some remedial 
% positioning of where to best place it. This is then adjusted manually to allow for the different font size on the x axis tick labels. The text() command is then used
% to manually place the text which should be the x axis label onto the plot - saving moves the xlabel, but it does not interfere with normal text. All relevant attributes
% to do with positioning of the xlabel are copied from the xlabel into the text command. Lastly, the xlabel is set to nothing, so that it is no longer visible. Hence, I have
% a tedious work around. Note that the position of the manual-xlabel is going to have to be manually adjusted whenever a different font size is desired.  
xlabel(xLabel,'FontSize',12);                                           % add the axis labels. 
xlabh = get(gca,'XLabel');                                              % retrieve handle to the XLabel on the axes. 
pos = get(xlabh,'Position');                                            % retreive the position of the xlabel. Matlab may not place it properly on the y axis, but the x axis is fine. 
pos = pos + [0 -7 0];                                                   % whenever a different font size is desired, this is going to have to change also. 
        % copy across relevant attributes from the xlabel text box. 
text(pos(1), pos(2), xLabel,'FontSize',12,'Units',get(xlabh,'Units'),'VerticalAlignment',get(xlabh,'VerticalAlignment'),'HorizontalAlignment',get(xlabh,'HorizontalAlignment'));
xlabel({''});                                                           % remove the xlabel box text. 
%--------------------------------

ylabel(yLabel,'FontSize',12);                                           % much simpler, if only it worked for the axis too!

print('-dpng', '-r300', [pwd '/' outputPrefix 'response-' responseName]);     % write the graph to the file system.%

