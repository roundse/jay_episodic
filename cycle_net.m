function final_place_activity = cycle_net( place_stim, food_stim, cycles, value)

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
global w_pfc_to_hpc;

global is_learning;

pfc = zeros(cycles, PFC_SIZE);
hpc = zeros(cycles, HPC_SIZE);
food = zeros(cycles, FOOD_CELLS);
place_region = zeros(cycles, PLACE_CELLS);

for j = 2:cycles
    pfc_out = pfc(j-1,:);
    hpc_out = hpc(j-1,:);
    place_out = place_region(j-1,:);
    food_out = food(j-1, :);

    cycle_place(place_out, eye(PLACE_CELLS), eye(PLACE_CELLS), ...
        place_stim, value);
    %cycle_place(place_out, w_hpc_to_place, hpc_out, value);
    % ADDED 4/8
    cycle_place(place_out, w_hpc_to_place, w_pfc_to_place, food_out, ...
        value); % maybe have value?

    cycle_food(food_out, eye(FOOD_CELLS), eye(FOOD_CELLS), eye(FOOD_CELLS), ...
        food_stim, value);
    %cycle_food_hpc(food_out, w_hpc_to_food, hpc_out, value);
    % ADDED 4/8
    cycle_food(food_out, w_hpc_to_food, w_pfc_to_food, w_place_to_food, ...
        place_out, value); % maybe add value?

    cycle_hpc(hpc_out, w_place_to_hpc, place_out, value);
    cycle_hpc(hpc_out, w_food_to_hpc, food_out, value);

    cycle_hpc(hpc_out, w_food_to_hpc,  food_stim, value);
    % ADDED 4/8
    cycle_hpc(hpc_out, w_pfc_to_hpc, pfc_out, value);
    
    % ADDED 4/8
    cycle_pfc(pfc_out, w_place_to_pfc, place_out, value);
    cycle_pfc(pfc_out, w_food_to_pfc, food_out, value);
  
    % ADDED 4/8
    pfc(j,:) = cycle_pfc(pfc_out, is_learning);
    
    
    % WHAT TO DO WITH THESE?
    hpc(j,:) = cycle_hpc(hpc_out, is_learning);
    place_region(j,:) = cycle_place_old({place_region(j-1,:), hpc(j,:), pfc(j,:)}, is_learning);
    food(j,:) = cycle_food({food(j-1,:), hpc(j,:)}, is_learning);
end

final_place_activity = mean(place_region(6:cycles,:));

end

