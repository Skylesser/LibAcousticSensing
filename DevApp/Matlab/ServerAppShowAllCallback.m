function [] = ServerAppShowAllCallback( obj, type, data )
%SERVERDEVCALLBACK Summary of this function goes here
    global USER_FIG_TAG;
    USER_FIG_TAG = 'USER_FIG_TAG';
    global PS; % user parse setting
    global detectResults;
    global detectResultsEnd;
    DETECT_RESULT_SIZE = 300; % number of result sample to show
    
    if type == obj.CALLBACK_TYPE_ERROR,
        fprintf(2, '[ERROR]: get the error callback data = %s', data);
        return;
    end

    CH_CNT_TO_SHOW = 1; % TOOD: set it based on device settings
    
    % parse audio data
    if type == obj.CALLBACK_TYPE_DATA,
        LINE_CNTS = [2,2,3]; % size of it is the number of figure axes, and the number in it is the number of lines per axe
        %hFig = findobj('Tag',FIG_CON_TAG);
        if obj.userfig == -1, % need to create a new UI window
            detectResultsEnd = 0;
            detectResults = zeros(DETECT_RESULT_SIZE, 1);

            createUI(obj, USER_FIG_TAG, data, LINE_CNTS);
        else
            % process data
            
            % convlution of all data
            cons = convn(data, PS.signalToCorrelate,'same');
            
            detectChIdx = 1;
            dataTime = data(:,end,detectChIdx); 
            FS = 48000;
            DF = FS/length(dataTime);
            freqs = -FS/2:DF:(FS/2-DF);
            SMOOTH_FACTOR = 5;
            dataFreq = smooth(fftshift(abs(fft(dataTime))), SMOOTH_FACTOR);
            
            % return the result if need
            if PS.detectEnabled,
                %obj.jss.write()
            end
            
            % line1: data 
            check1 = findobj('Tag','check01');
            if check1.Value == 1,
                for chIdx = 1:CH_CNT_TO_SHOW,
                    line = findobj('Tag',sprintf('line01_%02d',chIdx));
                    dataToPlot = data(:,end,chIdx);
                    set(line, 'yData', dataToPlot); % only show the 1st ch
                end
            end

            % line2: con 
            check2 = findobj('Tag','check02');
            if check2.Value == 1,
                for chIdx = 1:CH_CNT_TO_SHOW,
                    line = findobj('Tag',sprintf('line02_%02d',chIdx));
                    conToPlot = 10*log10(smooth(abs(cons(:,end,chIdx)),100));
                    set(line, 'yData', conToPlot); % only show the 1st ch
                end
            end

            % line3: detect result
            check3 = findobj('Tag','check03');
            if check3.Value == 1,
                line = findobj('Tag','line03_01');
                set(line, 'yData', dataFreq(PS.detectRangeStart:PS.detectRangeEnd)); % only show the 1st ch
            end
            
        end
    elseif type == obj.CALLBACK_TYPE_USER,
        % parse user data
        % must be 'pse' in this app
        if data.code == 1, % update the vertical line
            PS.detectEnabled = 1;
            refIdx = detectResultsEnd-1;
            if refIdx<0
                refIdx = 1;
            end
            PS.detectRef = detectResults(refIdx); % latest detect reuslt is the reference
            
            line = findobj('Tag','line03_02');
            set(line, 'yData', zeros(DETECT_RESULT_SIZE,1)+ PS.detectRef); % only show the 1st ch
        else
            PS.detectEnabled = 0;
            PS.detectRef = 1;
        end
    end
end

