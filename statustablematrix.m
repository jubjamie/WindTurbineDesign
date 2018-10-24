function [tableform] = statustablematrix(data,headings,filepath,display)
%STATUSTABLE Creates a status table from data
%   Creates a status table from data with optional display.

tableform=array2table(data, 'VariableNames',headings);

if display==true
    disp(tableform)
end

%Create figure for display.
f = figure('visible','on');
axis off
hold on
set(f, 'Position', [500 500 (size(data,2)*100) (35+(size(data,1)*20))])
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
saveas(f,filepath);
end
