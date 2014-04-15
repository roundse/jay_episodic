function [avg_checks side_pref checked_places first_checked] = bg_experiment(cycles, ... 
    hpc_learning_rate, pfc_learning_rate, gain_oja, is_disp_weights)

global INP_STR;
global GAIN;
GAIN = 5;


%%% NEW (4/8/14) %%%%%
global PFC_SIZE;
PFC_SIZE = 250;
%%%%%%%%%%%%%%%%%%%%%%%

global HPC_SIZE;
HPC_SIZE = 250;                 % 2 x 14 possible combinations multipled
                                % by 10 for random connectivity of 10%
global FOOD_CELLS;
global PLACE_CELLS;
FOOD_CELLS = 2;
PLACE_CELLS = 14;

EXT_CONNECT = .2;                   % Chance of connection = 20%
INT_CONNECT = .2;

global VALUE;

global worm;
global peanut;
worm = 1;
peanut = 2;

global PEANUT;
global WORM;
WORM =  [-1,  1];
PEANUT =[ 1, -1];

global place;
place = zeros(length(PEANUT), PLACE_CELLS);

% Weight initialization
global w_food_to_hpc;
global w_place_to_hpc;
global w_hpc_to_food;
global w_hpc_to_place;
global w_hpc_to_hpc;

%%%% NEW WEIGHTS (4/8/14) %%%%
global w_food_to_place;
global w_place_to_food;

global w_pfc_to_hpc;

global w_food_to_pfc;
global w_place_to_pfc;
global w_pfc_to_food;
global w_pfc_to_place;

global pfc_in_queue;
global pfc_weight_queue;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global w_food_to_food;
global w_food_in;

global hpc_in_queue;
global hpc_weight_queue;
global food_in_queue;
global food_weight_queue;

global place_in_queue;
global place_weight_queue;

global hpc_responses_to_place;
global pfc_responses_to_place;

global is_learning;
is_learning = 1;

place_in_queue = {};
place_weight_queue = {};

hpc_in_queue = {};
hpc_weight_queue = {};

pfc_in_queue = {};
pfc_weight_queue = {};

food_in_queue = {};
food_weight_queue = {};

w_food_in = eye(FOOD_CELLS);
w_food_to_food = zeros(FOOD_CELLS);

w_food_to_hpc = 0.5 .* (rand(FOOD_CELLS, HPC_SIZE) < EXT_CONNECT);
w_hpc_to_food = - w_food_to_hpc';
w_place_to_hpc = 0.5 .* (rand(PLACE_CELLS, HPC_SIZE) < EXT_CONNECT);
w_hpc_to_place =  - w_place_to_hpc';

%%%% ADDING IN THE NEW WEIGHTS (4/8/14)
w_food_to_place = 0.5 .* ones(FOOD_CELLS, PLACE_CELLS);
w_place_to_food = w_food_to_place';
w_food_to_pfc = 0.5 .* (rand(FOOD_CELLS, PFC_SIZE) < EXT_CONNECT);
w_pfc_to_food = w_food_to_pfc';
w_place_to_pfc = 0.5 .* (rand(PLACE_CELLS, PFC_SIZE) < EXT_CONNECT);
w_pfc_to_place = w_place_to_pfc';
w_pfc_to_hpc = -.03 .* ones(PFC_SIZE, HPC_SIZE);

global w_pfc_to_place_init;
global w_place_to_pfc_init;
w_pfc_to_place_init = w_pfc_to_place;
w_place_to_pfc_init = w_place_to_pfc;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


global w_hpc_to_place_init;
global w_place_to_hpc_init;

w_hpc_to_hpc = 0 .* (rand(HPC_SIZE, HPC_SIZE) < INT_CONNECT);
w_hpc_to_place_init = w_hpc_to_place;
w_place_to_hpc_init = w_place_to_hpc;

global pfc;
global hpc;
global place_region;
global food;

