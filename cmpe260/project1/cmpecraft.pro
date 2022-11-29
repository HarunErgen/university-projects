:- ['constants.pro'].

/********************
*  ACTION WRAPPERS  *
********************/
go_left(State, NewState) :- go(State, left, NewState), retractall(clicked(_, _)).
go_right(State, NewState) :- go(State, right, NewState), retractall(clicked(_, _)).
go_up(State, NewState) :- go(State, up, NewState), retractall(clicked(_, _)).
go_down(State, NewState) :- go(State, down, NewState), retractall(clicked(_, _)).

craft_stone_axe(State, NewState) :- craft(State, stone_axe, NewState), retractall(clicked(_, _)).
craft_stone_pickaxe(State, NewState) :- craft(State, stone_pickaxe, NewState), retractall(clicked(_, _)).
craft_stick(State, NewState) :- craft(State, stick, NewState), retractall(clicked(_, _)).

left_click_c(State, NewState) :- left_click(State, 0, 0, NewState).
left_click_e(State, NewState) :- left_click(State, 1, 0, NewState).
left_click_n(State, NewState) :- left_click(State, 0, -1, NewState).
left_click_w(State, NewState) :- left_click(State, -1, 0, NewState).
left_click_s(State, NewState) :- left_click(State, 0, 1, NewState).

left_click_ne(State, NewState) :- left_click(State, 1, -1, NewState).
left_click_nw(State, NewState) :- left_click(State, -1, -1, NewState).
left_click_sw(State, NewState) :- left_click(State, -1, 1, NewState).
left_click_se(State, NewState) :- left_click(State, 1, 1, NewState).

place_c(State, NewState) :- place(State, cobblestone, 0, 0, NewState), retractall(clicked(_, _)).
place_e(State, NewState) :- place(State, cobblestone, 1, 0, NewState), retractall(clicked(_, _)).
place_n(State, NewState) :- place(State, cobblestone, 0, -1, NewState), retractall(clicked(_, _)).
place_w(State, NewState) :- place(State, cobblestone, -1, 0, NewState), retractall(clicked(_, _)).
place_s(State, NewState) :- place(State, cobblestone, 0, 1, NewState), retractall(clicked(_, _)).

place_ne(State, NewState) :- place(State, cobblestone, 1, -1, NewState), retractall(clicked(_, _)).
place_nw(State, NewState) :- place(State, cobblestone, -1, -1, NewState), retractall(clicked(_, _)).
place_sw(State, NewState) :- place(State, cobblestone, -1, 1, NewState), retractall(clicked(_, _)).
place_se(State, NewState) :- place(State, cobblestone, 1, 1, NewState), retractall(clicked(_, _)).
eat_fruits(State, NewState) :- eat(State, fruits, NewState), retractall(clicked(_, _)).
/********************/
place(State, Item, DirX, DirY, NewState) :-
    placeable(Item),
    State = [AgentDict, ObjectDict, T],
    get_dict(x, AgentDict, X),
    get_dict(y, AgentDict, Y),
    Ax is X + DirX,
    Ay is Y + DirY,
    get_dict(inventory, AgentDict, Inv),
    (
        remove_from_inv(Item, 1, Inv, NewInv), \+tile_occupied(Ax, Ay, State) ->
        (
            current_key(Key),
            put_dict(Key, ObjectDict, object{x: Ax, y: Ay, type: Item, hp: 3}, NewObjectDict),
            retract(current_key(Key)),
            NewKey is Key + 1,
            assertz(current_key(NewKey)),
            put_dict(inventory, AgentDict, NewInv, NewAgentDict)
        );
        (NewObjectDict = ObjectDict, NewAgentDict = AgentDict)
    ),
    next_hunger_level(NewAgentDict, place, FinalAgentDict),
    Tn is T+1,
    NewState = [FinalAgentDict, NewObjectDict, Tn].
