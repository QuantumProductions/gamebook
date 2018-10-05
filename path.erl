-module(path).
-compile(export_all).
-compile({no_auto_import,[link/0]}).

-define(MAX_WIDTH, 1).

roll(Num) -> rand:uniform(Num).
dice(List) -> lists:nth(rand:uniform(length(List)), List).

prompt() -> dice([luck, test, choice2, choice2, choice2, choice2, choice2, choice3, choice3, choice3, ability2, ability2, ability3, ability3, item_use, fill, fill, fill, historical]).
result() -> dice([damage_low, fill, fill, fill, fill, item_gain, cost, impact]).

ability() -> dice([<<"Vaulting">>, <<"Climbing">>, <<"Architecture">>, <<"History">>, <<"Nature">>]).
item() -> dice([<<"Rope">>, <<"Ruby">>, <<"Skis">>]).

step() ->
  case prompt() of
    historical -> {historical, result(), result(), fill};
    luck -> {luck, result(), result(), fill};
    test -> {test, ability(), result(), result()};
    choice2 -> {choice2, result(), result()};
    choice3 -> {choice3, result(), result(), result()};
    ability2 -> {ability2, ability(), result(), result()};
    ability3 -> {ability3, ability(), ability(), result(), result(), result()};
    item_use -> {item_use, item(), result(), result()};
    fill -> fill
  end.

% commonality: prompt -> prompt and details, predicate

bDice() -> dice([-1, 0, 1]).

branch(Remaining, Width) ->
  B = fun() -> segment([], Remaining, Width + bDice()) end,

  case prompt() of
    luck -> {luck, B(), B()};
    test -> {test, ability(), B(), B()};
    choice2 -> {choice2, B(), B()};
    choice3 -> {choice3, B(), B(), B()};
    ability2 -> {ability2, ability(), B(), B()};
    ability3 -> {ability3, ability(), ability(), B(), B(), B()};
    item_use -> {item_use, item(), B(), B()};
    fill -> {fill, B()};
    historical -> {historical, B(), B()}
  end.

connection(0, _Width) -> fin;
connection(Remaining, Width) ->
 % branch(Remaining, Width + 1).
  case Width < ?MAX_WIDTH of
    true -> branch(Remaining, Width);
    false -> converge
  end.

% branching every 3 steps
segment(Steps, 0, _Width) -> Steps;
% segment(Steps = [_,_], Remaining, Width) -> lists:append(Steps, [connection(Remaining - 1, Width)]);
segment(Steps, Remaining, Width) -> 
  case roll(4 - length(Steps)) of
    1 -> lists:append(Steps, [connection(Remaining - 1, Width)]);
    4 -> segment(lists:append(Steps, [fill]), Remaining, Width);
    _ -> segment(lists:append(Steps, [step()]), Remaining, Width)
  end.
  

path(Length) -> 
  Data =segment([], Length, 0),
  file:write_file("./result", io_lib:fwrite("~p.\n", [Data])),
  Data.