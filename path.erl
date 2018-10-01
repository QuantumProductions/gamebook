-module(path).
-compile(export_all).
-compile({no_auto_import,[link/0]}).

-define(MAX_WIDTH, 3).

roll(Num) -> rand:uniform(Num).
dice(List) -> lists:nth(rand:uniform(length(List)), List).

prompt() -> dice([luck, test, choice2, choice2, choice2, ability2, ability2, item_use]).
result() -> dice([damage_low, damage_low, fill, fill, cost, fill, item_gain]).

ability() -> dice(["Vaulting", "Climbing", "Architecture", "History", "Nature"]).
item() -> dice(["Rope", "Ruby", "Skis"]).

step() ->
  case prompt() of
    luck -> {luck, result(), result()};
    test -> {test, ability(), result(), result()};
    choice2 -> {choice2, result(), result()};
    ability2 -> {ability2, ability(), result(), result()};
    item_use -> {item_use, item(), result(), result()}
  end.

% commonality: prompt -> prompt and details, predicate

branch(Remaining, Width) ->
  B = fun() -> segment([], Remaining, Width) end,
  case prompt() of
    luck -> {luck, B(), B()};
    test -> {test, ability(), B(), B()};
    choice2 -> {choice2, B(), B()};
    ability2 -> {ability2, ability(), B(), B()};
    item_use -> {item_use, item(), B(), B()}
  end.

connection(0, _Width) -> fin;
connection(Remaining, Width) ->
  case Remaining < ?MAX_WIDTH of
    true -> branch(Remaining, Width + 1);
    false -> segment([], Remaining, Width - 1)
  end.

% branching every 3 steps
segment(Steps, 0, _Width) -> Steps;
segment(Steps = [_,_], Remaining, Width) -> lists:append(Steps, [connection(Remaining - 1, Width)]);
segment(Steps, Remaining, Width) -> segment(lists:append(Steps, [step()]), Remaining, Width).

path(Length) -> segment([], Length, 0).