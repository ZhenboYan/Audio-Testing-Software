%% Communicate with Arduino IDE
% fclose(s);
% clear all
% clc
% portName = '/dev/cu.usbmodem14501';
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
%% Looping it through, plot, and play sound;
tic
% chirpFs = 48000;                             % Sampling Frequency (Hz)
% chirp_duration = 10;                               % Duration (sec)
chirpt = linspace(0, chirp_duration, chirp_duration*chirpFs);
% chirpf0 =   20;                          %starting frequency
% chirpf1 = 24000;                         %ending frequency
chirpx = chirp(chirpt,chirpf0,chirpt(end),chirpf1);
% at time 0 sec the frequency is 20, at time chirp_duration sec the frequency is 24k
% frequency increment per second is (24000 - 20) / chirpt
% frequency increment per second is about 2398 when chirpt is 10 sec
% sound_level = 0.1;
% sound_level_increment = 0.05;
sound_iteration = 0;
sound_flag = true;
% number_of_iteration = 10;
i = 0;
stop_time = number_of_iteration * chirp_duration; % stop time in sec, choose multipliers of chirp_duration

while toc < stop_time
    toc_int = int8(toc);
    increase_volume_iteration = mod(toc_int,chirp_duration+1);
    
    if increase_volume_iteration == 2 % after passing 2 seconds unlock sound flag
        sound_flag = true;
    end    
    
    if increase_volume_iteration == 0
        if sound_flag
            SoundVolume(sound_level);
            sound(chirpx, chirpFs);
            sound_level = sound_level + sound_level_increment
            sound_iteration = sound_iteration + 1;
            sound_flag = false;
            sound_iteration
        end
    end
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
increment_freq_time = (chirpf1 - chirpf0) / chirp_duration;
mod_time_duration = mod(time,chirp_duration);
frequency_at_time = chirpf0 + (increment_freq_time * mod_time_duration);
sample = 2;  % set graphing rate when is 10 it updates every 1 second
yMax  = 125; %y Maximum Value in dB
yMin  = 25;  %y minimum Value in dB
forward_offset = 2; % Space between the graph and right side end of the screen
backward_offset = 10; % Space between the graph and left side end of the screen
