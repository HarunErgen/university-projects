:- dynamic(blocking/1).
:- dynamic(state/3).
:- dynamic(clicked/2).
:- dynamic(current_key/1).
:- dynamic(width/1).
:- dynamic(height/1).

% For generating new objects. This should be higher than
% the max integer in object_dict.
current_key(1000).
frame_per_second(10).
sleep_period(Y) :- frame_per_second(X), Y is 1/X.
max_depth_limit(30).

% for printing
object_props(food, 'O', yellow).
object_props(tree, 'T', green).
object_props(stone, 'S', white).
object_props(cobblestone, 'C', white).
object_props(bedrock, '#', red).
object_props('.', '.', '.').
object_props('.', '\n', '.').
object_props('@', '@', '@').

% whether the object is interactable or not.
interactable([food, tree, stone, cobblestone]).
% item_info(Item, Requirements, CraftYieldNumber).
item_info(stick, reqs{log: 2}, 4).
item_info(stone_pickaxe, reqs{log: 3, stick: 2, cobblestone: 3}, 100).
item_info(stone_axe, reqs{log: 3, stick: 2, cobblestone: 3}, 100).
% whether the object blocks the agent or not.
%% blocking(stone).
%% blocking(tree).
%% blocking(bedrock).
%% blocking(cobblestone).
% whether an item is placeable or not.
placeable(cobblestone).
% whether an item is consumable or not.
consumable(fruits, 400).
% yields(Item, WhatItYields, HowManyItYields)
yields(cobblestone, cobblestone, 1).
yields(food, fruits, 2).
yields(tree, log, 3).
yields(stone, cobblestone, 3).
% action costs.
consumes(place, 10).
consumes(left_click, 10).
consumes(craft, 1).
consumes(go, 2).
% which item hits which object by how much
attack_points(stone_pickaxe, stone, 3).
attack_points(stone_pickaxe, cobblestone, 3).
attack_points(stone_axe, tree, 3).
% init hps
init_hp(food, 0).
init_hp(tree, 3).
init_hp(cobblestone, 3).
init_hp(stone, 3).
init_hp(bedrock, 0).
