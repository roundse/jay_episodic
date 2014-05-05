function [final_place_activity sum1 sum2] = cycle_net( place_stim, ...
    food_stim, cycles, value, sum1, sum2)

global pfc;
global hpc;
global place_region;
global food;

global PLACE_CELLS;
global FOOD_CELLS;
global HPC_SIZE;
global PFC_SIZE;

global w_hpc_to_place;
global w_hpc_to_food;
global w_place_to_hpc;
global w_food_to_hpc;


global w_place_to_food;
global w_pfc_to_food;
global w_food_to_pfc;
global w_pfc_to_place;
global w_place_to_pfc;
% global w_pfc_to_hpc;
% global w_pfc_to_food_inh;
% global w_pfc_to_place_inh;

global is_learning;

pfc = zeros(cycles, PFC_SIZE);
hpc = zeros(cycles, HPC_SIZE);
food = zeros(cycles, FOOD_CELLS);
place_region = zeros(cycles, PLACE_CELLS);
% 
% global base_inh;

if nargin < 4
    value = 1;
end

if nargin < 5
    sum1 = 0;
    sum2 = 0;
end

thresh = -.075;

hpc_activity = 0;
pfc_activity = 0;

for j = 2:cycles
    pfc_out = pfc(j-1,:);
    hpc_out = hpc(j-1,:);
    place_out = place_region(j-1,:);
    food_out = food(j-1, :);

    cycle_place(place_out, eye(PLACE_CELLS), place_stim, value);
    cycle_place(place_out, w_hpc_to_place, hpc_out);
    % ADDED 4/8
    cycle_place(place_out, w_pfc_to_place, pfc_out, value);
    

    cycle_food(food_out, eye(FOOD_CELLS), food_stim, value);
    cycle_food(food_out, w_hpc_to_food, hpc_out, value);
    % ADDED 4/8
    cycle_food(food_out, w_place_to_food, place_out, value); % maybe add value?
    cycle_food(food_out, w_pfc_to_food, pfc_out, value);

    cycle_hpc(hpc_out, w_place_to_hpc, place_out, value);
    cycle_pfc(pfc_out, w_place_to_pfc, place_out, value);
    
    cycle_hpc(hpc_out, w_food_to_hpc, food_out, value);
    cycle_pfc(pfc_out, w_food_to_pfc, food_out, value);
    
    cycle_hpc(hpc_out, w_food_to_hpc,  food_stim, value);
  
    % ADDED 4/8
   %cycle_hpc(hpc_out, w_pfc_to_hpc, pfc_out, value);
   
    
    % ADDED 4/8

    cycle_pfc(pfc_out, w_food_to_pfc, food_stim, value);

  
    % ADDED 4/8
    pfc(j,:) = cycle_pfc(pfc_out, is_learning);
    
    hpc(j,:) = cycle_hpc(hpc_out, is_learning);
    place_region(j,:) = cycle_place({place_region(j-1,:), hpc(j,:), pfc(j,:)}, is_learning);
   % place_region(j,:) = cycle_place({place_region(j-1,:), pfc(j,:)}, is_learning);
    food(j,:) = cycle_food({food(j-1,:), hpc(j,:), pfc(j,:)}, is_learning); % !BUG
   % food(j,:) = cycle_food({food(j-1,:), pfc(j,:)}, is_learning);
        
    hpc_activity = mean(hpc(j,:));
    sum1 = sum1 + hpc_activity;
    pfc_activity = mean(pfc(j,:));
    sum2 = sum2 + pfc_activity;
%     show_weights('Seeing stuff', 1);
%     drawnow;



%     ratio = sum1/sum2; % hpc/pfc activity. if pfc is stronger, ratio will
%                         % be < 1
% 
%     base_prev = base_inh;
%     
%     if ratio >= 0.01 && ratio < 3
%         base_inh = base_prev - (0.00001/ratio);
% %     elseif base_prev <= thresh
% %         base_inh = thresh;
%     end
%     w_pfc_to_hpc = base_inh .* ones(PFC_SIZE, HPC_SIZE);
%     w_pfc_to_food_inh = base_inh .* ones(PFC_SIZE, FOOD_CELLS);
%     w_pfc_to_place_inh = base_inh .* ones(PFC_SIZE, PLACE_CELLS);
end
    
final_place_activity = mean(place_region(6:cycles,:));

end