/********************/
left_click(State, DirX, DirY, NewState) :-
    State = [AgentDict, ObjectDict, T],
    get_dict(x, AgentDict, X),
    get_dict(y, AgentDict, Y),
    Ax is X + DirX,
    Ay is Y + DirY,
    (
        (get_dict(ObjKey, ObjectDict, Object),
         get_dict(x, Object, Ox),
         get_dict(y, Object, Oy),
         Ax = Ox, Ay = Oy,
         get_dict(type, Object, Type),
         interactable(InteractableObjects),
         member(Type, InteractableObjects),
         get_dict(hp, Object, ObjHp),
         (
            (ObjHp > 0) -> (
                get_dict(inventory, AgentDict, Inv),
                (
                    (attack_points(Tool, Type, AttackPoints), get_dict(Tool, Inv, _), remove_from_inv(Tool, 1, Inv, NewInv));
                    (NewInv = Inv, AttackPoints is 1)
                ),
                NewObjHp is max(ObjHp-AttackPoints, 0),
                put_dict(hp, Object, NewObjHp, NewObject),
                put_dict(ObjKey, ObjectDict, NewObject, NewObjectDict),
                put_dict(inventory, AgentDict, NewInv, NewAgentDict)
            );
            (
                (
                    (yields(Type, YieldType, YieldCount) ->
                        (
                            get_dict(inventory, AgentDict, Inv),
                            (get_dict(YieldType, Inv, CurrentCount) -> (NewCount is CurrentCount+YieldCount); (NewCount is YieldCount)),
                            put_dict(YieldType, Inv, NewCount, NewInv),
                            put_dict(inventory, AgentDict, NewInv, NewAgentDict)
                        ); (NewAgentDict is AgentDict)
                    )
                ),
                del_dict(ObjKey, ObjectDict, _, NewObjectDict)
            )
         )
        );
        (NewAgentDict = AgentDict, NewObjectDict = ObjectDict)
    ),
    Tn is T+1,
    next_hunger_level(NewAgentDict, left_click, FinalAgentDict),
    NewState = [FinalAgentDict, NewObjectDict, Tn],
    retractall(clicked(_, _)), assertz(clicked(Ax, Ay)), !.
/********************/
craft(State, Item, NewState) :-
    State = [AgentDict, ObjectDict, T],
    get_dict(inventory, AgentDict, Inv),
    item_info(Item, Reqs, YieldNum),
    dict_pairs(Reqs, _, Pairs),
    pairs_keys_values(Pairs, ReqItems, Counts),
    (
        remove_objects_from_inv(ReqItems, Counts, Inv, RemovedInv) ->
        (put_dict(Item, RemovedInv, YieldNum, AddedInv), put_dict(inventory, AgentDict, AddedInv, NewAgentDict));
        (AgentDict = NewAgentDict)
    ),
    Tn is T + 1,
    next_hunger_level(NewAgentDict, craft, FinalAgentDict),
    NewState = [FinalAgentDict, ObjectDict, Tn].
/********************/
craftable(Item, State) :-
    State = [AgentDict, _, _],
    get_dict(inventory, AgentDict, Inv),
    item_info(Item, Reqs, _),
    dict_pairs(Reqs, _, Pairs),
    pairs_keys_values(Pairs, ReqItems, Counts),
    remove_objects_from_inv(ReqItems, Counts, Inv, _).
/********************/
has(Object, Count, Inv) :- get_dict(Object, Inv, ObjCount), ObjCount >= Count.
/********************/
remove_from_inv(Object, Count, Inv, NewInv) :-
    get_dict(Object, Inv, ObjCount),
    ObjCount >= Count,
    NewCount is ObjCount - Count,
    put_dict(Object, Inv, NewCount, NewInv).
remove_objects_from_inv([], [], Inv, Inv).
remove_objects_from_inv([Object|TailObjects], [Count|TailCounts], Inv, NewInv) :-
    remove_from_inv(Object, Count, Inv, TailInv),
    remove_objects_from_inv(TailObjects, TailCounts, TailInv, NewInv).
/********************/
eat(State, Item, NewState) :-
    State = [AgentDict, ObjectDict, T],
    (
        consumable(Item, Energy) ->
        (
            get_dict(inventory, AgentDict, Inv),
            (
                remove_from_inv(Item, 1, Inv, NewInv) ->
                (
                    put_dict(inventory, AgentDict, NewInv, TempAgentDict),
                    get_dict(hunger, TempAgentDict, Hunger),
                    NewHunger is min(Hunger + Energy, 100000),
                    put_dict(hunger, TempAgentDict, NewHunger, NewAgentDict)
                );
                (NewAgentDict = AgentDict)
            )
        );
        (NewAgentDict = AgentDict)
    ),
    Tn is T+1,
    NewState = [NewAgentDict, ObjectDict, Tn].
