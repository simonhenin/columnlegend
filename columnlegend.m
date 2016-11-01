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
%
%   Motiified by Tian Zhou <github.com/yxtj>
%   10/31/2016 - Add support for errorbar function (Now supports plot, plotyy, errorbar)


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
numrows = ceil(numlines/numcolumns);

%get old width, new width and scale factor
set(legend_h, 'units', 'normalized');
set(gca, 'units', 'normalized');

pos = get(legend_h, 'position');
oldwidth=pos(3);
oldheight=pos(4);
newwidth = numcolumns*pos(3);
newheight = (pos(4)/numlines)*numrows;
rescale_x = 1/numcolumns;
rescale_y = numrows/numlines;

%set handles for x, y1 and y2 
switch lower(get(plot_h(1),'type'))
    case {'line'}
        x_h=object_h(numlines+1);
        y1_h=object_h(numlines+1);  % y line
        y2_h=object_h(numlines+3);  % y marker
    case {'errorbar'}
        x_h=object_h(numlines+1).Children.Children(2);
        y1_h=object_h(numlines+1).Children.Children(2);
        y2_h=object_h(numlines+2).Children.Children(2);
    otherwise
        warning(['Type "' get(plot_h(1),'type') ' "not supported']);
end

%get some old values so we can scale everything later
xdata = get(x_h, 'xdata'); 
ydata1 = get(y1_h, 'ydata');
ydata2 = get(y2_h, 'ydata');


%we'll use these later to align things appropriately
sheight = ydata1(1)-ydata2(1);                  % height between data lines
height = ydata1(1);                             % height of the box. Used to top margin offset
line_width = (xdata(2)-xdata(1))*rescale_x;   % rescaled linewidth to match original
spacer = xdata(1)*rescale_x;                    % rescaled spacer used for margins


%put the legend on the upper left corner to make initial adjustments easier
% set(gca, 'units', 'pixels');
fig_pos = get(gca, 'position');
set(legend_h, 'position', [fig_pos(1) fig_pos(2)+fig_pos(4)-pos(4) newwidth pos(4)]);

col = -1;
linenum = numlines+1;
for i=1:numlines,
    if (mod(i,numrows)==1 || (numrows == 1)),
        col = col+1;
    end
    
    switch lower(get(plot_h(i),'type'))
        case {'line'}
            line_yl_h=object_h(linenum);
            line_ym_h=object_h(linenum+1);
            linenum = linenum+2;
        case {'errorbar'}
            line_yl_h=object_h(linenum).Children.Children(2);
            line_ym_h=object_h(linenum).Children.Children(1);
            linenum = linenum+1;
        otherwise
            warning(['Type "' get(plot_h(i),'type') ' "not supported']);
    end
    
    labelnum = i;
    
    position = mod(i,numrows);
    if position == 0,
         position = numrows;
    end
    
    %realign the labels
    set(line_yl_h, 'ydata', [(height-(position-1)*sheight) (height-(position-1)*sheight)]);
    set(line_yl_h, 'xdata', [col/numcolumns+spacer col/numcolumns+spacer+line_width]);

    set(line_ym_h, 'ydata', [height-(position-1)*sheight height-(position-1)*sheight]);
    set(line_ym_h, 'xdata', [col/numcolumns+spacer*3.5 col/numcolumns+spacer*3.5]);

    set(object_h(labelnum), 'position', [col/numcolumns+spacer*2+line_width height-(position-1)*sheight]);
   
end

%unfortunately, it is not possible to force the box to be smaller than the
%original height, therefore, turn it off and set background color to none
%so that it no longer appears
set(legend_h, 'Color', 'None', 'Box', 'off');

%let's put it where you want it
pos = get(legend_h, 'position');
fig_pos = get(gca, 'position');
padding = 0.01; % padding, in normalized units
switch lower(location),
    case {'northeast'}
        pos(1)=pos(1)+fig_pos(3)-newwidth-padding;
        pos(2)=pos(2)+padding;
    case {'northwest'}
        pos(2)=pos(2)+padding;
    case {'southeast'}
        pos(1)=pos(1)+fig_pos(3)-newwidth-padding;
        pos(2)=fig_pos(2)-oldheight*(1-rescale_y);
    case {'southwest'}
        pos(2)=fig_pos(2)-oldheight*(1-rescale_y);
    case {'northeastoutside'}
        % need to resize axes to allow legend to fit in figure window
        set(gca, 'position', fig_pos-[0 0 newwidth 0]);
        pos(1)=fig_pos(1)+fig_pos(3)-newwidth;
    case {'northwestoutside'}
        % need to resize axes to allow legend to fit in figure window
        set(gca, 'position', fig_pos+[newwidth 0 -newwidth 0]);
        pos(1)=padding;
    case {'northoutside'}
        % need to resize axes to allow legend to fit in figure window
        set(gca, 'position', fig_pos-[0 0 0 newheight]);
        pos(1)=fig_pos(1)+fig_pos(3)/2-newwidth/2;
        pos(2)=fig_pos(2)+(fig_pos(4)-oldheight)+padding;
    case {'southoutside'}
        % need to resize axes to allow legend to fit in figure window
        set(gca, 'position', fig_pos-[0 -newheight 0 newheight]);
        pos(1)=fig_pos(1)+fig_pos(3)/2-newwidth/2;
        pos(2)=-oldheight*(1-rescale_y);
    case {'eastoutside'}
        % need to resize axes to allow legend to fit in figure window
        set(gca, 'position', fig_pos-[0 0 newwidth 0]);
        pos(1)=fig_pos(1)+fig_pos(3)-newwidth;
        pos(2)=fig_pos(2)+fig_pos(4)/2-oldheight/2-newheight/2;
    case {'southeastoutside'}
        % need to resize axes to allow legend to fit in figure window
        set(gca, 'position', fig_pos-[0 0 newwidth 0]);
        pos(1)=pos(1)+fig_pos(3)-newwidth;
        pos(2)=fig_pos(2)-oldheight*(1-rescale_y);
    case {'westoutside'}
        % need to resize axes to allow legend to fit in figure window
        set(gca, 'position', fig_pos+[newwidth 0 -newwidth 0]);
        pos(1)=padding;
        pos(2)=fig_pos(2)+fig_pos(4)/2-oldheight/2-newheight/2;
    case {'southwestoutside'}
        % need to resize axes to allow legend to fit in figure window
        set(gca, 'position', fig_pos+[newwidth 0 -newwidth 0]);
        pos(1)=padding;
        pos(2)=fig_pos(2)-oldheight*(1-rescale_y);
end
set(legend_h, 'position', pos);

% display box around legend
if boxon,
    drawnow; % make sure everyhting is drawn in place first.
%     set(legend_h, 'units', 'normalized');
    pos = get(legend_h, 'position');
    pos(1)=pos(1)+padding/2;
    pos(2)=pos(2)+oldheight*(1-rescale_y);
    pos(3)=newwidth;
    pos(4)=newheight;
    annotation('rectangle',pos, 'linewidth', 1);
end

% re-set to normalized so that things scale properly
%set(legend_h, 'units', 'normalized');
%set(gca, 'units', 'normalized');
