% name surname
% studentid
% compiling: no
% complete: no
:- ['cmpecraft.pro'].

:- init_from_map.

% 10 points
% manhattan distance(+List1, +List2, -Distance) :- .
manhattan_distance([X1,Y1], [X2,Y2], Distance) :- 
    Distance is abs(X2-X1) + abs(Y2-Y1).
% 10 points
% minimum of list(+List, -Minimum) :- .
minimum_of_list([Minimum], Minimum).
minimum_of_list([H,R|T], Minimum) :-
    H > R,
    minimum_of_list([R|T], Minimum). 
minimum_of_list([H,R|T], Minimum) :-
    H =< R,
    minimum_of_list([H|T], Minimum).
% 10 points
% find nearest type(+State, +ObjectType, -ObjKey, -Object, -Distance) :- .
find_nearest_type([AgentDict, ObjectDict, Time], ObjectType, ObjKey, Object, Distance) :- 
    findall([ObjKey, Object, Distance], get_nearest_type([AgentDict, ObjectDict, Time], ObjectType, [ObjKey, Object, Distance]), Distances),
    minimum_of_distances(Distances, ObjKey, Object, Distance).
get_nearest_type([AgentDict, ObjectDict, _], ObjectType, [ObjKey, Object, Distance]) :-
    get_dict(ObjKey, ObjectDict, Object),
    get_dict(type, Object, ObjectType),
    get_dict(x, AgentDict, X0),
    get_dict(y, AgentDict, Y0),
    get_dict(x, Object, X1),
    get_dict(y, Object, Y1),
    manhattan_distance([X0, Y0], [X1, Y1], Distance).
minimum_of_distances([[K, O, Minimum]], K, O, Minimum).
minimum_of_distances([[_, _, HV],[RK, RO, RV]|T], K, O, Minimum) :-
    HV > RV,
    minimum_of_distances([[RK, RO, RV]|T], K, O, Minimum). 
minimum_of_distances([[HK, HO, HV],[_, _, RV]|T], K, O, Minimum) :-
    HV =< RV,
    minimum_of_distances([[HK, HO, HV]|T], K, O, Minimum).
% 10 points
% navigate_to(+State, +X, +Y, -ActionList, +DepthLimit) :- .
navigate_to([AgentDict, ObjectDict, Time], X, Y, ActionList, DepthLimit) :-
    navigate_to_helper([AgentDict, ObjectDict, Time], X, Y, ActionList, [], DepthLimit).
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
% 10 points
% chop_nearest_tree(+State, -ActionList) :- .
chop_nearest_tree([AgentDict, ObjectDict, Time], ActionList) :- 
    find_nearest_type([AgentDict, ObjectDict, Time], tree, _, Object, Distance),
    navigate_to([AgentDict, ObjectDict, Time], Object.x, Object.y, NActionList, Distance),
    append(NActionList, [left_click_c, left_click_c, left_click_c, left_click_c], ActionList).
% 10 points
% mine_nearest_stone(+State, -ActionList) :- .
mine_nearest_stone([AgentDict, ObjectDict, Time], ActionList) :- 
    find_nearest_type([AgentDict, ObjectDict, Time], stone, _, Object, Distance),
    navigate_to([AgentDict, ObjectDict, Time], Object.x, Object.y, NActionList, Distance),
    append(NActionList, [left_click_c, left_click_c, left_click_c, left_click_c], ActionList).
mine_nearest_cobblestone([AgentDict, ObjectDict, Time], ActionList) :- 
    find_nearest_type([AgentDict, ObjectDict, Time], cobblestone, _, Object, Distance),
    navigate_to([AgentDict, ObjectDict, Time], Object.x, Object.y, NActionList, Distance),
    append(NActionList, [left_click_c, left_click_c, left_click_c, left_click_c], ActionList).
% 10 points
% gather_nearest_food(+State, -ActionList) :- .
gather_nearest_food([AgentDict, ObjectDict, Time], ActionList) :-
    find_nearest_type([AgentDict, ObjectDict, Time], food, _, Object, Distance),
    navigate_to([AgentDict, ObjectDict, Time], Object.x, Object.y, NActionList, Distance),
    append(NActionList, [left_click_c], ActionList).