/********************/
go(State, Direction, NewState) :-
    State = [AgentDict, ObjectDict, T],
    get_dict(x, AgentDict, Ax),
    get_dict(y, AgentDict, Ay),
    call(Direction, Ax, Ay, Axn, Ayn),
    (
        tile_occupied(Axn, Ayn, State) ->
        (NewAgentDict = AgentDict);
        (put_dict(x, AgentDict, Axn, TempDict), put_dict(y, TempDict, Ayn, NewAgentDict))
    ),
    next_hunger_level(NewAgentDict, go, FinalAgentDict),
    Tn is T + 1,
    NewState = [FinalAgentDict, ObjectDict, Tn].

left(Ax, Ay, Axn, Ayn) :-
    width(W), height(H),
    Ax > 1, Ay > 0, Ax < W - 1, Ay < H - 1,
    Axn is Ax - 1, Ayn is Ay.

right(Ax, Ay, Axn, Ayn) :-
    width(W), height(H),
    Ax > 0, Ay > 0, Ax < W - 2, Ay < H - 1,
    Axn is Ax + 1, Ayn is Ay.

up(Ax, Ay, Axn, Ayn) :-
    width(W), height(H),
    Ax > 0, Ay > 1, Ax < W - 1, Ay < H - 1,
    Axn is Ax, Ayn is Ay - 1.

down(Ax, Ay, Axn, Ayn) :-
    width(W), height(H),
    Ax > 0, Ay > 0, Ax < W - 1, Ay < H - 2,
    Axn is Ax, Ayn is Ay + 1.
/********************/
tile_occupied(X, Y, State) :-
    State = [_, StateDict, _],
    get_dict(_, StateDict, Object),
    get_dict(x, Object, Ox),
    get_dict(y, Object, Oy),
    get_dict(type, Object, Type),
    blocking(Type),
    X = Ox, Y = Oy.
/********************/
next_hunger_level(AgentDict, Action, NewAgentDict) :-
    get_dict(hunger, AgentDict, Hunger),
    consumes(Action, Consumption),
    NewHunger is Hunger - Consumption,
    put_dict(hunger, AgentDict, NewHunger, NewAgentDict).
/********************/
print_state(State) :-
    State = [A, S, T],
    ansi_format([bold, fg(blue)], 'T: ~w', [T]), nl,
    write('Agent: '), write(A), nl,
    write('State: '), write(S), nl,
    print_state_helper([A, S, T], [0, 0]).
/********************/
print_state_helper(State, [X, Y]) :-
    width(XMax),
    height(YMax),
    State = [AgentDict, ObjectDict, _],
    (
        ((get_dict(x, AgentDict, X), get_dict(y, AgentDict, Y)) -> ansi_format([fg(blue), bold], "@", []));
        (
            get_dict(_, ObjectDict, Object),
            get_dict(x, Object, X),
            get_dict(y, Object, Y),
            get_dict(type, Object, Type),
            clicked(Cx, Cy), Cx = X, Cy = Y -> object_props(Type, Chr, Color), ansi_format([bold, bg(cyan), fg(Color)], '~w', [Chr]));
        (
            get_dict(_, ObjectDict, Object),
            get_dict(x, Object, X),
            get_dict(y, Object, Y),
            get_dict(type, Object, Type) -> object_props(Type, Chr, Color), ansi_format([bold, fg(Color)], '~w', [Chr]));
        (clicked(Cx, Cy), Cx = X, Cy = Y -> ansi_format([bg(cyan)], ' ', []));
        (((X is 0);(Y is 0);(X is XMax-1);(Y is YMax-1)) -> ansi_format([bold, fg(red)], '~w', ['#']));
        (write(' '))
    ),
    (
        (X<XMax-1 -> Xn is X+1, print_state_helper(State, [Xn, Y]));
        (Y<YMax-1 -> Yn is Y+1, nl, print_state_helper(State, [0, Yn]));
        (!),
        nl
    ).
