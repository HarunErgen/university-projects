% harun resid ergen
% 2019400141
% compiling: yes
% complete: yes
:- ['cmpecraft.pro'].

:- init_from_map.

%------------------------------------------------------------------------------------------------------------------%
% Manhattan distance between points (X1, Y1) and (X2, Y2).
manhattan_distance([X1,Y1], [X2,Y2], Distance) :- 
    Distance is abs(X2-X1) + abs(Y2-Y1).
%------------------------------------------------------------------------------------------------------------------%
% Minimum element of a list.
minimum_of_list([Minimum], Minimum).
minimum_of_list([H,R|T], Minimum) :- 
    H > R,
    minimum_of_list([R|T], Minimum).
minimum_of_list([H,R|T], Minimum) :-
    H =< R,
    minimum_of_list([H|T], Minimum).
%------------------------------------------------------------------------------------------------------------------%
find_nearest_type([AgentDict, ObjectDict, Time], ObjectType, ObjKey, Object, Distance) :- 
    findall([ObjKey, Object, Distance], get_nearest_type([AgentDict, ObjectDict, Time], ObjectType, [ObjKey, Object, Distance]), Distances),
    minimum_of_distances(Distances, ObjKey, Object, Distance). 
    % Among the ObjKeys, the one with miniumum distance is selected.
get_nearest_type([AgentDict, ObjectDict, _], ObjectType, [ObjKey, Object, Distance]) :-
    get_dict(ObjKey, ObjectDict, Object),
    get_dict(type, Object, ObjectType),
    get_dict(x, AgentDict, X0),
    get_dict(y, AgentDict, Y0),
    get_dict(x, Object, X1),
    get_dict(y, Object, Y1),
    manhattan_distance([X0, Y0], [X1, Y1], Distance).
    % Manhattan distances between the agent and objects are calculated.

% Given lists [[ObjKey1, Object1, Distance1], [ObjKey2, Object2, Distance2]], selects the list with the minimum Distance.
% For example, Distance1 < Distance2, then K = ObjKey1, O = Object1, Minimum = Distance1.
minimum_of_distances([[K, O, Minimum]], K, O, Minimum).
minimum_of_distances([[_, _, HV],[RK, RO, RV]|T], K, O, Minimum) :-
    HV > RV,
    minimum_of_distances([[RK, RO, RV]|T], K, O, Minimum). 
minimum_of_distances([[HK, HO, HV],[_, _, RV]|T], K, O, Minimum) :-
    HV =< RV,
    minimum_of_distances([[HK, HO, HV]|T], K, O, Minimum).
%------------------------------------------------------------------------------------------------------------------%
navigate_to([AgentDict, ObjectDict, Time], X, Y, ActionList, DepthLimit) :-
    navigate_to_helper([AgentDict, ObjectDict, Time], X, Y, ActionList, [], DepthLimit).
% A helper predicate is written in order to instantiate the empty list TempList at the beginning.
% Necessary actions appended to TempList and at the end ActionList is instantiated being equal to TempList
navigate_to_helper([AgentDict, ObjectDict, Time], X, Y, ActionList, TempList, DepthLimit) :-
    get_dict(x, AgentDict, Ax),
    get_dict(y, AgentDict, Ay),
    (
        (Ax > X, DepthLimit >= 0) ->
        (   NDepthLimit is DepthLimit - 1,
            NX is X + 1, 
            append(TempList, [go_left], NTempList),
            navigate_to_helper([AgentDict, ObjectDict, Time], NX, Y, ActionList, NTempList, NDepthLimit)
        );
        (Ax < X, DepthLimit >= 0) ->
        (
            NDepthLimit is DepthLimit - 1,
            NX is X - 1, 
            append(TempList, [go_right], NTempList),
            navigate_to_helper([AgentDict, ObjectDict, Time], NX, Y, ActionList, NTempList, NDepthLimit)
        );
        (Ay > Y, DepthLimit >= 0) ->
        (    
            NDepthLimit is DepthLimit - 1,
            NY is Y + 1, 
            append(TempList, [go_up], NTempList),
            navigate_to_helper([AgentDict, ObjectDict, Time], X, NY, ActionList, NTempList, NDepthLimit)
        );
        (Ay < Y, DepthLimit >= 0) ->
        (
            NDepthLimit is DepthLimit - 1,
            NY is Y - 1, 
            append(TempList, [go_down], NTempList),
            navigate_to_helper([AgentDict, ObjectDict, Time], X, NY, ActionList, NTempList, NDepthLimit)
        );
        (DepthLimit < 0) -> 
        (
            false, !
        );
        append([], TempList, ActionList)
    ).