% duration of consolidation
global consolidation_length;

pfc = zeros(cycles, PFC_SIZE);
hpc = zeros(cycles, HPC_SIZE);
food = zeros(cycles, FOOD_CELLS);
place_region = zeros(cycles, PLACE_CELLS);
hpc_responses_to_place = zeros(PLACE_CELLS, HPC_SIZE);
pfc_responses_to_place = zeros(PLACE_CELLS, HPC_SIZE);

global PLACE_SLOTS;

PLACE_SLOTS = zeros(PLACE_CELLS);

PLACE_STR = 0.4;

side1 = 1*(rand(1, PLACE_CELLS) < PLACE_STR/2);

side2 = 1*(rand(1, PLACE_CELLS) < PLACE_STR/2);

% Food is pre-stored.
for i = 1:PLACE_CELLS
    if i <= 7
        place(:,i) = WORM;
        PLACE_SLOTS(i,:) = 1*(rand(1, PLACE_CELLS) < PLACE_STR) + side1 - side2;
    else
        place(:,i) = PEANUT;
        PLACE_SLOTS(i,:) = 1*(rand(1, PLACE_CELLS) < PLACE_STR) - side1 + side2;
    end
end

place = place';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Task 1: Pre-store food in place slots
%         Have agent recover foods from places to learn food/place
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% given food without value
stored_val = VALUE;
VALUE = [1 1];
value = 1;


activity1 = 0;
activity2 = 0;
for k=1:1
    place_order = randperm(PLACE_CELLS);

    for j = 1:PLACE_CELLS % recover from all slots
        i = place_order(j);

        [fpa sum1(j) sum2(j)] = cycle_net(PLACE_SLOTS(i,:), place(i,:), cycles, value);
    end
    m1(k) = mean(sum1);
    m2(k) = mean(sum2);
end
activity1 = mean(m1);
activity2 = mean(m2);
disp(['HPC - Task 1a: ', num2str(activity1)]);
disp(['PFC - Task 1a: ', num2str(activity2)]);

for k=1:10
    place_order = randperm(PLACE_CELLS);

    for j = 1:PLACE_CELLS % recover from all slots
        i = place_order(j);

        [fpa sum1(j) sum2(j)] = cycle_net(PLACE_SLOTS(i,:), place(i,:), cycles, value);
    end
    m1(k) = mean(sum1);
    m2(k) = mean(sum2);
end
activity1 = mean(m1);
activity2 = mean(m2);
disp(['HPC - Task 1b: ', num2str(activity1)]);
disp(['PFC - Task 1b: ', num2str(activity2)]);

show_weights('No value', is_disp_weights);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Task 2: Agent stores food in place slots
%         Have agent recover foods from places, but this time with
%         value
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% given food with value
VALUE = stored_val;
activity1 = 0;
activity2 = 0;

side_order = randperm(2);
for i=1:2
    s = side_order(i);
    s_spots = [1+s*7 : 7*(s+1)];
    
    for k=1:1
        p_indices = randperm(PLACE_CELLS/2);
        place_order = s_spots(p_indices);
        
        for j = 1:PLACE_CELLS
            i = place_order(j);

            if place(i,:) == WORM
                value = VALUE(worm);
            else
                value = VALUE(peanut);
            end

            [fpa sum1(j) sum2(j)] = cycle_net(PLACE_SLOTS(i,:), place(i,:), cycles, value);
        end
        m1(k) = mean(sum1);
        m2(k) = mean(sum2);
    end
end
activity1 = mean(m1);
activity2 = mean(m2);
disp(['HPC - Task 2a: ', num2str(activity1)]);
disp(['PFC - Task 2a: ', num2str(activity2)]);

