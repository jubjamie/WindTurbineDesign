function [tableform] = statustablematrix(data,headings,filepath,ftitle,displaytype,extend)
%STATUSTABLE Creates a status table from data
%   Creates a status table from data with optional display.

tableform=array2table(data, 'VariableNames',headings);

if strcmp('print',displaytype)
    disp(tableform)
end

%Create figure for display.
if strcmp('figure',displaytype)
    f = figure('visible','on','Name',ftitle,'NumberTitle','off');
else
    f = figure('visible','off');
end

axis off
hold on
set(f, 'Position', [500 500 (size(data,2)*(90*extend)) (52+(size(data,1)*17))])
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
if isstring(filepath)
saveas(f,filepath);
end
end

