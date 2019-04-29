% targetDevice should be the name (string) of a device object
function obj = selectPeaks(obj, targetDevice)
% select peaks popup that will graph the wavelength Vs. power output of
% each detector unit on a separate axes and allow the user to pick peaks on
% each graph to track by saving them to the device object specified
% Victor Bass 2013
% Modified by Vince Wu - Nov 2013


% Reset device scan datas
obj.devices.(targetDevice).setProp('ScanNumber', 0);
obj.devices.(targetDevice).PeakLocations = {};
obj.devices.(targetDevice).PeakLocationsN = {};
obj.devices.(targetDevice).PeakTrackWindow = {};

%targetDevice is the name of the device

numDetectors = obj.instr.detector.getProp('NumOfDetectors');

instructions{1} = 'Press the Start button to begin peak tracking';
instructions{2} = 'Left click near a peak to select for tracking.';
instructions{3} = 'Right click when finished';
instructions{4} = 'Click ''Done'' to save peaks';

obj.gui.selectPeaksPopup.mainWindow = figure(...
    'Unit', 'normalized', ...
    'Position', [0, 0, 0.68, 0.85],...
    'Menu', 'None',...
    'Name', 'PEAK TRACKER',...
    'WindowStyle', 'normal',...  % normal , modal, docked.
    'Visible', 'off',...
    'NumberTitle', 'off',...
    'CloseRequestFcn', {@closeWindow});

% main panel
obj.gui.selectPeaksPopup.mainPanel = uipanel(...
    'parent', obj.gui.selectPeaksPopup.mainWindow,...
    'BackgroundColor',[0.9 0.9 0.9],...
    'Visible','on',...
    'Units', 'normalized', ...
    'Position', [.005, .005, .990, .990]);

% title string
obj.gui.selectPeaksPopup.stringTitle = uicontrol(...
    'Parent', obj.gui.selectPeaksPopup.mainPanel,...
    'Style', 'text',...
    'HorizontalAlignment','center',...
    'BackgroundColor',[0.9 0.9 0.9 ],...
    'Units', 'normalized',...
    'String','Peaks Selection and Tracking',...
    'FontSize', 13, ...
    'FontWeight','bold',...
    'Position', [.3, .95, .4, .035]);

% instructions string
obj.gui.selectPeaksPopup.instructionString = uicontrol(...
    'parent', obj.gui.selectPeaksPopup.mainPanel,...
    'Style', 'text',...
    'BackgroundColor',[0.9 0.9 0.9 ],...
    'Units', 'normalized', ...
    'Position', [.30, .91, .4, .035],...
    'String', 'INSTRUCTIONS:', ...
    'FontWeight','bold',...
    'FontSize', 12);

% dynamic instructions box
obj.gui.selectPeaksPopup.instructions = uicontrol(...
    'parent', obj.gui.selectPeaksPopup.mainPanel,...
    'Style', 'text',...
    'BackgroundColor',[0.9 0.9 0.9 ],...
    'Units', 'normalized',...
    'Position', [.30, .87, .4, .035],...
    'String', instructions{1}, ...
    'FontWeight', 'bold', ...
    'FontSize', 11, ...
    'ForegroundColor', [0, 0, 1]);

% save and close button
obj.gui.selectPeaksPopup.save_and_close_button = uicontrol(...
    'parent', obj.gui.selectPeaksPopup.mainPanel,...
    'Style', 'pushbutton',...
    'units', 'normalized',...
    'String', 'SAVE & CLOSE',...
    'FontWeight', 'bold', ...
    'Enable', 'on',...
    'Position', [0.73, 0.87, 0.12, 0.05],...
    'Callback', {@save_and_close_cb, obj, targetDevice, numDetectors});

%% Generate Axes
plotPanel_w = 0.62;
plotPanel_h = 0.85;
% axes panel
obj.gui.selectPeaksPopup.plotPanel = uipanel(...
    'parent', obj.gui.selectPeaksPopup.mainPanel,...
    'Title', 'Sweep Data', ...
    'FontWeight', 'bold', ...
    'FontSize', 11, ...
    'BackgroundColor', [0.9, 0.9, 0.9],...
    'Visible', 'on',...
    'Units', 'normalized',...
    'Position', [0.01, 0.01, plotPanel_w, plotPanel_h]);