% 10 points
% collect_requirements(+State, +ItemType, -ActionList) :- .
collect_requirements([AgentDict, ObjectDict, Time], ItemType, ActionList) :- 
    collect_requirements_helper([AgentDict, ObjectDict, Time], ItemType, ActionList, []).
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
                has(log, ReqLog, Inv) ->  
                (
                    NState = [AgentDict, ObjectDict, Time]
                );
                collect_log([AgentDict, ObjectDict, Time], ReqLog, TempList, NState)
            ),
            (  
                has(stick, ReqStick, Inv) ->
                (
                    NNState = NState
                );
                collect_stick(NState, ReqStick, TempList, NNState)
            ),
            (
                has(cobblestone, ReqCobblestone, Inv) ->  
                (    
                    true
                );
                collect_cobblestone(NNState, ReqCobblestone, TempList)
            ),
            append(TempList, [], ActionList)
        );
        (ItemType = stone_pickaxe) ->
        (
            item_info(stone_pickaxe, Reqs, _),
            get_dict(log, Reqs, ReqLog),
            get_dict(stick, Reqs, ReqStick),
            get_dict(cobblestone, Reqs, ReqCobblestone),
            (
                has(log, ReqLog, Inv) ->  
                (
                    NState = [AgentDict, ObjectDict, Time]
                );
                collect_log([AgentDict, ObjectDict, Time], ReqLog, TempList, NState)
            ),
            (  
                has(stick, ReqStick, Inv) ->
                (
                    NNState = NState
                );
                collect_stick(NState, ReqStick, TempList, NNState)
            ),
            (
                has(cobblestone, ReqCobblestone, Inv) ->  
                (    
                    true
                );
                collect_cobblestone(NNState, ReqCobblestone, TempList)
            ),
            append(TempList, [], ActionList)
        );
        (ItemType = stick) ->
        (
            item_info(stick, Reqs, _),
            get_dict(log, Reqs, ReqLog),
            (
                has(log, ReqLog, Inv) ->  
                (
                    NState = [AgentDict, ObjectDict, Time]
                );
                collect_log([AgentDict, ObjectDict, Time], ReqLog, TempList, NState)
            ),
            append(TempList, [], ActionList)
        )
    ).

collect_log([AgentDict, ObjectDict, Time], Count, ActionList, FinalState) :-
    yields(tree, log, YieldNum),
    (Count > 0) ->
    (
        chop_nearest_tree([AgentDict, ObjectDict, Time], NActionList),
        execute_actions([AgentDict, ObjectDict, Time], NActionList, NewState),
        append(ActionList, NActionList , NNActionList),
        NCount is Count - YieldNum,
        collect_log(NewState, NCount, NNActionList, FinalState)
    );
    FinalState = [AgentDict, ObjectDict, Time],
    true.
collect_stick([AgentDict, ObjectDict, Time], Count, ActionList, FinalState) :-
    item_info(stick, Reqs, YieldNum),
    get_dict(log, Reqs, ReqLog),
    NReqLog is (((Count-1)//YieldNum)+1)*ReqLog,
    (Count > 0) ->
    (
        collect_log([AgentDict, ObjectDict, Time], NReqLog, NActionList, NewState),
        append(NActionList, [craft_stick], NNActionList),
        NCount is Count - YieldNum,
        collect_stick(NewState, NCount, NNActionList, FinalState)
        );
    FinalState = [AgentDict, ObjectDict, Time],
    true. 
collect_cobblestone([AgentDict, ObjectDict, Time], Count, ActionList) :-
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
        append(ActionList, NActionList , NNActionList),
        NCount is Count - YieldNum,
        collect_cobblestone(NewState, NCount, NNActionList)
    );
    true.
    
% 5 points
% find_castle_location(+State, -XMin, -YMin, -XMax, -YMax) :- .
% 15 points
% make_castle(+State, -ActionList) :- .