% consolidation
% 
for k=1:consolidation_length
    place_order = randperm(PLACE_CELLS);

    for j = 1:PLACE_CELLS
        i = place_order(j);
  
        if place(i,:) == WORM
            value = VALUE(worm);
        else
            value = VALUE(peanut);
        end
        
        [fpa sum1(j) sum2(j)] = cycle_net(PLACE_SLOTS(i,:), place(i,:), cycles, value);
    end
    m1(k) = mean(sum1);
    m2(k) = mean(sum2);
end
activity1 = mean(m1);
activity2 = mean(m2);
disp(['HPC Task 2b: ', num2str(activity1)]);
disp(['PFC Task 2b: ', num2str(activity2)]);

show_weights('Cached with value ', is_disp_weights);

global TRIAL_DIR;
filename = horzcat(TRIAL_DIR, 'post learning', '_variables');
save(filename);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Task 3: Agent stores food in place slots
%         Have agent recover foods from places, see if it chooses
%         highest-value places.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
is_learning = false;
place_order = randperm(PLACE_CELLS);
activity1 = 0;
activity2 = 0;
for k=1:1
    place_order = randperm(PLACE_CELLS);

    for j = 1:PLACE_CELLS
        i = place_order(j);
  
        if place(i,:) == WORM
            value = VALUE(worm);
        else
            value = VALUE(peanut);
        end
        
        [fpa sum1(j) sum2(j)] = cycle_net(PLACE_SLOTS(i,:), place(i,:), cycles, value);
        
    	hpc_responses_to_place(i,:) = mean(hpc(3:cycles,:));
        pfc_responses_to_place(i,:) = mean(pfc(3:cycles, :));
    end
    m1(k) = mean(sum1);
    m2(k) = mean(sum2);
end
activity1 = mean(m1);
activity2 = mean(m2);
disp(['HPC Task 3a: ', num2str(activity1)]);
disp(['PFC Task 3a: ', num2str(activity2)]);
for k=1:10
    place_order = randperm(PLACE_CELLS);

    for j = 1:PLACE_CELLS
        i = place_order(j);
  
        if place(i,:) == WORM
            value = VALUE(worm);
        else
            value = VALUE(peanut);
        end
        
        [fpa sum1(j) sum2(j)] = cycle_net(PLACE_SLOTS(i,:), place(i,:), cycles, value);
        
    	hpc_responses_to_place(i,:) = mean(hpc(3:cycles,:));
        pfc_responses_to_place(i,:) = mean(pfc(3:cycles, :));
    end
    m1(k) = mean(sum1);
    m2(k) = mean(sum2);
end
activity1 = mean(m1);
activity2 = mean(m2);
disp(['HPC Task 3b: ', num2str(activity1)]);
disp(['PFC Task 3b: ', num2str(activity2)]);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PRETRAINING: Agent stores both foods. Consolidates 124 hours and is allowed to
%           retrieve the foods. Learns worms decay.
%         Then agent stores both foods. Consolidates 4 hours and then is
%         allowed to retrieve the foods. Learns worms are still good.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Cache food 1.
% Cache food 2.

% Consolidate x hours.
% Retrieve.