%------------------------------------------------------------------------------------------------------------------%
% Finds nearest tree, navigates to it, left clicks four times in order to chop it.
chop_nearest_tree([AgentDict, ObjectDict, Time], ActionList) :- 
    find_nearest_type([AgentDict, ObjectDict, Time], tree, _, Object, Distance),
    navigate_to([AgentDict, ObjectDict, Time], Object.x, Object.y, NActionList, Distance),
    append(NActionList, [left_click_c, left_click_c, left_click_c, left_click_c], ActionList).
%------------------------------------------------------------------------------------------------------------------%
% Finds nearest stone, navigates to it, left clicks four times in order to mine it.
mine_nearest_stone([AgentDict, ObjectDict, Time], ActionList) :- 
    find_nearest_type([AgentDict, ObjectDict, Time], stone, _, Object, Distance),
    navigate_to([AgentDict, ObjectDict, Time], Object.x, Object.y, NActionList, Distance),
    append(NActionList, [left_click_c, left_click_c, left_click_c, left_click_c], ActionList).
% Finds nearest cobblestone, navigates to it, left clicks four times in order to mine it.
mine_nearest_cobblestone([AgentDict, ObjectDict, Time], ActionList) :- 
    find_nearest_type([AgentDict, ObjectDict, Time], cobblestone, _, Object, Distance),
    navigate_to([AgentDict, ObjectDict, Time], Object.x, Object.y, NActionList, Distance),
    append(NActionList, [left_click_c, left_click_c, left_click_c, left_click_c], ActionList).
%------------------------------------------------------------------------------------------------------------------%
% Finds nearest food, navigates to it, left clicks once in order to gather it.
gather_nearest_food([AgentDict, ObjectDict, Time], ActionList) :-
    find_nearest_type([AgentDict, ObjectDict, Time], food, _, Object, Distance),
    navigate_to([AgentDict, ObjectDict, Time], Object.x, Object.y, NActionList, Distance),
    append(NActionList, [left_click_c], ActionList).
%------------------------------------------------------------------------------------------------------------------%
collect_requirements([AgentDict, ObjectDict, Time], ItemType, ActionList) :- 
    collect_requirements_helper([AgentDict, ObjectDict, Time], ItemType, ActionList, []).
% Appends Y to X S times, resulting in Z.
append_loop(0,Z,_,Z).
append_loop(S,X,Y,Z) :- 
    append(X,Y,NZ), 
    NS is S - 1, 
    append_loop(NS,NZ,Y,Z).
