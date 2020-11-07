function varargout = GUInxp(varargin)
% GUINXP MATLAB code for GUInxp.fig
%      GUINXP, by itself, creates a new GUINXP or raises the existing
%      singleton*.
%
%      H = GUINXP returns the handle to a new GUINXP or the handle to
%      the existing singleton*.
%
%      GUINXP('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUINXP.M with the given input arguments.
%
%      GUINXP('Property','Value',...) creates a new GUINXP or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GUInxp_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GUInxp_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GUInxp

% Last Modified by GUIDE v2.5 17-Oct-2019 16:28:50

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GUInxp_OpeningFcn, ...
                   'gui_OutputFcn',  @GUInxp_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before GUInxp is made visible.
function GUInxp_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GUInxp (see VARARGIN)

% Choose default command line output for GUInxp
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes GUInxp wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = GUInxp_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
%to run and receive data
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global stop
global g_speed_sp_left
global g_speed_sp_right
global g_speed_left
global g_speed_right
global g_error_steering
global g_lineR
global g_lineL
global caseLibre
global s %serial port
stop=0
comPort=get(handles.editCOM,'String')
s = serial(comPort, 'BaudRate', 115200,'TimeOut',0.1,'Terminator', 'LF')
fopen(s);
fclose(s);

    %% declaration des variables :
    g_speed_sp_left = zeros(1e4, 1);
    g_speed_sp_right = zeros(1e4, 1);

    g_speed_left = zeros(1e4, 1);
    g_speed_right = zeros(1e4, 1);

    g_error_steering = zeros(1e4, 1);

    g_lineR = zeros(1e4, 1);
    g_lineL = zeros(1e4, 1);
    
    caseLibre=0;
    
while(stop==0)
    s = serial(comPort, 'BaudRate', 115200,'TimeOut',0.1,'Terminator', 'LF');
    fopen(s);
    receveidRead = fread(s, 128, 'uint8');
    fclose(s);
    dataFirst=-2; %position du bit de depart
    tailleTab = size(receveidRead,1);
    if tailleTab>21
        for c = 1:21
            if receveidRead(c)== 42
                if receveidRead(c+1) == 21
                    dataFirst = c;
                end
            end
        end
    else
        disp('No data found');

    end
    

        %% remplir variable
    if dataFirst >= 0

        while(dataFirst+21<tailleTab)
            caseLibre = caseLibre+1;
            g_speed_sp_left(caseLibre) = bitToDec(receveidRead(dataFirst+2),receveidRead(dataFirst+3),receveidRead(dataFirst+4),receveidRead(dataFirst+5));
            g_speed_sp_right(caseLibre) = bitToDec(receveidRead(dataFirst+10),receveidRead(dataFirst+11),receveidRead(dataFirst+12),receveidRead(dataFirst+13));

            g_speed_left(caseLibre) = bitToDec(receveidRead(dataFirst+6),receveidRead(dataFirst+7),receveidRead(dataFirst+8),receveidRead(dataFirst+9));
            g_speed_right(caseLibre) = bitToDec(receveidRead(dataFirst+14),receveidRead(dataFirst+15),receveidRead(dataFirst+16),receveidRead(dataFirst+17));
            
            g_error_steering(caseLibre) = bitToDec(0,0,0,receveidRead(dataFirst+18));           
            if g_error_steering(caseLibre)>127
               g_error_steering(caseLibre)=-1*(255-g_error_steering(caseLibre));
            end
            g_lineR(caseLibre) = bitToDec(0,0,0,receveidRead(dataFirst + 19));
            g_lineL(caseLibre) =  bitToDec(0,0,0,receveidRead(dataFirst +20));

            dataFirst= dataFirst+21;
        end
    end

    %graph = append(graph, 10);
%     graph1(end+1) = val(2);%put fgets
%     graph2(end+1) = val(5);%put fgets
%     graph3(end+1) = val(4);%put fgets


    
    graphSave1 = g_speed_sp_left(max(1,caseLibre-100):caseLibre);
    graphSave2 = g_speed_sp_right(max(1,caseLibre-100):caseLibre);
    graphSave3 = g_speed_left(max(1,caseLibre-100):caseLibre);
    graphSave4 = g_speed_right(max(1,caseLibre-100):caseLibre);
    graphSave5 = g_error_steering(max(1,caseLibre-100):caseLibre);
    graphSave6 = g_lineR(max(1,caseLibre-100):caseLibre);
    graphSave7 = g_lineL(max(1,caseLibre-100):caseLibre);
    
    x = max(1,caseLibre-100):caseLibre;
    plot(handles.axes1,x,graphSave1,'r',x, graphSave3,'b');
    title(handles.axes1,'speed left');
    plot(handles.axes2,x,graphSave2,'r',x,graphSave4, 'b');
    title(handles.axes2,'speed right');
    plot(handles.axes3,x,graphSave6,'r', x,graphSave7, 'b');
    title(handles.axes3,'left line / right line');
    plot(handles.axes4,x,graphSave5,'r');
    title(handles.axes4,'Error Values');
    %axis([-15 15 0 inf]);

    pause(0.01)
    drawnow;
end
display('finish')



function editCOM_Callback(hObject, eventdata, handles)
% hObject    handle to editCOM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% Hints: get(hObject,'String') returns contents of editCOM as text
%        str2double(get(hObject,'String')) returns contents of editCOM as a double


% --- Executes during object creation, after setting all properties.
function editCOM_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editCOM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton2.

%to stop receiving data
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global stop
global g_speed_sp_left
global g_speed_sp_right
global g_speed_left
global g_speed_right
global g_error_steering
global g_lineR
global g_lineL
global caseLibre
global s
stop =1
g_speed_sp_left=[]
g_speed_left = []
g_speed_right = []
g_error_steering = []
g_lineR = []
g_lineL = []
caseLibre=0;
display('stop')

fclose(s);
pause(2);



function editFileName_Callback(hObject, eventdata, handles)
% hObject    handle to editFileName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editFileName as text
%        str2double(get(hObject,'String')) returns contents of editFileName as a double


% --- Executes during object creation, after setting all properties.
function editFileName_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editFileName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton3.
%to save the result
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global g_speed_sp_left
global g_speed_sp_right
global g_speed_left
global g_speed_right
global g_error_steering
global g_lineR
global g_lineL

T= table(g_speed_sp_left, g_speed_sp_right, g_speed_left,g_speed_right,g_error_steering,g_lineR,g_lineL);
fileName=get(handles.editFileName,'String')
fileName=strcat(fileName);
writetable(T,fileName)