for i = 1:numDetectors
    % draw axes
    obj.gui.selectPeaksPopup.sweepScanSubplot(i)= subplot(numDetectors, 1, i);
    set(obj.gui.selectPeaksPopup.sweepScanSubplot(i), ...
        'Parent', obj.gui.selectPeaksPopup.plotPanel, ...
        'Units', 'normalized');
    axePosition = get(obj.gui.selectPeaksPopup.sweepScanSubplot(i), 'Position');
    axePosition(1) = 0.08;
    axePosition(2) = 1.01 - axePosition(4)*1.5*i;
    set(obj.gui.selectPeaksPopup.sweepScanSubplot(i), ...
        'Position', axePosition)
    xlabel('Wavelength [nm]');
    ylabel('Power [dBm]');
    title(strcat(['Detector ', num2str(i)]));
   
    % start button for peak selection
    obj.gui.selectPeaksPopup.startButton(i) = uicontrol(...
        'Parent', obj.gui.selectPeaksPopup.plotPanel,...
        'Style', 'pushbutton',...
        'units', 'normalized',...
        'position', [.87, axePosition(2) + axePosition(4)*0.84, .12, axePosition(4)*0.17],...
        'string', 'Start',...
        'Enable', 'on',...
        'callback', {@start_button_cb, obj,instructions, i});
    
    % done button for peak selection
    obj.gui.selectPeaksPopup.doneButton(i) = uicontrol(...
        'Parent', obj.gui.selectPeaksPopup.plotPanel,...
        'Style', 'pushbutton',...
        'units', 'normalized',...
        'position', [.87, axePosition(2) + axePosition(4)*0.66, .12, axePosition(4)*0.17],...
        'string', 'Done',...
        'userData', false, ...
        'Enable', 'off', ...
        'callback', {@done_button_cb, obj,instructions, targetDevice, i});
    
    % Table to show selected wvls
    PeakLocations = {};
    obj.gui.selectPeaksPopup.peaksTable(i) = uitable(...
        'Parent', obj.gui.selectPeaksPopup.plotPanel,...
        'ColumnName', {'Wvl'},...
        'ColumnFormat',{'char'},...
        'ColumnEditable', false,...
        'Units','normalized',...
        'Position', [0.87, axePosition(2), 0.12, axePosition(4)*0.66],...
        'Data', PeakLocations,...
        'FontSize', 9,...
        'ColumnWidth', {50},...
        'CellEditCallback',{@cell_edit_cb, i},...
        'CellSelectionCallback', {@cell_sel_cb, i},...
        'Enable', 'on');
end

%% Create Data Storage Directory
if (~obj.devices.(targetDevice).hasDirectory)
    filePath = createTempDataPath(obj);
    dateTag = datestr(now,'yyyy.mm.dd@HH.MM'); % time stamp
    obj.devices.(targetDevice).checkDirectory(filePath, obj.AppSettings.infoParams.Task, dateTag);
end

%% INSTR UI PANELS
% UI parameters (position)
ui_x = plotPanel_w + 0.015;
ui_y = 0.01;
ui_width = 0.99 - ui_x;
ui_height = 0;
ui_position = [ui_x, ui_y, ui_width, ui_height];

% Optical Stage UI
if (obj.instr.opticalStage.Connected)
    ui_position(4) = 0.26;
    obj = optical_stage_ui(...
        obj, ...
        'selectPeaks', ...
        obj.gui.selectPeaksPopup.mainPanel, ...
        ui_position);
end

% Laser UI
if (obj.instr.laser.Connected)
    ui_position(2) = ui_position(2) + ui_position(4);
    ui_position(4) = 0.26;
    obj = laser_ui(...
        obj, ...
        'selectPeaks', ...
        obj.gui.selectPeaksPopup.mainPanel, ...
        ui_position, ...
        obj.gui.selectPeaksPopup.sweepScanSubplot);
end

% Detector UI
if (obj.instr.detector.Connected)
    ui_position(2) = ui_position(2) + ui_position(4);
    ui_position(4) = 0.85 - ui_position(2);
    obj = detector_ui(...
        obj, ...
        'selectPeaks', ...
        obj.gui.selectPeaksPopup.mainPanel, ...
        ui_position);
end

movegui(obj.gui.selectPeaksPopup.mainWindow, 'center');
set(obj.gui.selectPeaksPopup.mainWindow, 'Visible', 'on');
end % ends SelectPeaks Popup

%% SELECT PEAKS FROM PLOT
function peak_selection(obj, instructions, index) % --- Vince 2013
PeakLocations = {};

% Delete the previous (if any) peak selection
delete(findobj(obj.gui.selectPeaksPopup.sweepScanSubplot(index), 'Marker', '+'));
set(obj.gui.selectPeaksPopup.peaksTable(index), 'Data', {});

