function obj = initialize_console(obj)

    obj.gui.messagePanel = uipanel(...
        'Parent', obj.gui.benchMainWindow, ...
        'Title', 'Debug Messages', ...
        'FontSize', 9, ...
        'BackGroundColor', [0.9, 0.9, 0.9], ...
        'Units', 'normalized', ...
        'Position', [.76, .065, 0.23, 0.93]);

    obj.gui.debugConsole = uicontrol(...
        'Parent', obj.gui.messagePanel, ...
        'Style', 'edit', ...
        'BackgroundColor', [0.85, 0.85, 0.85], ...
        'Units', 'normalized', ...
        'Position', [.015, .10, .97, .86], ...
        'HorizontalAlignment', 'left', ...
        'FontSize', 9, ...
        'Max', 20, ...
        'String', {});

    obj.msg('---- Startup ----');
end