% pl = zeros(1,14);
% % Four pairs of trials
% for p = 1:4
%     f = rand;
%     t = rand;
%     if f < 0.5
%         food1 = WORM;
%         food2 = PEANUT;
%         PLACE_CELLS1 = 7;
%         PLACE_CELLS2 = 14;
%     else
%         food1 = PEANUT;
%         food2 = WORM;
%         PLACE_CELLS1 = 14;
%         PLACE_CELLS2 = 7;
%     end
%     
%     if t < 0.5
%         time1 = 4;
%         time2 = 124;
%     else
%         time1 = 124;
%         time2 = 4;
%     end
%     
%     
%     for j = 1:PLACE_CELLS1
%   
%         if place(i,:) == WORM
%             value = VALUE(worm);
%         else
%             value = VALUE(peanut);
%         end
%         
%     [fpa sum1(j) sum2(j)] = cycle_net(PLACE_SLOTS(i,:), place(i,:), cycles, value);
%     end
%     
% end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TESTING: Agent stores one food, consolidates either 4 or 124 hours, then
%           stores the second food, and consolidates the leftover time.
%           Then gets to recover its caches.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% for l=1:PLACE_CELLS
%     i = place_order(l);
% 
%     food_stim = place(i,:);
%     place_stim = PLACE_SLOTS(i,:);
% 
%     for j = 3:cycles
%         hpc_out = hpc(j-1,:);
%         place_out = place_region(j-1,:);
%         food_out = food(j-1, :);
% 
%         % sets value
%         if place(i,:) == WORM
%             value = VALUE(worm);
%         else
%             value = VALUE(peanut);
%         end
% 
%         cycle_place(place_out, eye(PLACE_CELLS), place_stim, value);
%         cycle_place(place_out, w_hpc_to_place, hpc_out, value);
% 
%         cycle_food(food_out, eye(FOOD_CELLS), food_stim, value);
%         cycle_food(food_out, w_hpc_to_food, hpc_out, value);
% 
%         cycle_hpc(hpc_out, w_place_to_hpc, place_out, value);
%         cycle_hpc(hpc_out, w_food_to_hpc, food_out, value);
% 
%         cycle_hpc(hpc_out, w_food_to_hpc,  food_stim, value);
% 
%         hpc(j,:) = cycle_hpc(hpc_out, is_learning);
%         place_region(j,:) = cycle_place({place_region(j-1,:), ...
%             hpc(j,:)}, is_learning);
%         food(j,:) = cycle_food({food(j-1,:), hpc(j,:)}, is_learning);
%     end
%     hpc_responses_to_place(i,:) = mean(hpc(3:cycles,:));
% end
% 
% % agent thinks about stored food
% collect_size = 10;
% for k=1:collect_size
%     place_order = randperm(PLACE_CELLS);
%     
%     for j=1:PLACE_CELLS
%         i = place_order(j);
%         
%         food_stim = place(i,:);
%         place_stim = PLACE_SLOTS(i,:);
% 
%         for j = 3:cycles
%             hpc_out = hpc(j-1,:);
%             place_out = place_region(j-1,:);
%             food_out = food(j-1, :);
% 
%             % sets value
%             if place(i,:) == WORM
%                 value = VALUE(worm);
%             else
%                 value = VALUE(peanut);
%             end
% 
%             cycle_place(place_out, eye(PLACE_CELLS), place_stim, value);
%             cycle_place(place_out, w_hpc_to_place, hpc_out, value);
% 
%             cycle_food(food_out, eye(FOOD_CELLS), food_stim, value);
%             cycle_food(food_out, w_hpc_to_food, hpc_out, value);
% 
%             cycle_hpc(hpc_out, w_place_to_hpc, place_out, value);
%             cycle_hpc(hpc_out, w_food_to_hpc, food_out, value);
% 
%             cycle_hpc(hpc_out, w_food_to_hpc, food_stim, value);
% 
%             hpc(j,:) = cycle_hpc(hpc_out, is_learning);
%             place_region(j,:) = cycle_place({place_region(j-1,:), ...
%                 hpc(j,:)}, is_learning);
%             food(j,:) = cycle_food({food(j-1,:), hpc(j,:)}, is_learning);
%         end
%         hpc_responses_to_place(i,:) = mean(hpc(3:cycles,:));
%     end
% end

[checked_places side_pref avg_checks first_checked] = place_slot_check; % mean_spot_check();

filename = horzcat(TRIAL_DIR, 'after final trial ', '_variables');
save(filename);

varlist = {'hpc','place_region','food', 'pfc', 'place_in_queue', ...
    'place_weight_queue', 'hpc_in_queue', 'hpc_weight_queue', ...
    'food_in_queue', 'food_weight_queue', 'pfc_in_queue', ...
    'pfc_weight_queue'};
clear(varlist{:})
end