function createUI(obj, figTag, data, lineCnts)
    % lineCnts is the number of lines per figure
    global PS;
    
    PLOT_AXE_IN_WIDTH = 270;
    PLOT_AXE_OUT_WIDTH = 290;
    PLOT_AXE_CNT = length(lineCnts);
    
    obj.userfig = figure('Position',[50,50,550+PLOT_AXE_OUT_WIDTH*(PLOT_AXE_CNT-1),330],'Toolbar','none','MenuBar','none','Tag',figTag);
    set(obj.userfig,'UserData',obj); % attached the obj to fig property for future reference 
    
    h_panel2 = uipanel(obj.userfig,'Units','pixels','Position',[15,15,520+PLOT_AXE_OUT_WIDTH*(PLOT_AXE_CNT-1),300]);
    textIntro = uicontrol(h_panel2,'Style','text','Position',[10,255,180,30],'String','Control the sensing response');
    
    RANGE_Y = 200;
    RANGE_FONT_SIZE = 15;
    textRange = uicontrol(h_panel2,'Style','text','Position',[25,RANGE_Y-5,50,30],'String','Range:','FontSize',RANGE_FONT_SIZE);
    uicontrol(h_panel2, 'Tag','editRangeStart', 'style','edit','units','pixels','position',[80,RANGE_Y,50,30],'String',num2str(PS.detectRangeStart),'FontSize',RANGE_FONT_SIZE);
    uicontrol(h_panel2, 'Tag','editRangeEnd', 'style','edit','units','pixels','position',[130,RANGE_Y,50,30],'String',num2str(PS.detectRangeEnd),'FontSize',RANGE_FONT_SIZE);
    
    
    buttonApply = uicontrol(h_panel2,'Style','pushbutton','Position',[30,130,110,30],'String','Apply','Callback',@buttonApplyCallback);
            
    

    %{
    buttonStartSensing = uicontrol(h_panel2,'Style','pushbutton',...
                'Position',[30,200,110,30],...
                'String','Start Sensing',...
                'BusyAction','queue',...
                'TooltipString','BusyAction = queue',...
                'Callback',@callbackStartSensing);
            %}
            
    
                
    for i = 1:PLOT_AXE_CNT,
        uicontrol(h_panel2, 'Style','checkbox','String','update','Value',0,'Position',[220+PLOT_AXE_OUT_WIDTH*(i-1),280,80,20], 'Tag',sprintf('check%02d',i));
        
        obj.axe = axes('Parent',h_panel2,'Units','pixels','Position',[220+PLOT_AXE_OUT_WIDTH*(i-1),30,270,250]);
        hold on;
        for j = 1:lineCnts(i),
            plot(obj.axe, data(:,1),'Tag',sprintf('line%02d_%02d',i,j),'linewidth',2); % only show the 1st ch
        end
        hold off;
        legend(arrayfun(@(x) sprintf('%d',x), 1:lineCnts(i),'uni',false).');
    end
        

%MY_SLIDER is an example of Matlab GUI
% ref: https://www.mathworks.com/help/matlab/creating_guis/share-data-among-callbacks.html#bt9p4qp
%{
    hfig = figure('Tag',figTag);
    set(hfig,'UserData',obj);
    recordButton = uicontrol('Parent', hfig,'Style','pushbutton',...
             'Tag','recordButton',...
             'Units','normalized',...
             'Position',[0.4 0.3 0.2 0.1],...
             'String','Record',...
             'Callback',@recordButtonCallback);
    line = plot(data(:,1),'r','Tag','line1','linewidth',2); % only show the 1st ch
%}
end

function callbackStartSensing(obj, event)
    fprintf('    callbackStartSensing is called\n');
    global USER_FIG_TAG;
    userfig = findobj('Tag', USER_FIG_TAG);
    ss = userfig.UserData;
    while ss.latestReceivedAction ~= ss.ACTION_INIT,
        fprintf('    wait socket is connected\n');
        pause(1.0);
    end
    ss.startSensing();
end

function recordButtonCallback(obj, event)
    recordButton = findobj('Tag','recordButton');
    if strcmp(recordButton.String,'Record'), 
        recordButton.String = 'Stop';
        hFig = findobj('Tag', 'FIG_CON_TAG');
        ss = hFig.UserData;
        ss.startRecord();
    elseif strcmp(recordButton.String,'Stop'),
        recordButton.String = 'Record';
        prompt = {'Enter the trace tag','Enter the path to save'};
        dlg_title = 'Input';
        num_lines = 1;
        defaultans = {'none','Records/'};
        answer = inputdlg(prompt,dlg_title,num_lines,defaultans);
        ss.stopRecord(answer(1), answer(2));
    else
        fprintf(2,'[ERROR]: undefined recordButton status\n');
    end
end


% apply ui control to parse value
function buttonApplyCallback(obj,event)
    global PS;
    editRangeStart = findobj('Tag','editRangeStart');
    editRangeEnd = findobj('Tag','editRangeEnd');
    
    rangeStart = str2num(editRangeStart.String);
    rangeEnd = str2num(editRangeEnd.String);
    
    if isempty(rangeStart) || isempty(rangeEnd),
        warndlg('Range input must be numerical');
    else
        PS.detectRangeStart = rangeStart;
        PS.detectRangeEnd = rangeEnd;
    end
end