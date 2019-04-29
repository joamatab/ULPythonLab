function man_coord_start(obj)
%This function controls the popup menu for the fluidic stage settings
%pkulik 2013, modified by Vince Wu - Oct 2013

obj.gui.manualCoordPopup.mainWindow = figure(...
    'Units', 'normalized', ...
    'Position', [0, 0, .62, .84], ...
    'Menu', 'None', ...
    'Name', 'Manual Coordinate Setup', ...
    'WindowStyle', 'normal', ...  %normal , modal, docked.  %temp switch back to modal
    'Visible', 'off', ...
    'NumberTitle', 'off', ...
    'CloseRequestFcn', {@closeWindow});

%set up main
obj.gui.manualCoordPopup.mainPanel = uipanel(...
    'Parent', obj.gui.manualCoordPopup.mainWindow, ...
    'Unit','Pixels', ...
    'BackgroundColor', [0.9 0.9 0.9], ...
    'Visible', 'on', ...
    'Units', 'normalized', ...
    'Position', [.005, .005, .990, .990]);

%% HEAT MAP
% Heat map panel parameters (size)
hmap_width = 0.5;
hmap_height = 0.5;

% heat map panel
obj.gui.manualCoordPopup.heatMapPanel = uipanel(...
    'Parent', obj.gui.manualCoordPopup.mainPanel, ...
    'BackgroundColor', [0.9, 0.9 0.9], ...
    'Visible','on', ...
    'Units','normalized', ...
    'Title','Heat Map', ...
    'FontSize', 9, ...
    'FontWeight','bold', ...
    'Position', [.01, .02, hmap_width, hmap_height]);

% axes for heat map
obj.gui.manualCoordPopup.heatMapDisp = axes(...
    'Parent', obj.gui.manualCoordPopup.heatMapPanel, ...
    'Units', 'normalized', ...
    'Position', [.1, .12, .84, .84], ...
    'Color', [.85 .85 .85], ...
    'NextPlot', 'add', ...
    'box', 'on');

xlabel('X (um)');
ylabel('Y (um)');

%% Instrument UIs
% ui panel parameters (size)
camera_y = hmap_height + 0.02;
camera_width = hmap_width;
camera_height = 0.985 - camera_y;
ui_x = camera_width + 0.015;
ui_y = 0.05;
ui_width = 0.985 - ui_x;
ui_height = 0;
ui_position = [ui_x, ui_y, ui_width, ui_height];

% Microscope Camera ui Panel
obj = camera_ui(...
    obj, ...
    'manual', ...
    obj.gui.manualCoordPopup.mainPanel, ...
    [.01, camera_y, camera_width, camera_height]);

% Coordinates System UIs
if (obj.instr.opticalStage.Connected)
    % Align ui
    ui_position(4) = 0.125;
    obj = align_ui(...
        obj, ...
        'manual', ...
        obj.gui.manualCoordPopup.mainPanel, ...
        ui_position, ...
        obj.gui.manualCoordPopup.heatMapDisp);
    % Coordinates ui
    ui_position(2) = ui_position(2) + ui_position(4);
    ui_position(4) = 0.28;
    obj = coordinates_ui(...
        obj, ...
        'manual', ...
        obj.gui.manualCoordPopup.mainPanel, ...
        ui_position);
    % Optical Stage ui
    ui_position(2) = ui_position(2) + ui_position(4);
    ui_position(4) = 0.20;
    obj = optical_stage_ui(...
        obj, ...
        'manual', ...
        obj.gui.manualCoordPopup.mainPanel, ...
        ui_position);
end

% Laser ui
if (obj.instr.laser.Connected)
    ui_position(2) = ui_position(2) + ui_position(4);
    ui_position(4) = 0.19;
    obj = laser_ui(...
        obj, ....
        'manual', ...
        obj.gui.manualCoordPopup.mainPanel, ...
        ui_position);
end

% Detector ui
if (obj.instr.detector.Connected)
    ui_position(2) = ui_position(2) + ui_position(4);
    ui_position(4) = 0.985 - ui_position(2);
    obj = detector_ui(...
        obj, ...
        'manual', ...
        obj.gui.manualCoordPopup.mainPanel, ...
        ui_position);
end

%% CANCEL AND RETURN

