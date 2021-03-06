function [] = testdepth ()
clear
clc
imaqreset;
%[240 160 150 150]
%rec = input('Input a position of a rectangle [a b c d] : \n');
%rec = [240 160 200 200];


%create figure to contain buttons/axes
    window=figure('Color',[1 1 1],'Name','Test Depth Detection',...
                  'DockControl','off','Units','Pixels',...
                  'toolbar','none',...
                  'Position',[200 100 1000 500]);
         
         %create start button which calls the startbCallback fctn
    startb=uicontrol('Parent',window,'Style','pushbutton','String',...
                        'Start',...
                        'FontSize',10,...
                        'Units','normalized',...
                        'Position',[0.1 0.05 0.15 0.03],...
                        'Callback',@startbCallback);
    %create stop button which calls the stopbCallback fctn
    stopb=uicontrol('Parent',window,'Style','pushbutton','String',...
                        'Stop',...
                        'FontSize',10,...
                        'Units','normalized',...
                        'Position',[0.75 0.05 0.15 0.03],...
                        'Callback',@stopbCallback);
  
    colorVid = videoinput('kinect',1);
    depthVid = videoinput('kinect',2);
    triggerconfig([colorVid depthVid],'manual');
    colorVid.FramesPerTrigger = 1;
    depthVid.FramesPerTrigger = 1;
    colorVid.TriggerRepeat = inf;       
    depthVid.TriggerRepeat = inf;  
    Fs = 20; 				% Number of frames per second
    t = timer('TimerFcn',@trig, 'Period', 1/Fs,...
        'executionMode','fixedRate');                      
    start(depthVid);
    trigger(depthVid);
    [de, timede, metade] = getdata(depthVid);
    y = thresdepth(de);
    stop(depthVid);
    
    % Variables for realtime plots
    time_range = 3; 							% second
	timepoints = Fs*time_range; 			% number of points in 1 range of time
	timeShift = 0;
	
	time = zeros(1,  timepoints);			% XData for x axis of plot
    k1 = zeros(1, timepoints);				% YData for y axis of plot
	k2 = zeros(1, timepoints);			
	ind = 1;										% index of iterating frames
	
	% Initialize a plot
	h_axes3 = subplot(1,3,3);
	h_plot1 = plot(1:timepoints, zeros(1,timepoints));
	h_line = line([0 0], [-5 10], 'Color', [1 0.5 0.5], 'LineWidth', 2);	% Vertical line to track the current point being plotted
	
  function startbCallback(hobj,event) 
         start([colorVid depthVid]);%open object
         start(t)%open object
  end

    function stopbCallback(hobj,event)
         stop(t)%close object
         stop([colorVid depthVid]);%close object
    end                  



function trig(hobj,event)

    % ---------- Automatically adjust horizontal axes -----
	if ind == timepoints;
		ind = 1;
		timeShift = timeShift + time_range;
		set(h_axes3, 'xtick', [0:Fs:time_range*Fs], 'xticklabel', [timeShift:(timeShift+time_range)]);
	end
	
	% --------------- Import data -----------------------
    trigger([colorVid depthVid]);
    cl = getdata(colorVid);
    [de, timede, metade] = getdata(depthVid);
    [I,new] = mindepth(de,200,y);
    %I1 = ycbcr(cl);
    %I2 = kovac(cl);
    %k1 = [k1 new];
    %k2 = [k2 y+0.11];
    %sik = size(k1);
    
    % --------------- Update plot -----------------------
	time(ind) = ind;
	k1(ind) = new;
	%k2(ind) = y + 0.11;
	set(h_plot1, 'XData', time, 'YData', volt);
    set(h_line, 'XData', [ind, ind]);
	ind = ind + 1;		% update index
	
	% --------------- Others -----------------------
    %plot(k1,'r--','linewidth',1);
    %hold on
    %plot(k2,'b--','linewidth',1);
    I3 = ybr(cl);
    %I4 = ybr(cl);
    %I5 = hsv(cl);
    %Ig = I & I2;
    %cl = I1;
    I = I & I3;
     %I2 = medfilt2(I,[5 5]);
     I2 = bwmorph(I,'bridge');
    I2 = imfill(I2,'holes');
    I2 = bwmorph(I2,'open');
    I2 = bwmorph(I2,'close');
%     I2 = medfilt2(I2,[9 9]);
%     I2 = medfilt2(I2,[9 9]);
%    I3 = medfilt2(I,[13 13]);
%     cl = edge(I2,'canny');
%     se90 = strel('line', 3, 90);
%     se0 = strel('line', 3, 0);
%     cl = imdilate(cl, [se90 se0]);
%     cl = imfill(cl, 'holes');
    subplot(1,3,1)
    imshow(de,[0 4096]);
    subplot(1,3,2)
    imshow(I2);
end
end
