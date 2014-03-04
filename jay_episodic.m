function jay_episodic()
clear;
close all;
clc;

global learning_rate;
global gain_oja;
global cycles;
global VALUE;

gain_step = .04;
gain_max = 0.7;

runs = 10;
cycles = 14;
VALUE = [1 1]; %worm, peanut
gain_oja = 0.7;
learning_rate = 0.2;


global pos
global DIR;
global TRIAL_DIR;
DIR = datestr(now);
DIR = strrep(DIR,':',' ');
mkdir(DIR);


pos = 0;
place_responses = zeros(runs, 14);
place_stats = zeros(runs, 2);
filename = horzcat(DIR, '\trial_data', '.mat');

is_disp_weights = true;
% profile on
while gain_oja <= gain_max
    pos = pos+1;

    for i = 1:runs
        TRIAL_DIR = horzcat(DIR, '\', num2str(i),'\');
        mkdir(TRIAL_DIR);
        [place_responses(i,:) side_pref checked_place] = sm_experiment(cycles, ...
            learning_rate, gain_oja, is_disp_weights);
        checked_places{i} = checked_place;
        place_stats(i,:) = mean(side_pref);
        is_disp_weights = false;
        message = horzcat('trial ', num2str(i), ' complete');
        disp(message);
    end

    trials{pos} = {gain_oja, mean(place_stats(:,2)), mean(place_stats(:,1)), ...
        place_responses, place_stats, checked_places};
    save(filename,'trials', 'VALUE');
    
    gain_oja = gain_oja + gain_step;
end
% profile viewer
% profile off
end

% lr_step = .01;
% lr_max = .05;
% 
% cycles_step = 1;
% cycles_max = 120;

