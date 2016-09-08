function [legend_h,object_h,plot_h,text_strings] = columnlegend(numcolumns, str, varargin)
%
%   columnlegend creates a legend with a specified number of columns.
%   
%   columnlegend(numcolumns, str, varargin)
%       numcolumns - number of columns in the legend
%       str - cell array of strings for the legend
%       
%   columnlegend(..., 'Location', loc)
%       loc - location variable for legend, default is 'NorthEast'
%                  possible values: 'NorthWest', 'NorthEast', 'SouthEast', 'SouthWest' 
%
%   columnlegend(..., 'boxon')
%   columnlegend(..., 'boxoff')
%        set legend bounding box on/off
%
%   example:
%      legend_str = []; 
%      for i=1:10, 
%           x = 1:i:(10*i); 
%           plot(x); hold on; 
%           legend_str = [legend_str; {num2str(i)}];
%      end
%      columnlegend(3, legend_str, 'Location', 'NorthWest');
%
%
%   Author: Simon Henin <shenin@gc.cuny.edu>
%   
%   4/09/2013 - Fixed bug with 3 entries / 3 columns
%   4/09/2013 - Added bounding box option as per @Durga Lal Shrestha (fileexchage)



location = 'NorthEast';
boxon = false; legend_h = false;
for i=1:2:length(varargin),
    switch lower(varargin{i})
        case 'location'
            location = varargin{i+1};
            i=i+2;
        case 'boxon'
            boxon = true;
        case 'boxoff'
            boxon = false;
        case 'legend'
            legend_h = varargin{i+1};
            i=i+2;
        case 'object'
            object_h = varargin{i+1};
            i=i+2;
    end
end

if legend_h == false,
    %create the legend
    [legend_h,object_h,plot_h,text_strings] = legend(str);
end

%some variables
numlines = length(str);
numpercolumn = ceil(numlines/numcolumns);

%get old width, new width and scale factor
set(legend_h, 'units', 'normalized');
set(gca, 'units', 'normalized');

pos = get(legend_h, 'position');
width = numcolumns*pos(3);
newheight = (pos(4)/numlines)*numpercolumn;
rescale = pos(3)/width;

%get some old values so we can scale everything later
xdata = get(object_h(numlines+1), 'xdata'); 
ydata1 = get(object_h(numlines+1), 'ydata');
ydata2 = get(object_h(numlines+3), 'ydata');

%we'll use these later to align things appropriately
sheight = ydata1(1)-ydata2(1);                  % height between data lines
height = ydata1(1);                             % height of the box. Used to top margin offset
line_width = (xdata(2)-xdata(1))*rescale;   % rescaled linewidth to match original
spacer = xdata(1)*rescale;                    % rescaled spacer used for margins


%put the legend on the upper left corner to make initial adjustments easier
% set(gca, 'units', 'pixels');
loci = get(gca, 'position');
set(legend_h, 'position', [loci(1) pos(2) width pos(4)]);


col = -1;
for i=1:numlines,
    if (mod(i,numpercolumn)==1 || (numpercolumn == 1)),
        col = col+1;
    end
    
    if i==1
        linenum = i+numlines;
    else
        linenum = linenum+2;
    end
    labelnum = i;
    
    position = mod(i,numpercolumn);
    if position == 0,
         position = numpercolumn;
    end
    
    %realign the labels
    set(object_h(linenum), 'ydata', [(height-(position-1)*sheight) (height-(position-1)*sheight)]);
    set(object_h(linenum), 'xdata', [col/numcolumns+spacer col/numcolumns+spacer+line_width]);
    
    set(object_h(linenum+1), 'ydata', [height-(position-1)*sheight height-(position-1)*sheight]);
    set(object_h(linenum+1), 'xdata', [col/numcolumns+spacer*3.5 col/numcolumns+spacer*3.5]);
    
    set(object_h(labelnum), 'position', [col/numcolumns+spacer*2+line_width height-(position-1)*sheight]);
    
   
end

%unfortunately, it is not possible to force the box to be smaller than the
%original height, therefore, turn it off and set background color to none
%so that it no longer appears
set(legend_h, 'Color', 'None', 'Box', 'off');

