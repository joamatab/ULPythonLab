function chip_history_dialog(obj)

% create popup dialog box for user to enter info
history_entry = dialog('Name', 'Entry box');

% instruction string
dialog_string = uicontrol('Parent', history_entry,...
    'Style', 'text',...
    'Enable', 'on',...
    'HorizontalAlignment', 'left',...
    'Units', 'normalized',...
    'String', 'Enter information to be added to chip history. Click outside the text box to save your input.',...
    'FontSize', 10,...
    'Position', [.05, .925, .9, .05]);

% text box for user input
entry_box = uicontrol('Parent', history_entry,...
    'Style', 'edit',...
    'Enable', 'on',...
    'Units', 'normalized',...
    'Position', [.1, .1, .8, .8],...
    'FontSize', 10,...
    'HorizontalAlignment', 'left',...
    'Max', 100,...
    'Callback', {@entry_box_CB, obj});

% Callback
    function entry_box_CB(hObject, eventdata, obj)
        text = strcat(get(entry_box, 'String'));
        user_date_time = strcat([' ', datestr(now), 'wrote: ']);
        obj.chip.save_history(text, user_date_time);
    end

end