%this is not good: can't reset peak locations.
dataObj = get(obj.gui.selectPeaksPopup.sweepScanSubplot(index),'Children');
wvlVals = get(dataObj, 'XData');
pwrVals = get(dataObj, 'YData');
% WinPoints = 5/(wvlVals(2)-wvlVals(1)); % window/step = num of elements: for a 2nm window;
xrange = max(wvlVals) - min(wvlVals);
tol = xrange/100;
n = 0;
hold(obj.gui.selectPeaksPopup.sweepScanSubplot(index), 'on');
finish = false;
while (~finish)
    [xsel, ysel, button] = ginput(1);
    % get x,y coord of mouse cursor
    % button is an integer indicating which mouse buttons you pressed
    % (1 for left, 2 for middle, 3 for right)
    if (button == 1) %user - left-click
        boundary = ...
            xsel <= max(wvlVals) && xsel >= min(wvlVals) && ...
            ysel <= max(pwrVals) && ysel >= min(pwrVals);
        if (boundary) % Process data only when user click with in the proper axes
            % Limit the range of wavelength selection
            wvlVals_filter = wvlVals(abs(wvlVals - xsel) <= tol);
            pwrVals_filter = pwrVals(abs(wvlVals - xsel) <= tol);
            
            % Find the peak power value within the limited range above
            [y_peak, ind] = min(pwrVals_filter); % look for index of min y in range
            x_peak = wvlVals_filter(ind);
            
            % update plot /w X on selected point
            plot(obj.gui.selectPeaksPopup.sweepScanSubplot(index), x_peak, y_peak, 'r+'); % make a red-x at point
            n = n + 1;
            PeakLocations{n,1} = x_peak;
            set(obj.gui.selectPeaksPopup.peaksTable(index), 'Data', PeakLocations);
            set(obj.gui.selectPeaksPopup.instructions, 'String', instructions{3});
        end
    elseif (button == 2 || button == 3)  %user right or middle mouse click
        finish = true;
    end
end
hold(obj.gui.selectPeaksPopup.sweepScanSubplot(index), 'off');
end

%% CALLBACK FUNCTIONS

function closeWindow(hObject, ~)
delete(hObject);
end

function start_button_cb(hObject, ~, obj, instructions, index)
set(hObject, 'Enable', 'off'); % disable the start button that was pressed
% set(obj.gui.selectPeaksPopup.doneButton(index), 'Enable', 'on');
set(obj.gui.selectPeaksPopup.instructions, 'String', instructions{2});
set(obj.gui.selectPeaksPopup.doneButton(index), 'Enable', 'on');
peak_selection(obj,instructions, index);
end

function done_button_cb(hObject, ~, obj, instructions, targetDevice, index)
% save wvls (meters) of selected peaks to device object
% also find the min/max of selected peaks from all detectors and save in
% device object as start and stop wvls
obj.devices.(targetDevice).PeakLocations{index} = {};
obj.devices.(targetDevice).PeakLocationsN{index} = {};

set(obj.gui.selectPeaksPopup.instructions, 'String', instructions{1}); % update displayed instructions
set(obj.gui.selectPeaksPopup.startButton(index), 'Enable', 'on'); % enable start button again
wvl_data = cell2mat(get(obj.gui.selectPeaksPopup.peaksTable(index), 'data')); % get wvl data from table
% find min and max of data
data_min = min(wvl_data);
data_max = max(wvl_data);
% save data to the device object
%device.PeakLocations.(strcat('Detector',num2str(index))) = wvl_data;
for ii = 1:length(wvl_data)
    obj.devices.(targetDevice).PeakLocations{index}{ii} = wvl_data(ii);
    obj.devices.(targetDevice).PeakLocationsN{index}{ii} = 0;
end
% determine if overall min/max is within data and set if so
% min (start wvl)
if isempty(obj.devices.(targetDevice).getProp('StartWvl')) % device property not set yet
    obj.devices.(targetDevice).setProp('StartWvl', data_min);
elseif data_min < obj.devices.(targetDevice).getProp('StartWvl') % current start higher than lowest selected peak
    obj.devices.(targetDevice).setProp('StartWvl', data_min);
end
% max (stop wvl)
if isempty(obj.devices.(targetDevice).getProp('StopWvl'))
    obj.devices.(targetDevice).setProp('StopWvl', data_max);
elseif data_max > obj.devices.(targetDevice).getProp('StopWvl')
    obj.devices.(targetDevice).setProp('StopWvl', data_max);
end

set(hObject, 'Enable', 'off'); % disable done button that was pushed
end

function save_and_close_cb(~, ~, obj, targetDevice, numDetectors)
if isempty(obj.devices.(targetDevice).PeakLocations)
    obj.devices.(targetDevice).PeakLocations = cell(numDetectors, 1);
elseif numDetectors > length(obj.devices.(targetDevice).PeakLocations)
    for index = length(obj.devices.(targetDevice).PeakLocations):numDetectors
        obj.devices.(targetDevice).PeakLocations{index} = {};
        obj.devices.(targetDevice).PeakLocationsN{index} = {};
    end
end
obj.devices.(targetDevice).trackPeaks();
close(obj.gui.selectPeaksPopup.mainWindow);
obj.gui.popup_peaks = [];
end

function cell_edit_cb(hObject, eventdata, index)
end

function cell_sel_cb(hObject, eventdata, index)
end