/********************/
is_terminal(State) :-
    State = [AgentDict, _, T],
    (
        (T > 1000);
        (
            get_dict(hunger, AgentDict, Hunger),
            Hunger < 0
        )
    ).
/********************/
fill_map([],[A,S],[A,S],_):-!.
fill_map([[_,_,'.']|L],[A,S],[An,Sn],Id):-
    fill_map(L,[A,S],[An,Sn],Id).

fill_map([[X,Y,'@']|L],[A,S],[An,Sn],Id):-
    put_dict(x, A, X, An_),
    put_dict(y, An_, Y, Ann),
    fill_map(L,[Ann,S],[An,Sn],Id).

fill_map([[X,Y,Type]|L],[A,S],[An,Sn],Id):-
    Type \= '.' , Type \= '@',
    init_hp(Type, Hp),
    put_dict(Id, S, object{x: X, y: Y, type: Type, hp: Hp}, Sn_),
    Id_ is Id + 1,
    fill_map(L,[A,Sn_],[An,Sn],Id_),!.

read_file(Objects,[X,Y]):-
    open('map.txt', read, File),
    read_lines(File, Objects, -1,[X,Y]),
    close(File).

read_lines(File,[],_,_):- 
    at_end_of_stream(File), !.

read_lines(File,L,-1,[Row,Col]):-
    read_line_to_string(File, String),
    split_string(String, '-', "", [C,R]),    
    number_codes(Row, R),number_codes(Col, C),
    
    read_lines(File,L,0,[Row,Col+1]).

read_lines(File,[[A,B,Name]|L],Count,[Row,Col]):-
    Count =\= -1 ,
    \+ at_end_of_stream(File),
    get_char(File,C),
    object_props(Name,C,_),
    B is Count // Col + 1 , A is rem(Count, Col) + 1,
    read_lines(File,L,Count + 1,[Row,Col]).
/********************/
/********************/
/********************/
/********************/
init_from_map :-
    read_file(Objects,[X,Y]),
    W is Y+2,
    H is X+2,
    retractall(width(_)), retractall(height(_)), retractall(state(_, _, _)),
    assertz(width(W)), assertz(height(H)),
    As = agent_dict{hp: 10, hunger: 100000, inventory: bag{}},
    Ss = object_dict{},
    fill_map(Objects, [As,Ss], [A,S], 0),
    assertz(state(A, S, 1)),!.
/********************/

execute_actions(InitialState, [Action], FinalState) :-
    call(Action, InitialState, FinalState), !.
/********************/
execute_actions(InitialState, [Action|TailActions], FinalState) :-
    call(Action, InitialState, TempState),
    execute_actions(TempState, TailActions, FinalState).
/********************/
execute_print_actions(InitialState, [Action], FinalState) :-
    call(Action, InitialState, FinalState),
    write('Action: '), write(Action), nl,
    print_state(FinalState), !.
/********************/
execute_print_actions(InitialState, [Action|TailActions], FinalState) :-
    call(Action, InitialState, TempState),
    write('Action: '), write(Action), nl,
    print_state(TempState),
    sleep_period(SleepT),
    sleep(SleepT),
    execute_print_actions(TempState, TailActions, FinalState).
/********************/
/********************/
random_move :-
    repeat,
    random_member(Action, [go_left, go_right, go_up, go_down,
                           craft_stone_axe, craft_stone_pickaxe, craft_stick,
                           left_click_e, left_click_n, left_click_w, left_click_s, left_click_c,
                           left_click_ne, left_click_nw, left_click_sw, left_click_se,
                           place_e, place_n, place_w, place_s, place_c,
                           place_ne, place_nw, place_sw, place_se, eat_fruits]),
    state(A, S, T),
    call(Action, [A, S, T], [An, Sn, Tn]),
    write('Action: '), write(Action), nl,
    print_state([A, S, T]),
    sleep_period(SleepT),
    sleep(SleepT),
    retract(state(A, S, T)),
    assertz(state(An, Sn, Tn)),
    is_terminal([An, Sn, Tn]), !.