%let's put it where you want it
pos = get(legend_h, 'position'); pos(4) = newheight;
fig_pos = get(gca, 'position');
padding = 0.01; % padding, in normalized units
switch lower(location),
    case {'northeast'}
        set(legend_h, 'position', [pos(1)+fig_pos(3)-pos(3)-padding pos(2) pos(3) pos(4)]);
    case {'northwest'}
        set(legend_h, 'position', [pos(1)+padding pos(2) pos(3) pos(4)]);        
    case {'southeast'}
        set(legend_h, 'position', [pos(1)+fig_pos(3)-pos(3)-padding fig_pos(2)-pos(4)/2+pos(4)/4 pos(3) pos(4)]);
    case {'southwest'}
        set(legend_h, 'position', [fig_pos(1)+padding fig_pos(2)-pos(4)/2+pos(4)/4 pos(3) pos(4)]);
    case {'northeastoutside'}
        % need to resize axes to allow legend to fit in figure window
        set(gca, 'position', [fig_pos]-[0 0 pos(3) 0]);
        set(legend_h, 'position', [pos(1)+fig_pos(3)-pos(3) pos(2) pos(3) pos(4)]);
    case {'northwestoutside'}
        % need to resize axes to allow legend to fit in figure window
        set(gca, 'position', [fig_pos]+[pos(3) 0 -pos(3) 0]);
        set(legend_h, 'position', [fig_pos(1)-fig_pos(3)*.1 pos(2) pos(3) pos(4)]); % -10% figurewidth to account for axis labels
    case {'northoutside'}
        % need to resize axes to allow legend to fit in figure window
        set(gca, 'position', [fig_pos]-[0 0 0 pos(4)]);
        set(legend_h, 'position', [fig_pos(1)+fig_pos(3)/2-pos(3)/2 fig_pos(2)+fig_pos(4)-pos(4) pos(3) pos(4)]);
    case {'southoutside'}
        % need to resize axes to allow legend to fit in figure window
        set(gca, 'position', [fig_pos]-[0 -pos(4) 0 pos(4)]);
        set(legend_h, 'position', [fig_pos(1)+fig_pos(3)/2-pos(3)/2 fig_pos(2)-pos(4)/2 pos(3) pos(4)]);
    case {'eastoutside'}
        % need to resize axes to allow legend to fit in figure window
        set(gca, 'position', [fig_pos]-[0 0 pos(3) 0]);
        set(legend_h, 'position', [pos(1)+fig_pos(3)-pos(3) fig_pos(2)+fig_pos(4)/2-pos(4)/2 pos(3) pos(4)]);
    case {'southeastoutside'}
        % need to resize axes to allow legend to fit in figure window
        set(gca, 'position', [fig_pos]-[0 0 pos(3) 0]);
        set(legend_h, 'position', [pos(1)+fig_pos(3)-pos(3) fig_pos(2)-pos(4)/4 pos(3) pos(4)]);
    case {'westoutside'}
        % need to resize axes to allow legend to fit in figure window
        set(gca, 'position', [fig_pos]+[pos(3) 0 -pos(3) 0]);
        set(legend_h, 'position', [fig_pos(1)-fig_pos(3)*.1 fig_pos(2)+fig_pos(4)/2-pos(4)/2 pos(3) pos(4)]); % -10% figurewidth to account for axis labels    
    case {'southwestoutside'}
        % need to resize axes to allow legend to fit in figure window
        set(gca, 'position', [fig_pos]+[pos(3) 0 -pos(3) 0]);
        set(legend_h, 'position', [fig_pos(1)-fig_pos(3)*.1 fig_pos(2)-pos(4)/4 pos(3) pos(4)]); % -10% figurewidth to account for axis labels        
end

% display box around legend
if boxon,
    drawnow; % make sure everyhting is drawn in place first.
%     set(legend_h, 'units', 'normalized');
    pos = get(legend_h, 'position');
    orgHeight = pos(4);
    pos(4) = (orgHeight/numlines)*numpercolumn;
    pos(2)=pos(2) + orgHeight-pos(4) - pos(4)*0.05;
    pos(1) = pos(1)+pos(1)*0.01;
    annotation('rectangle',pos, 'linewidth', 1)
end

% re-set to normalized so that things scale properly
set(legend_h, 'units', 'normalized');
set(gca, 'units', 'normalized');