obj.gui.manualCoordPopup.cancelButton = uicontrol(...
    'Parent', obj.gui.manualCoordPopup.mainPanel, ...
    'Style','pushbutton', ...
    'HorizontalAlignment','left', ...
    'Units', 'normalized', ...
    'Position', [0.706, 0.02, 0.1, 0.03], ...
    'String', 'Cancel', ...
    'Callback', @cancel_button_cb);

obj.gui.manualCoordPopup.doneButton = uicontrol(...
    'Parent', obj.gui.manualCoordPopup.mainPanel, ...
    'Style','pushbutton', ...
    'HorizontalAlignment','left', ...
    'Units', 'normalized', ...
    'Position', [0.814, 0.02, 0.1, 0.03], ...
    'String', 'Done', ....
    'Callback', @done_button_cb);

movegui(obj.gui.manualCoordPopup.mainWindow, 'center');
set(obj.gui.manualCoordPopup.mainWindow, 'Visible', 'on');

%% FINE ALIGN POWER OUTPUT

% obj.gui.manualCoordPopup.fapwrx_string = uicontrol('Parent', obj.gui.manualCoordPopup.mainPanel, ...
%     'Style','text', ...
%     'HorizontalAlignment','left', ...
%     'BackGroundColor', [0.9, 0.9, 0.9], ...
%     'Units', 'normalized', ...
%     'Position', [0.0496957403651116,0.887055837563452,0.202839756592292,0.0317258883248731], ...
%     'String', 'Fine Align Power Output X', ....
%     'FontSize', STAT_TXT_FONT, ...
%     'FontWeight', 'bold');
% y_align = 0.72;
% % Initiate axes x fine align
% obj.gui.manualCoordPopup.fapwrx_axes = axes('Parent', obj.gui.manualCoordPopup.mainPanel, ...
%     'Units', 'normalized', ...
%     'Position', [.06, y_align, .57, .15], ...
%     'Color', [.85 .85 .85], ...
%     'NextPlot', 'add', ...
%     'box', 'on');
% 
% y_align = y_align - 0.07;
% 
% obj.gui.manualCoordPopup.fapwry_string = uicontrol('Parent', obj.gui.manualCoordPopup.mainPanel, ...
%     'Style','text', ...
%     'HorizontalAlignment','left', ...
%     'BackGroundColor', [0.9, 0.9, 0.9], ...
%     'Units', 'normalized', ...
%     'Position', [0.0496957403651116,y_align,0.202839756592292,0.0317258883248731], ...
%     'String', 'Fine Align Power Output Y', ....
%     'FontSize', STAT_TXT_FONT, ...
%     'FontWeight', 'bold');
% 
% y_align = y_align - 0.17;
% % Initiate axes x fine align
% obj.gui.manualCoordPopup.fapwry_axes = axes('Parent', obj.gui.manualCoordPopup.mainPanel, ...
%     'Units', 'normalized', ...
%     'Position', [.06, y_align, .57, .15], ...
%     'Color', [.85 .85 .85], ...
%     'NextPlot', 'add', ...
%     'box', 'on');
% 

%% POPUP WINDOW CALLBACKS

    function cancel_button_cb(~, ~)
        close(obj.gui.manualCoordPopup.mainWindow);
    end

    function done_button_cb(~, ~)
        % save the set stage/gds coords and close the window
        
%         for i = 1:6  % loop through the coords table in the window and store the values
%             GDS_coords = [get(obj.gui.manualCoordPopup.GDS_table{i, 2}, 'String'), ...
%                 get(obj.gui.manualCoordPopup.GDS_table{i, 3}, 'String')];
%             
%             stage_coords = [get(obj.gui.manualCoordPopup.GDS_table{i, 4}, 'String'), ...
%                 get(obj.gui.manualCoordPopup.GDS_table{i, 5}, 'String')];
%             
%             obj.settings.coordPairs.i.gds.x = GDS_coords(1);
%             obj.settings.coordPairs.i.gds.y = GDS_coords(2);
%             
%             obj.settings.coordPairs.i.stage.x = stage_coords(1);
%             obj.settings.coordPairs.i.stage.y = stage_coords(2);
%         end
        try
            obj.instr.camera.PreviewAxes = obj.gui.manualCoordPopup.cameraUI.cameraPreviewAxe;
            obj.instr.camera.close();
        end
        % close the window
        close(obj.gui.manualCoordPopup.mainWindow);
    end

    function closeWindow(hObject,eventdata)
        delete(gcbf);
    end
end