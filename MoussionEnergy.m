classdef MoussionEnergy < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        MoussionEnergyUIFigure      matlab.ui.Figure
        EnergyPanel                 matlab.ui.container.Panel
        PlotEnergySwitch            matlab.ui.control.Switch
        PlotRawSwitch               matlab.ui.control.Switch
        WhiskerCheckBox             matlab.ui.control.CheckBox
        NoseCheckBox                matlab.ui.control.CheckBox
        EyeCheckBox                 matlab.ui.control.CheckBox
        EnergyAxes                  matlab.ui.control.UIAxes
        SettingsPanel               matlab.ui.container.Panel
        RecordingLimitsSwitch       matlab.ui.control.Switch
        RecordinglimitsSwitchLabel  matlab.ui.control.Label
        ComputeMotionEnergyButton   matlab.ui.control.Button
        SaveResultsButton           matlab.ui.control.Button
        SmoothingSpinner            matlab.ui.control.Spinner
        samplingperiodmsLabel_2     matlab.ui.control.Label
        SetSettingsDropDown         matlab.ui.control.DropDown
        FromworkspaceLabel          matlab.ui.control.Label
        FinalFrameSpinner           matlab.ui.control.Spinner
        finalLabel                  matlab.ui.control.Label
        InitialFrameSpinner         matlab.ui.control.Spinner
        initialLabel                matlab.ui.control.Label
        FPSSpinner                  matlab.ui.control.Spinner
        samplingperiodmsLabel       matlab.ui.control.Label
        MoviePanel                  matlab.ui.container.Panel
        MovieDropDown               matlab.ui.control.DropDown
        FrameSpinner                matlab.ui.control.Spinner
        frameSpinnerLabel           matlab.ui.control.Label
        FrameSlider                 matlab.ui.control.Slider
        ImageAxes                   matlab.ui.control.UIAxes
        PathPanel                   matlab.ui.container.Panel
        LoadVideoButton             matlab.ui.control.Button
        FileEditField               matlab.ui.control.EditField
        FileButton                  matlab.ui.control.Button
    end

    
    properties (Access = private)
        movie = [];                 % Movie images
        prop = [];                  % Movie properties
        frame_number = 1;           % Number of current frame
        eye_ROI = [];
        nose_ROI = [];
        whiskers_ROI = [];
        eye_ROI_changed = false;    % eye ROI flag
        nose_ROI_changed = false;   % nose ROI glag
        whisker_ROI_changed = false;% whiskers ROI flag
        smoothing_changed = false;  % smoothing flag
        line_ROI = [];              % line ROI
        image = [];                 % frame image
        plot_raw = true;
        plot_energy = true;
        face = struct;
    end
    
    methods (Access = private)
        
        function Update_Image(app)
            app.image.CData = app.movie(:,:,app.frame_number);
        end
        
        function Update_Plot(app)
            % Get initial and final frames
            ini = app.InitialFrameSpinner.Value;
            fin = app.FinalFrameSpinner.Value-1;

            % Plot smoothed signals
            cla(app.EnergyAxes)

            % Plot Eye signal
            if app.EyeCheckBox.Value && ~isempty(app.face.Eye.Energy)
                if app.plot_raw
                    % Plot Raw
                    if app.plot_energy
                        % Plot Energy
                        plot(app.EnergyAxes,ini:fin,app.face.Eye.Energy(ini:fin),'color',Get_Color(1,'jp'))
                        hold(app.EnergyAxes,'on')
                        plot(app.EnergyAxes,find(app.face.Blinking),app.face.Eye.Energy(app.face.Blinking),...
                            '*','color',Darken_Colors(Get_Color(1,'jp')))
                    else
                        % Plot Intensity
                        plot(app.EnergyAxes,ini:fin,app.face.Eye.Intensity(ini:fin),'color',Get_Color(1,'jp'))
                        hold(app.EnergyAxes,'on')
                        plot(app.EnergyAxes,find(app.face.Blinking),app.face.Eye.Intensity(app.face.Blinking),...
                            '*','color',Darken_Colors(Get_Color(1,'jp')))
                    end
                else
                    % Plot smoothed signal
                    if app.plot_energy
                        % Plot Energy
                        plot(app.EnergyAxes,ini:fin,app.face.Eye.EnergySmoothed(ini:fin),'color',Get_Color(1,'jp'))
                        hold(app.EnergyAxes,'on')
                        plot(app.EnergyAxes,find(app.face.Blinking),app.face.Eye.EnergySmoothed(app.face.Blinking),...
                            '*','color',Darken_Colors(Get_Color(1,'jp')))
                    else
                        % Plot Intensity
                        plot(app.EnergyAxes,ini:fin,app.face.Eye.IntensitySmoothed(ini:fin),'color',Get_Color(1,'jp'))
                        hold(app.EnergyAxes,'on')
                        plot(app.EnergyAxes,find(app.face.Blinking),app.face.Eye.IntensitySmoothed(app.face.Blinking),...
                            '*','color',Darken_Colors(Get_Color(1,'jp')))
                    end
                end
            end

            % Plot Nose signal
            if app.NoseCheckBox.Value && ~isempty(app.face.Nose.Energy)
                if app.plot_raw
                    if app.plot_energy
                        plot(app.EnergyAxes,ini:fin,app.face.Nose.Energy(ini:fin),'color',Get_Color(2,'jp'))
                        hold(app.EnergyAxes,'on')
                        plot(app.EnergyAxes,find(app.face.Sniffing),app.face.Nose.Energy(app.face.Sniffing),...
                            '*','color',Darken_Colors(Get_Color(2,'jp')))
                    else
                        plot(app.EnergyAxes,ini:fin,app.face.Nose.Intensity(ini:fin),'color',Get_Color(2,'jp'))
                        hold(app.EnergyAxes,'on')
                        plot(app.EnergyAxes,find(app.face.Sniffing),app.face.Nose.Intensity(app.face.Sniffing),...
                            '*','color',Darken_Colors(Get_Color(2,'jp')))
                    end
                else
                    if app.plot_energy
                        plot(app.EnergyAxes,ini:fin,app.face.Nose.EnergySmoothed(ini:fin),'color',Get_Color(2,'jp'))
                        hold(app.EnergyAxes,'on')
                        plot(app.EnergyAxes,find(app.face.Sniffing),app.face.Nose.EnergySmoothed(app.face.Sniffing),...
                            '*','color',Darken_Colors(Get_Color(2,'jp')))
                    else
                        plot(app.EnergyAxes,ini:fin,app.face.Nose.IntensitySmoothed(ini:fin),'color',Get_Color(2,'jp'))
                        hold(app.EnergyAxes,'on')
                        plot(app.EnergyAxes,find(app.face.Sniffing),app.face.Nose.IntensitySmoothed(app.face.Sniffing),...
                            '*','color',Darken_Colors(Get_Color(2,'jp')))
                    end
                end
                hold(app.EnergyAxes,'on')
            end

            % Plot Whiskers signal
            if app.WhiskerCheckBox.Value && ~isempty(app.face.Whiskers.Energy)
                if app.plot_raw
                    if app.plot_energy
                        plot(app.EnergyAxes,ini:fin,app.face.Whiskers.Energy(ini:fin),'color',Get_Color(3,'jp'))
                    else
                        plot(app.EnergyAxes,ini:fin,app.face.Whiskers.Intensity(ini:fin),'color',Get_Color(3,'jp'))
                    end
                else
                    if app.plot_energy
                        plot(app.EnergyAxes,ini:fin,app.face.Whiskers.EnergySmoothed(ini:fin),'color',Get_Color(3,'jp'))
                    else
                        plot(app.EnergyAxes,ini:fin,app.face.Whiskers.IntensitySmoothed(ini:fin),'color',Get_Color(3,'jp'))
                    end
                end
            end
            % Place line ROI
            app.line_ROI.delete()
            app.line_ROI = drawline(app.EnergyAxes,'Color',[0 0 0],...
                    'Position',[[app.frame_number app.frame_number];...
                    app.EnergyAxes.YLim]','InteractionsAllowed','none','LineWidth',1);
        end
        
        function ChangeEyeROI_Callback(app)
            % Update ROI values
            app.face.Eye.ROI.Center = app.eye_ROI.Center;
            app.face.Eye.ROI.SemiAxes = app.eye_ROI.SemiAxes;
            app.face.Eye.ROI.RotationAngle = app.eye_ROI.RotationAngle;
            
            Need_To_Compute(app)
            app.eye_ROI_changed = true;
        end

        function ChangeNoseROI_Callback(app)
            % Update ROI values
            app.face.Nose.ROI.Center = app.nose_ROI.Center;
            app.face.Nose.ROI.SemiAxes = app.nose_ROI.SemiAxes;
            app.face.Nose.ROI.RotationAngle = app.nose_ROI.RotationAngle;
            
            Need_To_Compute(app)
            app.nose_ROI_changed = true;
        end

        function ChangeWhiskerROI_Callback(app)
            % Update ROI values
            app.face.Whiskers.ROI.Position = app.whiskers_ROI.Position;

            Need_To_Compute(app)
            app.whisker_ROI_changed = true;
        end
        
        function Need_To_Compute(app)
            % Change control properties
            app.ComputeMotionEnergyButton.BackgroundColor = [0.96 0.96 0.96];
            app.ComputeMotionEnergyButton.Text = {'Compute';'motion energy'};
            app.ComputeMotionEnergyButton.Enable = 'on';
            app.SaveResultsButton.BackgroundColor = [0.96 0.96 0.96];
            app.SaveResultsButton.Text = 'Save results';
            app.SaveResultsButton.Enable = 'on';
        end
        
        function Add_ROIs(app)
            % Add ROIs to image
            app.eye_ROI = images.roi.Ellipse(app.ImageAxes,...
                'Center',app.face.Eye.ROI.Center,...
                'SemiAxes',app.face.Eye.ROI.SemiAxes,...
                'RotationAngle',app.face.Eye.ROI.RotationAngle,...
                'Color',Get_Color(1,'jp'),...
                'Deletable',false,'FaceAlpha',0);
            app.nose_ROI = images.roi.Ellipse(app.ImageAxes,...
                'Center',app.face.Nose.ROI.Center,...
                'SemiAxes',app.face.Nose.ROI.SemiAxes,...
                'RotationAngle',app.face.Nose.ROI.RotationAngle,...
                'Color',Get_Color(2,'jp'),...
                'Deletable',false,'FaceAlpha',0);
            app.whiskers_ROI = images.roi.Polygon(app.ImageAxes,...
                'Position',app.face.Whiskers.ROI.Position,...
                'Color',Get_Color(3,'jp'),...
                'Deletable',false,'FaceAlpha',0);

            % Set listeners to ROIs
            addlistener(app.eye_ROI,'ROIMoved',@(~,~)ChangeEyeROI_Callback(app));
            addlistener(app.nose_ROI,'ROIMoved',@(~,~)ChangeNoseROI_Callback(app));
            addlistener(app.whiskers_ROI,'ROIMoved',@(~,~)ChangeWhiskerROI_Callback(app));
        end
    end

    % Callbacks that handle component events
    methods (Access = private)

        % Button pushed function: FileButton
        function FileButtonPushed(app, event)
            [file_name,path_name] = uigetfile('*.tif;*.avi','Select one video',app.FileEditField.Value);
            if file_name
                app.FileEditField.Value = [path_name file_name];
                FileEditFieldValueChanging(app)
            end
        end

        % Button pushed function: LoadVideoButton
        function LoadVideoButtonPushed(app, event)
            % Change control properties
            app.LoadVideoButton.BackgroundColor = [1 1 0.5];
            app.LoadVideoButton.Text = 'Loading...';
            drawnow

            % Read name
            file_name = app.FileEditField.Value;
            [~,name,ext] = fileparts(file_name);
    
            % Read file
            if strcmp(ext,'.tif')
                if exist(file_name,'file')
                    % Read TIF file
                    [app.movie,app.prop] = Read_Tiff_File(file_name);
                    app.face.Movie.FilePath = file_name;
                    app.face.Movie.Name = name;
                    app.face.Movie.Height = app.prop.height;
                    app.face.Movie.Width = app.prop.width;
                    app.face.Movie.Depth = app.prop.depth;
                    app.face.Movie.Frames = app.prop.frames;
    
                    %% Add results file data
                    results_file = [file_name(1:end-4) '_face.mat'];
                    if exist(results_file,'file')
                        load(results_file,['face_' name])
                        app.face = eval(['face_' name]);

                        % Change control properties
                        app.ComputeMotionEnergyButton.BackgroundColor = [0.5 1 0.5];
                        app.ComputeMotionEnergyButton.Text = {'Motion energy','computed!'};
                        app.ComputeMotionEnergyButton.Enable = 'off';
                        app.SaveResultsButton.BackgroundColor = [0.5 1 0.5];
                        app.SaveResultsButton.Text = 'Saved!';
                        app.SaveResultsButton.Enable = 'off';
                    else
                        % Initialize variables
                        app.face.Eye.Energy = [];
                        app.face.Eye.EnergySmoothed = [];
                        app.face.Eye.Intensity = [];
                        app.face.Eye.IntensitySmoothed = [];
                        app.face.Nose.Energy = [];
                        app.face.Nose.EnergySmoothed = [];
                        app.face.Nose.Intensity = [];
                        app.face.Nose.IntensitySmoothed = [];
                        app.face.Whiskers.Energy = [];
                        app.face.Whiskers.EnergySmoothed = [];
                        app.face.Whiskers.Intensity = [];
                        app.face.Whiskers.IntensitySmoothed = [];
                        app.face.Movie.Smoothing = 10;
                        app.face.Movie.FPS = 30;

                        % Create ROIs
                        app.face.Eye.ROI.Shape = 'Ellipse';
                        app.face.Eye.ROI.Center = [70 50];
                        app.face.Eye.ROI.SemiAxes = [22 20];
                        app.face.Eye.ROI.RotationAngle = 45;
                        app.face.Nose.ROI.Shape = 'Ellipse';
                        app.face.Nose.ROI.Center = [270 120];
                        app.face.Nose.ROI.SemiAxes = [20 30];
                        app.face.Nose.ROI.RotationAngle = 40;
                        app.face.Whiskers.ROI.Shape = 'Polygon';
                        app.face.Whiskers.ROI.Position = [240 80; 180 40; 180 235; 240 190];
    
                        % Identify initial and recording frame
                        sum_movie = squeeze(sum(app.movie,[1 2]));
                        th_recording = 3*std(sum_movie([1:30 end-30:end]))+...
                            mean(sum_movie([1:30 end-30:end]));
                        app.face.Movie.InitialFrameAuto = find(sum_movie>th_recording,1,'first');
                        app.face.Movie.InitialFrame = app.face.Movie.InitialFrameAuto;
                        app.face.Movie.FinalFrameAuto = find(sum_movie>th_recording,1,'last');
                        app.face.Movie.FinalFrame = app.face.Movie.FinalFrameAuto;

                        % Get convenient images
                        tic; disp('Computing convenient images...')
                        app.face.Movie.AverageImage = mean(app.movie,3);
                        app.face.Movie.MinImage = min(app.movie,[],3);
                        app.face.Movie.MaxImage = max(app.movie,[],3);
                        t=toc; disp(['   Done (' num2str(t) ' seconds)'])

                        % Change control properties
                        Need_To_Compute(app)
                    end
    
                    % Add the file name to the title
                    app.MoussionEnergyUIFigure.Name = ['Moussion Energy - ' name];
    
                    % Plot initial image
                    app.frame_number = app.face.Movie.InitialFrame;
                    app.image = imshow(app.movie(:,:,app.frame_number),'Parent',app.ImageAxes,...
                        'InitialMagnification','fit');
                    axis(app.ImageAxes,'tight')

                    % Add ROIs
                    Add_ROIs(app)
    
                    % Set limits to controls
                    app.FrameSpinner.Limits = [1 app.prop.frames];
                    app.FrameSlider.Limits = [1 app.prop.frames];
                    app.InitialFrameSpinner.Limits = [1 app.face.Movie.FinalFrame-1];
                    app.FinalFrameSpinner.Limits = [app.face.Movie.InitialFrame+1 app.prop.frames];
                    
                    % Initialize control properties
                    app.MovieDropDown.Value = 'Movie';
                    app.SetSettingsDropDown.Value = '-- none --';
                    app.SetSettingsDropDown.BackgroundColor = [0.96 0.96 0.96];
                    app.FPSSpinner.Value = app.face.Movie.FPS;
                    app.SmoothingSpinner.Value = app.face.Movie.Smoothing;
                    app.FrameSpinner.Value = app.frame_number;
                    app.FrameSlider.Value = app.frame_number;
                    app.FrameSpinner.Enable = 'on';
                    app.FrameSlider.Enable = 'on';
                    app.InitialFrameSpinner.Value = app.face.Movie.InitialFrame;
                    app.FinalFrameSpinner.Value = app.face.Movie.FinalFrame ;
                    app.SettingsPanel.Enable = 'on';
                    app.MoviePanel.Enable = 'on';
                    app.EnergyPanel.Enable = 'on';

                    % Plot signals
                    app.line_ROI = drawline(app.EnergyAxes,'Color',[0 0 0],...
                        'Position',[[app.frame_number app.frame_number];...
                        app.EnergyAxes.YLim]','InteractionsAllowed','none','LineWidth',1);
                    Update_Plot(app)
                    Set_Label_Time(app.prop.frames,app.face.Movie.FPS,app.InitialFrameSpinner.Value,app.EnergyAxes)
                    
                    % Change control properties
                    app.LoadVideoButton.BackgroundColor = [0.5 1 0.5];
                    app.LoadVideoButton.Text = 'Loaded!';
                    app.LoadVideoButton.Enable = 'off';
                else
                    % Change control properties
                    app.LoadVideoButton.BackgroundColor = [1 0.5 0.5];
                    app.LoadVideoButton.Text = 'File inexistent!';
                end
            else
                % Change control properties
                app.LoadVideoButton.BackgroundColor = [1 0.5 0.5];
                app.LoadVideoButton.Text = 'File incompatible!';
                app.MoussionEnergyUIFigure.Name = 'Moussion Energy';
            end
        end

        % Callback function: EnergyAxes, FrameSlider, FrameSpinner, 
        % ...and 1 other component
        function FrameValueChanging(app, event)

            if isa(event.Source,'matlab.ui.control.UIAxes')
                app.frame_number = round(event.Source.CurrentPoint(1));
            elseif isa(event.Source,'matlab.ui.Figure')
                if ~isempty(app.movie)
                    switch event.Key
                        case 'rightarrow'
                            if app.frame_number<app.prop.frames
                                app.frame_number = app.frame_number+1;
                            else
                                return
                            end
                        case 'leftarrow'
                            if app.frame_number>1
                                app.frame_number = app.frame_number-1;
                            else
                                return
                            end
                    end
                else
                    return
                end
            else
                app.frame_number = round(event.Value);
            end
            
            app.FrameSlider.Value = app.frame_number;
            app.FrameSpinner.Value = app.frame_number;
            Update_Image(app)

            % Place line ROI
            app.line_ROI.delete()
            app.line_ROI = drawline(app.EnergyAxes,'Color',[0 0 0],...
                    'Position',[[app.frame_number app.frame_number];...
                    app.EnergyAxes.YLim]','InteractionsAllowed','none','LineWidth',1);

            % Change to Movie images
            if ~strcmp(app.MovieDropDown.Value,'Movie')
                app.MovieDropDown.Value = 'Movie';
                app.FrameSlider.Enable = 'on';
                app.FrameSpinner.Enable = 'on';
            end
        end

        % Value changed function: InitialFrameSpinner
        function InitialFrameSpinnerValueChanged(app, event)
            % Read value
            value = app.InitialFrameSpinner.Value;

            % Set initial frame
            app.face.Movie.InitialFrame = value;
            app.FrameSpinner.Value = value;
            app.FrameSlider.Value = value;
            app.frame_number = value;

            % Change control limits
            app.FinalFrameSpinner.Limits(1) = app.InitialFrameSpinner.Value+1;
            
            % Update current image and plot
            Update_Image(app)
            Update_Plot(app)
        end

        % Value changed function: FinalFrameSpinner
        function FinalFrameSpinnerValueChanged(app, event)
            % Read value
            value = app.FinalFrameSpinner.Value;

            % Set final frame
            app.face.Movie.FinalFrame = value;
            app.FrameSpinner.Value = value;
            app.FrameSlider.Value = value;
            app.frame_number = value;

            % Change control limits
            app.InitialFrameSpinner.Limits(2) = app.FinalFrameSpinner.Value-1;

            % Update current image and plot
            Update_Image(app)
            Update_Plot(app)
        end

        % Value changed function: FPSSpinner
        function FPSSpinnerValueChanged(app, event)
            % read value
            app.face.Movie.FPS = app.FPSSpinner.Value;
            
            % Set time
            Set_Label_Time(app.prop.frames,app.face.Movie.FPS,app.InitialFrameSpinner.Value,app.EnergyAxes)
        end

        % Drop down opening function: SetSettingsDropDown
        function SetSettingsDropDownOpening(app, event)
            data_strings = evalin('base','who');
            set(app.SetSettingsDropDown,'items',[{'-- none --'};data_strings])
        end

        % Value changed function: SetSettingsDropDown
        function SetSettingsDropDownValueChanged(app, event)
            name = app.SetSettingsDropDown.Value;
            
            if strcmp(name,'-- none --')
                app.SetSettingsDropDown.BackgroundColor = [0.96 0.96 0.96];
            else
                % Check if variable exist
                if evalin('base',['exist(''' name ''',''var'')'])
                    
                    % Read workspace variable
                    face_settings = evalin('base',name);

                    if isfield(face_settings,'Eye')
                        % Get ROIs data
                        app.face.Eye.ROI = face_settings.Eye.ROI;
                        app.face.Nose.ROI = face_settings.Nose.ROI;
                        app.face.Whiskers.ROI = face_settings.Whiskers.ROI;
                        
                        % ROIs to image
                        app.eye_ROI.delete;
                        app.nose_ROI.delete;
                        app.whiskers_ROI.delete;
    
                        % Add ROIs
                        Add_ROIs(app)
    
                        % Set control values
                        app.face.Movie.FPS = face_settings.Movie.FPS;
                        app.FPSSpinner.Value = app.face.Movie.FPS;
                        app.face.Movie.Smoothing = face_settings.Movie.Smoothing;
                        app.SmoothingSpinner.Value = app.face.Movie.Smoothing;
    
                        % Need to compute again
                        Need_To_Compute(app)
                        app.SetSettingsDropDown.BackgroundColor = [0.5 1 0.5];
                    else
                        app.SetSettingsDropDown.BackgroundColor = [1 0.5 0.5];
                    end
                end
            end
        end

        % Value changed function: SmoothingSpinner
        function SmoothingSpinnerValueChanged(app, event)
            % Add changing value
            app.face.Movie.Smoothing = app.SmoothingSpinner.Value;
            app.smoothing_changed = true;
            Need_To_Compute(app)
        end

        % Value changed function: EyeCheckBox, NoseCheckBox, 
        % ...and 1 other component
        function EnergyCheckBoxValueChanged(app, event)
            Update_Plot(app)
        end

        % Button pushed function: SaveResultsButton
        function SaveResultsButtonPushed(app, event)
            assignin('base',['face_' app.face.Movie.Name],app.face)
            eval(['face_' app.face.Movie.Name '=app.face;']);

            % Save file
            file_path = fileparts(app.face.Movie.FilePath);
            save([file_path filesep app.face.Movie.Name '_face'],['face_' app.face.Movie.Name],'-v7.3')

            % Change control properties
            app.SaveResultsButton.BackgroundColor = [0.5 1 0.5];
            app.SaveResultsButton.Text = 'Saved!';
            app.SaveResultsButton.Enable = 'off';
        end

        % Value changing function: FileEditField
        function FileEditFieldValueChanging(app, event)
            app.LoadVideoButton.BackgroundColor = [0.96 0.96 0.96];
            app.LoadVideoButton.Text = 'Load video';
            app.LoadVideoButton.Enable = 'on';
        end

        % Button pushed function: ComputeMotionEnergyButton
        function ComputeMotionEnergyButtonPushed(app, event)
            % Change control properties
            app.ComputeMotionEnergyButton.BackgroundColor = [1 1 0.5];
            app.ComputeMotionEnergyButton.Text = 'Computing...';
            drawnow

            % Compute motion energy and intensity
            if app.eye_ROI_changed || app.smoothing_changed || isempty(app.face.Eye.Energy)
                % Compute motion energy
                app.face.Eye.Energy = Motion_Energy(app.movie,app.eye_ROI.createMask);
                app.face.Eye.EnergySmoothed = smooth(app.face.Eye.Energy,app.SmoothingSpinner.Value);

                % Compute intensity
                app.face.Eye.Intensity = Movie_Intensity(app.movie,app.eye_ROI.createMask);
                app.face.Eye.IntensitySmoothed = smooth(app.face.Eye.Intensity,app.SmoothingSpinner.Value);

                % Detect blinking
                th_1 = mean(app.face.Eye.Energy)+3*std(app.face.Eye.Energy);
                app.face.Blinking = Find_Spikes(app.face.Eye.Energy,th_1);
                th_2 = mean(app.face.Eye.EnergySmoothed)+3*std(app.face.Eye.EnergySmoothed);
                smoothed_above = app.face.Eye.EnergySmoothed>th_2;
                app.face.Blinking = app.face.Blinking&smoothed_above;

                % Set flag
                app.eye_ROI_changed = false;
            end
            if app.nose_ROI_changed || app.smoothing_changed || isempty(app.face.Nose.Energy)
                % Compute motion energy
                app.face.Nose.Energy = Motion_Energy(app.movie,app.nose_ROI.createMask);
                app.face.Nose.EnergySmoothed = smooth(app.face.Nose.Energy,app.SmoothingSpinner.Value);
    
                % Compute intensity
                app.face.Nose.Intensity = Movie_Intensity(app.movie,app.nose_ROI.createMask);
                app.face.Nose.IntensitySmoothed = smooth(app.face.Nose.Intensity,app.SmoothingSpinner.Value);

                % Detect sniffing
                th = mean(app.face.Nose.Intensity)-2*std(app.face.Nose.Intensity);
                app.face.Sniffing = app.face.Nose.Intensity<th;

                % Set flag
                app.nose_ROI_changed = false;
            end
            if app.whisker_ROI_changed || app.smoothing_changed || isempty(app.face.Whiskers.Energy)
                % Compute motion energy
                app.face.Whiskers.Energy = Motion_Energy(app.movie,app.whiskers_ROI.createMask);
                app.face.Whiskers.EnergySmoothed = smooth(app.face.Whiskers.Energy,app.SmoothingSpinner.Value);

                % Compute intensity
                app.face.Whiskers.Intensity = Movie_Intensity(app.movie,app.whiskers_ROI.createMask);
                app.face.Whiskers.IntensitySmoothed = smooth(app.face.Whiskers.Intensity,app.SmoothingSpinner.Value);

                % Set flag
                app.whisker_ROI_changed = false;
            end
            app.smoothing_changed = false;

            % Update plots
            Update_Plot(app)

            % Set time
            Set_Label_Time(app.prop.frames,app.face.Movie.FPS,app.InitialFrameSpinner.Value,app.EnergyAxes)

            % Change control properties
            app.ComputeMotionEnergyButton.BackgroundColor = [0.5 1 0.5];
            app.ComputeMotionEnergyButton.Text = {'Motion energy','computed!'};
            app.ComputeMotionEnergyButton.Enable = 'off';
        end

        % Value changed function: RecordingLimitsSwitch
        function RecordingLimitsSwitchValueChanged(app, event)
            value = app.RecordingLimitsSwitch.Value;
            switch value
                case 'Auto'
                    app.InitialFrameSpinner.Enable = 'off';
                    app.FinalFrameSpinner.Enable = 'off';
                    app.InitialFrameSpinner.Value = app.face.Movie.InitialFrameAuto;
                    app.FinalFrameSpinner.Value = app.face.Movie.FinalFrameAuto;
                    InitialFrameSpinnerValueChanged(app)
                    FinalFrameSpinnerValueChanged(app)
                case 'Manual'
                    app.InitialFrameSpinner.Enable = 'on';
                    app.FinalFrameSpinner.Enable = 'on';
            end
        end

        % Value changed function: PlotRawSwitch
        function PlotRawSwitchValueChanged(app, event)
            switch event.Value
                case 'Raw'
                    app.plot_raw = true;
                case 'Smoothed'
                    app.plot_raw = false;
            end    
            Update_Plot(app)
        end

        % Value changed function: PlotEnergySwitch
        function PlotEnergySwitchValueChanged(app, event)
            switch event.Value
                case 'Energy'
                    app.plot_energy = true;
                    app.EnergyAxes.Title.String = 'Motion energy';
                    app.EnergyAxes.YLabel.String = {'average energy';'|\Deltaintensity|'};
                case 'Intensity'
                    app.plot_energy = false;
                    app.EnergyAxes.Title.String = 'Pixel intensity';
                    app.EnergyAxes.YLabel.String = 'average intensity';
            end    
            Update_Plot(app)
        end

        % Value changed function: MovieDropDown
        function MovieDropDownValueChanged(app, event)
            switch app.MovieDropDown.Value
                case 'Average'
                    app.image.CData = app.face.Movie.AverageImage;
                    app.FrameSlider.Enable = 'off';
                    app.FrameSpinner.Enable = 'off';
                case 'Minimum'
                    app.image.CData = app.face.Movie.MinImage;
                    app.FrameSlider.Enable = 'off';
                    app.FrameSpinner.Enable = 'off';
                case 'Maximum'
                    app.image.CData = app.face.Movie.MaxImage;
                    app.FrameSlider.Enable = 'off';
                    app.FrameSpinner.Enable = 'off';
                otherwise
                    app.image.CData = app.movie(:,:,app.frame_number);
                    app.FrameSlider.Enable = 'on';
                    app.FrameSpinner.Enable = 'on';
            end
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create MoussionEnergyUIFigure and hide until all components are created
            app.MoussionEnergyUIFigure = uifigure('Visible', 'off');
            app.MoussionEnergyUIFigure.Position = [100 100 820 750];
            app.MoussionEnergyUIFigure.Name = 'Moussion Energy';
            app.MoussionEnergyUIFigure.KeyPressFcn = createCallbackFcn(app, @FrameValueChanging, true);

            % Create PathPanel
            app.PathPanel = uipanel(app.MoussionEnergyUIFigure);
            app.PathPanel.Title = 'Movie file';
            app.PathPanel.Position = [10 677 800 60];

            % Create FileButton
            app.FileButton = uibutton(app.PathPanel, 'push');
            app.FileButton.ButtonPushedFcn = createCallbackFcn(app, @FileButtonPushed, true);
            app.FileButton.Position = [11 6 28 22];
            app.FileButton.Text = '...';

            % Create FileEditField
            app.FileEditField = uieditfield(app.PathPanel, 'text');
            app.FileEditField.ValueChangingFcn = createCallbackFcn(app, @FileEditFieldValueChanging, true);
            app.FileEditField.Position = [48 6 587 22];

            % Create LoadVideoButton
            app.LoadVideoButton = uibutton(app.PathPanel, 'push');
            app.LoadVideoButton.ButtonPushedFcn = createCallbackFcn(app, @LoadVideoButtonPushed, true);
            app.LoadVideoButton.Position = [644 6 145 23];
            app.LoadVideoButton.Text = 'Load video';

            % Create MoviePanel
            app.MoviePanel = uipanel(app.MoussionEnergyUIFigure);
            app.MoviePanel.Enable = 'off';
            app.MoviePanel.Title = 'Movie';
            app.MoviePanel.Position = [11 249 595 419];

            % Create ImageAxes
            app.ImageAxes = uiaxes(app.MoviePanel);
            title(app.ImageAxes, 'Place eye, nose, and whiskers ROIs')
            app.ImageAxes.XTick = [];
            app.ImageAxes.YTick = [];
            app.ImageAxes.ZTick = [];
            app.ImageAxes.Color = 'none';
            app.ImageAxes.Box = 'on';
            app.ImageAxes.Position = [9 54 572 329];

            % Create FrameSlider
            app.FrameSlider = uislider(app.MoviePanel);
            app.FrameSlider.Limits = [1 100];
            app.FrameSlider.MajorTicks = [];
            app.FrameSlider.MajorTickLabels = {''};
            app.FrameSlider.ValueChangingFcn = createCallbackFcn(app, @FrameValueChanging, true);
            app.FrameSlider.MinorTicks = [];
            app.FrameSlider.Position = [13 24 442 3];
            app.FrameSlider.Value = 1;

            % Create frameSpinnerLabel
            app.frameSpinnerLabel = uilabel(app.MoviePanel);
            app.frameSpinnerLabel.HorizontalAlignment = 'right';
            app.frameSpinnerLabel.Position = [547 13 36 22];
            app.frameSpinnerLabel.Text = 'frame';

            % Create FrameSpinner
            app.FrameSpinner = uispinner(app.MoviePanel);
            app.FrameSpinner.ValueChangingFcn = createCallbackFcn(app, @FrameValueChanging, true);
            app.FrameSpinner.Limits = [1 Inf];
            app.FrameSpinner.ValueDisplayFormat = '%.0f';
            app.FrameSpinner.Position = [468 13 72 22];
            app.FrameSpinner.Value = 1;

            % Create MovieDropDown
            app.MovieDropDown = uidropdown(app.MoviePanel);
            app.MovieDropDown.Items = {'Movie', 'Average', 'Minimum', 'Maximum'};
            app.MovieDropDown.ValueChangedFcn = createCallbackFcn(app, @MovieDropDownValueChanged, true);
            app.MovieDropDown.Position = [8 370 142 22];
            app.MovieDropDown.Value = 'Movie';

            % Create SettingsPanel
            app.SettingsPanel = uipanel(app.MoussionEnergyUIFigure);
            app.SettingsPanel.Enable = 'off';
            app.SettingsPanel.Title = 'Settings';
            app.SettingsPanel.Position = [615 249 196 419];

            % Create samplingperiodmsLabel
            app.samplingperiodmsLabel = uilabel(app.SettingsPanel);
            app.samplingperiodmsLabel.HorizontalAlignment = 'right';
            app.samplingperiodmsLabel.Position = [64 290 25 22];
            app.samplingperiodmsLabel.Text = 'fps';

            % Create FPSSpinner
            app.FPSSpinner = uispinner(app.SettingsPanel);
            app.FPSSpinner.Limits = [1 Inf];
            app.FPSSpinner.ValueChangedFcn = createCallbackFcn(app, @FPSSpinnerValueChanged, true);
            app.FPSSpinner.HorizontalAlignment = 'center';
            app.FPSSpinner.Position = [103 290 70 22];
            app.FPSSpinner.Value = 30;

            % Create initialLabel
            app.initialLabel = uilabel(app.SettingsPanel);
            app.initialLabel.HorizontalAlignment = 'right';
            app.initialLabel.Position = [21 163 67 22];
            app.initialLabel.Text = 'initial frame';

            % Create InitialFrameSpinner
            app.InitialFrameSpinner = uispinner(app.SettingsPanel);
            app.InitialFrameSpinner.Limits = [1 Inf];
            app.InitialFrameSpinner.ValueDisplayFormat = '%.0f';
            app.InitialFrameSpinner.ValueChangedFcn = createCallbackFcn(app, @InitialFrameSpinnerValueChanged, true);
            app.InitialFrameSpinner.Position = [103 163 70 22];
            app.InitialFrameSpinner.Value = 1;

            % Create finalLabel
            app.finalLabel = uilabel(app.SettingsPanel);
            app.finalLabel.HorizontalAlignment = 'right';
            app.finalLabel.Position = [27 133 61 22];
            app.finalLabel.Text = 'final frame';

            % Create FinalFrameSpinner
            app.FinalFrameSpinner = uispinner(app.SettingsPanel);
            app.FinalFrameSpinner.Limits = [1 Inf];
            app.FinalFrameSpinner.ValueDisplayFormat = '%.0f';
            app.FinalFrameSpinner.ValueChangedFcn = createCallbackFcn(app, @FinalFrameSpinnerValueChanged, true);
            app.FinalFrameSpinner.Position = [103 133 70 22];
            app.FinalFrameSpinner.Value = 1;

            % Create FromworkspaceLabel
            app.FromworkspaceLabel = uilabel(app.SettingsPanel);
            app.FromworkspaceLabel.Position = [13 355 167 22];
            app.FromworkspaceLabel.Text = 'Load settings from workspace';

            % Create SetSettingsDropDown
            app.SetSettingsDropDown = uidropdown(app.SettingsPanel);
            app.SetSettingsDropDown.Items = {'-- none --'};
            app.SetSettingsDropDown.DropDownOpeningFcn = createCallbackFcn(app, @SetSettingsDropDownOpening, true);
            app.SetSettingsDropDown.ValueChangedFcn = createCallbackFcn(app, @SetSettingsDropDownValueChanged, true);
            app.SetSettingsDropDown.Position = [13 328 170 22];
            app.SetSettingsDropDown.Value = '-- none --';

            % Create samplingperiodmsLabel_2
            app.samplingperiodmsLabel_2 = uilabel(app.SettingsPanel);
            app.samplingperiodmsLabel_2.HorizontalAlignment = 'right';
            app.samplingperiodmsLabel_2.Position = [28 262 62 22];
            app.samplingperiodmsLabel_2.Text = 'smoothing';

            % Create SmoothingSpinner
            app.SmoothingSpinner = uispinner(app.SettingsPanel);
            app.SmoothingSpinner.Limits = [1 Inf];
            app.SmoothingSpinner.ValueDisplayFormat = '%.0f';
            app.SmoothingSpinner.ValueChangedFcn = createCallbackFcn(app, @SmoothingSpinnerValueChanged, true);
            app.SmoothingSpinner.HorizontalAlignment = 'center';
            app.SmoothingSpinner.Position = [103 262 70 22];
            app.SmoothingSpinner.Value = 30;

            % Create SaveResultsButton
            app.SaveResultsButton = uibutton(app.SettingsPanel, 'push');
            app.SaveResultsButton.ButtonPushedFcn = createCallbackFcn(app, @SaveResultsButtonPushed, true);
            app.SaveResultsButton.FontSize = 18;
            app.SaveResultsButton.Position = [13 13 170 30];
            app.SaveResultsButton.Text = 'Save results';

            % Create ComputeMotionEnergyButton
            app.ComputeMotionEnergyButton = uibutton(app.SettingsPanel, 'push');
            app.ComputeMotionEnergyButton.ButtonPushedFcn = createCallbackFcn(app, @ComputeMotionEnergyButtonPushed, true);
            app.ComputeMotionEnergyButton.FontSize = 18;
            app.ComputeMotionEnergyButton.Position = [13 54 170 62];
            app.ComputeMotionEnergyButton.Text = {'Compute'; 'motion energy'};

            % Create RecordinglimitsSwitchLabel
            app.RecordinglimitsSwitchLabel = uilabel(app.SettingsPanel);
            app.RecordinglimitsSwitchLabel.HorizontalAlignment = 'center';
            app.RecordinglimitsSwitchLabel.Position = [59 215 91 22];
            app.RecordinglimitsSwitchLabel.Text = 'Recording limits';

            % Create RecordingLimitsSwitch
            app.RecordingLimitsSwitch = uiswitch(app.SettingsPanel, 'slider');
            app.RecordingLimitsSwitch.Items = {'Manual', 'Auto'};
            app.RecordingLimitsSwitch.ValueChangedFcn = createCallbackFcn(app, @RecordingLimitsSwitchValueChanged, true);
            app.RecordingLimitsSwitch.Position = [82 191 45 20];
            app.RecordingLimitsSwitch.Value = 'Manual';

            % Create EnergyPanel
            app.EnergyPanel = uipanel(app.MoussionEnergyUIFigure);
            app.EnergyPanel.Enable = 'off';
            app.EnergyPanel.Title = 'Motion plots';
            app.EnergyPanel.BackgroundColor = [1 1 1];
            app.EnergyPanel.Position = [10 15 800 225];

            % Create EnergyAxes
            app.EnergyAxes = uiaxes(app.EnergyPanel);
            title(app.EnergyAxes, 'Motion energy')
            xlabel(app.EnergyAxes, 'time (frame #)')
            ylabel(app.EnergyAxes, {'average energy'; '|\Deltaintesity|'})
            app.EnergyAxes.ButtonDownFcn = createCallbackFcn(app, @FrameValueChanging, true);
            app.EnergyAxes.Position = [10 10 780 160];

            % Create EyeCheckBox
            app.EyeCheckBox = uicheckbox(app.EnergyPanel);
            app.EyeCheckBox.ValueChangedFcn = createCallbackFcn(app, @EnergyCheckBoxValueChanged, true);
            app.EyeCheckBox.Text = 'Eye';
            app.EyeCheckBox.FontColor = [1 0 0];
            app.EyeCheckBox.Position = [379 180 42 22];
            app.EyeCheckBox.Value = true;

            % Create NoseCheckBox
            app.NoseCheckBox = uicheckbox(app.EnergyPanel);
            app.NoseCheckBox.ValueChangedFcn = createCallbackFcn(app, @EnergyCheckBoxValueChanged, true);
            app.NoseCheckBox.Text = 'Nose';
            app.NoseCheckBox.FontColor = [0.3922 0.8314 0.0745];
            app.NoseCheckBox.Position = [432 180 50 22];
            app.NoseCheckBox.Value = true;

            % Create WhiskerCheckBox
            app.WhiskerCheckBox = uicheckbox(app.EnergyPanel);
            app.WhiskerCheckBox.ValueChangedFcn = createCallbackFcn(app, @EnergyCheckBoxValueChanged, true);
            app.WhiskerCheckBox.Text = 'Whiskers';
            app.WhiskerCheckBox.FontColor = [0.0745 0.6235 1];
            app.WhiskerCheckBox.Position = [493 180 71 22];
            app.WhiskerCheckBox.Value = true;

            % Create PlotRawSwitch
            app.PlotRawSwitch = uiswitch(app.EnergyPanel, 'slider');
            app.PlotRawSwitch.Items = {'Raw', 'Smoothed'};
            app.PlotRawSwitch.ValueChangedFcn = createCallbackFcn(app, @PlotRawSwitchValueChanged, true);
            app.PlotRawSwitch.Position = [248 181 45 20];
            app.PlotRawSwitch.Value = 'Raw';

            % Create PlotEnergySwitch
            app.PlotEnergySwitch = uiswitch(app.EnergyPanel, 'slider');
            app.PlotEnergySwitch.Items = {'Energy', 'Intensity'};
            app.PlotEnergySwitch.ValueChangedFcn = createCallbackFcn(app, @PlotEnergySwitchValueChanged, true);
            app.PlotEnergySwitch.Position = [49 179 45 20];
            app.PlotEnergySwitch.Value = 'Energy';

            % Show the figure after all components are created
            app.MoussionEnergyUIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = MoussionEnergy

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.MoussionEnergyUIFigure)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.MoussionEnergyUIFigure)
        end
    end
end