%% Communicate with Arduino IDE
% fclose(s);
% clear all
% clc
% portName = '/dev/cu.usbmodem14601';
s=serial(portName,'BaudRate',115200);
fopen(s)

%% Setting up variables
avg = 0;
iteration = 0;
% sample = 3;  % set graphing rate when is 10 it updates every 1 second
% yMax  = 125;                           %y Maximum Value
% yMin  = 25;                            %y minimum Value
delay = 0.000000000000000001;
time = 0;
data = 0;
count = 0;
avgCount = 0;
% forward_offset = 2;
% backward_offset = 10;

%% Set up Plot
plotGraph = plot(time,data,'-m','LineWidth',3);  % every AnalogRead needs to be on its own Plotgraph
plotGrid = 'on';                 % 'off' to turn off grid
title('Arduino SPL reading','FontSize',15);
xlabel('Elapsed Time (s)','FontSize',15);
ylabel('SPL (dBA)','FontSize',15);
hold on                            %hold on makes sure all of the channels are plotted
yline(90,'--r');
yline(floor,'--b');
grid(plotGrid);

%% Looping it through and plot;
% for i=1:n
tic
i = 0;
% stop_time = 5;
while toc < stop_time
    i = i + 1;
    iteration = iteration + 1;
    data(i) = 50 * fscanf(s,'%f');
    avg = avg + data(i);
    if iteration == sample
        count = count + 1;
        time(count) = toc;
        xmax = time(count) + forward_offset;
        xmin = time(count) - backward_offset;
        avgCount = avgCount + 1;
        avg = avg / sample;
        avgData(avgCount) = avg;
        iteration = 0;
        avg = 0;
        set(plotGraph,'XData',time,'YData',avgData);
        axis([xmin xmax yMin yMax]);
        pause(delay);
    end
end
% each iteration in the loop causes between 0.105 second and 0.118 second
fclose(s);
set(plotGraph,'XData',time,'YData',avgData);
axis([1 time(count)+0.5 min(avgData)-3 max(avgData)+3 ]);
average_dB = mean(data)
maximum_db = max(data)
minimum_db = min(data)
time_elapsed = time(count)