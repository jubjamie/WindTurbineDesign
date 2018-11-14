function [tableform] = statustablematrix(data,headings,filepath,ftitle,...
                       displaytype,extend)
%STATUSTABLE Creates a status table from data
%   Creates a status table from a matrix and can print to console,
%   displays as figure in a window or save to file.

tableform=array2table(data, 'VariableNames',headings); % Make the table.

% Detrimine requested display type.
if strcmp('print',displaytype)
    % If print, the put in command window.
    disp(tableform)
end

% Create figure handle.
if strcmp('figure',displaytype)
    % If figure display is requested, turn visibility on.
    f = figure('visible','on','Name',ftitle,'NumberTitle','off');
else
    % If not, turn off. Figure still needed to save to file.
    f = figure('visible','off');
end

axis off
hold on
set(f, 'Position', [500 500 (size(data,2)*(90*extend))...
                    (52+(size(data,1)*17))])
% Get the table in string form.
TString = evalc('disp(tableform)');
% Use TeX Markup for bold formatting and underscores.
TString = strrep(TString,'<strong>','\bf');
TString = strrep(TString,'</strong>','\rm');
TString = strrep(TString,'_','\_');
% Get a fixed-width font.
FixedWidth = get(0,'FixedWidthFontName');
% Output the table using the annotation command.
annotation(gcf,'Textbox','String',TString,'Interpreter','Tex',...
    'FontName',FixedWidth,'Units','Normalized','Position',[0 0 1 1]);

if filepath(1) ~= false
    % If a file path is specified, save to filepath.
    saveas(f,filepath);
end
end