% A helper predicate is written in order to instantiate the empty list TempList at the beginning.
collect_requirements_helper([AgentDict, ObjectDict, Time], ItemType, ActionList, TempList) :-
    get_dict(inventory, AgentDict, Inv),
    (
        (ItemType = stone_axe) ->
        (
            item_info(stone_axe, Reqs, _),
            get_dict(log, Reqs, ReqLog),
            get_dict(stick, Reqs, ReqStick),
            get_dict(cobblestone, Reqs, ReqCobblestone),
            (
                % If get_dict is false it means there is no log in the inventory, collects required logs.
                % Else, there are logs in the inventory and collects the remaining logs.
                get_dict(log, Inv, LogCount) -> 
                collect_log([AgentDict, ObjectDict, Time], ReqLog - LogCount, TempList, NTempList, NState);
                collect_log([AgentDict, ObjectDict, Time], ReqLog, TempList, NTempList, NState)
            ),
            (  
                item_info(stick, StickReqs, StickYieldNum),
                get_dict(log, StickReqs, StickReqLog),
                (   
                    % If get_dict is true, then there are sticks in the inventory.
                    % Else, there is no stick in the inventory and collects the required sticks.
                    get_dict(stick, Inv, StickCount)  -> 
                    (                                                
                        % Checks if the sticks in the inventory are enough for required sticks. If so, ActionList and State does not change.
                        % Else, collects the remaining sticks.
                        has(stick, ReqStick, Inv) -> 
                        (
                            append(TempList, NTempList, N1TempList),
                            N1State = NState
                        );   
                        (
                            % Checks if there are enough logs in the inventory to craft remaining sticks. If so, crafts.
                            % Else, collects log in the predicate collect_stick.
                            has(log, ((((ReqStick-StickCount-1)//StickYieldNum)+1)*StickReqLog), Inv) ->   
                            (
                                append_loop(ReqStick - StickCount, NTempList, [craft_stick], N1TempList),
                                N1State = NState
                            );
                            collect_stick(NState, ReqStick - StickCount, NTempList, N1TempList, N1State)
                        )
                    );
                    (
                        % Checks if there are enough logs in the inventory to craft required sticks. If so, crafts.
                        % Else, collects log in the predicate collect_stick.
                        has(log, (((ReqStick-1)//StickYieldNum)+1)*StickReqLog, Inv) ->   
                        (
                            append_loop(ReqStick, NTempList, [craft_stick], N1TempList),
                            execute_actions(NState, N1TempList, N1State)
                        );
                        collect_stick(NState, ReqStick, NTempList, N1TempList, N1State)
                    )
                )      
            ),
            (
                % If get_dict is false it means there is no cobblestone in the inventory, collects required cobblestones.
                % Else, there are cobblestones in the inventory and collects the remaining cobblestones.
                get_dict(cobblestone, Inv, CobbleStoneCount) -> 
                collect_cobblestone(N1State, ReqCobblestone - CobbleStoneCount, N1TempList, N2TempList, _);
                collect_cobblestone(N1State, ReqCobblestone, N1TempList, N2TempList, _)
            ),
            append(N2TempList, [], ActionList)
        );
        (ItemType = stone_pickaxe) ->
        (
            item_info(stone_pickaxe, Reqs, _),
            get_dict(log, Reqs, ReqLog),
            get_dict(stick, Reqs, ReqStick),
            get_dict(cobblestone, Reqs, ReqCobblestone),
            (
                % If get_dict is false it means there is no log in the inventory, collects required logs.
                % Else, there are logs in the inventory and collects the remaining logs.
                get_dict(log, Inv, LogCount) -> 
                collect_log([AgentDict, ObjectDict, Time], ReqLog - LogCount, TempList, NTempList, NState);
                collect_log([AgentDict, ObjectDict, Time], ReqLog, TempList, NTempList, NState)
            ),
            (  
                item_info(stick, StickReqs, StickYieldNum),
                get_dict(log, StickReqs, StickReqLog),
                (   
                    % If get_dict is true, then there are sticks in the inventory.
                    % Else, there is no stick in the inventory and collects the required sticks.
                    get_dict(stick, Inv, StickCount)  -> 
                    (                                                
                        % Checks if the sticks in the inventory are enough for required sticks. If so, ActionList and State does not change.
                        % Else, collects the remaining sticks.
                        has(stick, ReqStick, Inv) -> 
                        (
                            append(TempList, NTempList, N1TempList),
                            N1State = NState
                        );   
                        (
                            % Checks if there are enough logs in the inventory to craft remaining sticks. If so, crafts.
                            % Else, collects log in the predicate collect_stick.
                            has(log, ((((ReqStick-StickCount-1)//StickYieldNum)+1)*StickReqLog), Inv) ->   
                            (
                                append_loop(ReqStick - StickCount, NTempList, [craft_stick], N1TempList),
                                N1State = NState
                            );
                            collect_stick(NState, ReqStick - StickCount, NTempList, N1TempList, N1State)
                        )
                    );
                    (
                        % Checks if there are enough logs in the inventory to craft required sticks. If so, crafts.
                        % Else, collects log in the predicate collect_stick.
                        has(log, (((ReqStick-1)//StickYieldNum)+1)*StickReqLog, Inv) ->   
                        (
                            append_loop(ReqStick, NTempList, [craft_stick], N1TempList),
                            execute_actions(NState, N1TempList, N1State)
                        );
                        collect_stick(NState, ReqStick, NTempList, N1TempList, N1State)
                    )
                )      
            ),
            (
                % If get_dict is false it means there is no cobblestone in the inventory, collects required cobblestones.
                % Else, there are cobblestones in the inventory and collects the remaining cobblestones.
                get_dict(cobblestone, Inv, CobbleStoneCount) -> 
                collect_cobblestone(N1State, ReqCobblestone - CobbleStoneCount, N1TempList, N2TempList, _);
                collect_cobblestone(N1State, ReqCobblestone, N1TempList, N2TempList, _)
            ),
            append(N2TempList, [], ActionList)
        );
        (ItemType = stick) ->
        (
            item_info(stick, Reqs, _),
            get_dict(log, Reqs, ReqLog),
            (
                % Checks if required logs are in the inventory. If so, ActionList does not change.
                % Else, collects required logs.
                has(log, ReqLog, Inv) ->  
                (
                    append(TempList, [], NTempList)
                );
                collect_log([AgentDict, ObjectDict, Time], ReqLog, TempList, NTempList, _)
            ),
            append(NTempList, [], ActionList)
        )
    ).
% Generates the necessary actions to collect 'Count' logs.
collect_log([AgentDict, ObjectDict, Time], Count, InputList, ActionList, FinalState) :-
    yields(tree, log, YieldNum),
    (Count > 0) ->
    (
        chop_nearest_tree([AgentDict, ObjectDict, Time], NActionList),
        execute_actions([AgentDict, ObjectDict, Time], NActionList, NewState),
        append(InputList, NActionList , NNActionList),
        NCount is Count - YieldNum,
        collect_log(NewState, NCount, NNActionList, ActionList, FinalState)
    );
    ActionList = InputList,
    FinalState = [AgentDict, ObjectDict, Time],
    true.
% Generates the necessary actions to craft 'Count' sticks.
collect_stick([AgentDict, ObjectDict, Time], Count, InputList, ActionList, FinalState) :-
    item_info(stick, Reqs, YieldNum),
    get_dict(log, Reqs, ReqLog),
    NReqLog is (((Count-1)//YieldNum)+1)*ReqLog,
    (Count > 0) ->
    (
        collect_log([AgentDict, ObjectDict, Time], NReqLog, InputList, NActionList, NewState),
        append(NActionList, [craft_stick], NNActionList),
        NCount is Count - YieldNum,
        collect_stick(NewState, NCount, NNActionList, ActionList, FinalState)
    );
    ActionList = InputList,
    FinalState = [AgentDict, ObjectDict, Time],
    true. 
% Generates the necessary actions to collect 'Count' cobblestones.
collect_cobblestone([AgentDict, ObjectDict, Time], Count, InputList, ActionList, FinalState) :-
    (Count > 0) ->
    (
        (
            mine_nearest_stone([AgentDict, ObjectDict, Time], NActionList) -> 
            (
                yields(stone, cobblestone, YieldNum)
            );
            mine_nearest_cobblestone([AgentDict, ObjectDict, Time], NActionList),
            yields(cobblestone, cobblestone, YieldNum)
        ),
        execute_actions([AgentDict, ObjectDict, Time], NActionList, NewState),
        append(InputList, NActionList , NNActionList),
        NCount is Count - YieldNum,
        collect_cobblestone(NewState, NCount, NNActionList, ActionList, FinalState)
    );
    ActionList = InputList,
    FinalState = [AgentDict, ObjectDict, Time],
    true.
    
%------------------------------------------------------------------------------------------------------------------%
find_castle_location([AgentDict, ObjectDict, Time], XMin, YMin, XMax, YMax) :- 
    check_map([AgentDict, ObjectDict, Time], 1, 1, X, Y),
    XXX is X+2, YYY is Y+2,
    XMin = X, XMax = XXX,
    YMin = Y, YMax = YYY.

% Starting from (X, Y), checks whole map if a castle can be build. 
% (Xleftup, Yleftup) is the upper left corner of the castle.
check_map(State, X, Y, Xleftup, Yleftup) :- 
    width(W), height(H),
    (
        % If the lower bound of the map is exceeded, no more checks the map and returns false.
        (Y =:= H-2) -> (false, !) ; true
    ),
    (
        % (X, Y) being the upper left corner, checks if the nine blocks for the castle is empty. If so, XMin = X and YMin = Y.
        % Else, continue checking.
        check_nine_blocks(State, X, Y) -> 
        (
            Xleftup = X, Yleftup = Y, true
        );
        (
            % If the right bound of the map is exceeded, continue from the beginning of the bottom line.
            % Else, continue from current line.
            (X+2 =:= W-2) -> 
            (
                YY is Y+1,
                check_map(State, 1, YY, Xleftup, Yleftup) 
            );  
                XX is X+1,
                check_map(State, XX, Y, Xleftup, Yleftup)
        )
    ).
% (X, Y) being the upper left corner, checks if the nine blocks for the castle is empty.
check_nine_blocks(State, X, Y) :-
    not(is_tile_blocked(State, X, Y)), not(is_tile_blocked(State, X+1, Y)), not(is_tile_blocked(State, X+2, Y)),
    not(is_tile_blocked(State, X, Y+1)), not(is_tile_blocked(State, X+1, Y+1)), not(is_tile_blocked(State, X+2, Y+1)),
    not(is_tile_blocked(State, X, Y+2)), not(is_tile_blocked(State, X+1, Y+2)), not(is_tile_blocked(State, X+2, Y+2)).
% Checks if the location (X, Y) is blocked.
is_tile_blocked(State, X, Y) :-
    State = [_, StateDict, _],
    get_dict(_, StateDict, Object),
    get_dict(x, Object, Ox),
    get_dict(y, Object, Oy),
    get_dict(type, Object, Type),
    blocks(Type),
    X =:= Ox, Y =:= Oy.
blocks(stone).
blocks(tree).
blocks(bedrock).
blocks(cobblestone).
blocks(food).
%------------------------------------------------------------------------------------------------------------------%
% Makes castle
make_castle([AgentDict, ObjectDict, Time], ActionList) :- 
    get_dict(inventory, AgentDict, Inv),
    (
        get_dict(cobblestone, Inv, CobbleStoneCount) -> 
        collect_cobblestone([AgentDict, ObjectDict, Time], 9-CobbleStoneCount, [], NActionList, NState);
        collect_cobblestone([AgentDict, ObjectDict, Time], 9, [], NActionList, NState)
    ),
    % Finds location for the castle
    find_castle_location(NState, XMin, YMin, _, _),
    X is XMin, XX is XMin+1, XXX is XMin+2,
    Y is YMin, YY is YMin+1, YYY is YMin+2,
    
    max_depth_limit(DepthLimit),
    
    navigate_to(NState, X, Y, N1ActionList, DepthLimit),
    append(N1ActionList, [place_c], N2ActionList),
    execute_actions(NState, N2ActionList, N1State),

    navigate_to(N1State, XX, Y, N3ActionList, DepthLimit),
    append(N3ActionList, [place_c], N4ActionList),
    execute_actions(N1State, N4ActionList, N2State),

    navigate_to(N2State, XXX, Y, N5ActionList, DepthLimit),
    append(N5ActionList, [place_c], N6ActionList),
    execute_actions(N2State, N6ActionList, N3State),

    navigate_to(N3State, XXX, YY, N7ActionList, DepthLimit),
    append(N7ActionList, [place_c], N8ActionList),
    execute_actions(N3State, N8ActionList, N4State),

    navigate_to(N4State, XXX, YYY, N9ActionList, DepthLimit),
    append(N9ActionList, [place_c], N10ActionList),
    execute_actions(N4State, N10ActionList, N5State),

    navigate_to(N5State, XX, YYY, N11ActionList, DepthLimit),
    append(N11ActionList, [place_c], N12ActionList),
    execute_actions(N5State, N12ActionList, N6State),

    navigate_to(N6State, X, YYY, N13ActionList, DepthLimit),
    append(N13ActionList, [place_c], N14ActionList),
    execute_actions(N6State, N14ActionList, N7State),

    navigate_to(N7State, X, YY, N15ActionList, DepthLimit),
    append(N15ActionList, [place_c], N16ActionList),
    execute_actions(N7State, N16ActionList, N8State),

    navigate_to(N8State, XX, YY, N17ActionList, DepthLimit),
    append(N17ActionList, [place_c], N18ActionList),

    append([NActionList, N2ActionList, N4ActionList,
            N6ActionList, N8ActionList, N10ActionList,
            N12ActionList, N14ActionList, N16ActionList,
            N18ActionList], ActionList).
%------------------------------------------------------------------------------------------------------------------%