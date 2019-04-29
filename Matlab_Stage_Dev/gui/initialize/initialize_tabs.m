function obj = initialize_tabs(obj)

list = panel_index('all');
numOfPanels = length(list);

obj.gui.tab = zeros(1, numOfPanels);

    for ii = 1:numOfPanels
        obj.gui.tabFrame(ii) = uipanel('Parent', obj.gui.benchMainWindow, ...
            'BackgroundColor', [0.8 0.8 0.8], ...
            'Units', 'normalized', ...
            'Position', ...
            [.0111 + (ii-1)*0.7468/numOfPanels 0.94 0.7468/numOfPanels 0.05]);

        obj.gui.tab(ii) = uicontrol('Parent', obj.gui.tabFrame(ii), ...
            'Style', 'text', ...
            'FontSize', 11, ...
            'String', panel_index(ii), ...
            'BackgroundColor', [0.8 0.8 0.8], ...
            'Units', 'normalized', ...
            'Position', [0 0 1 1]);
    end
end
