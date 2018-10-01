-module(path).
-compile(export_all).
-compile({no_auto_import,[node/0]}).

roll(Num) -> rand:uniform(Num).
dice(List) -> lists:nth(rand:uniform(length(List)), List).

prompt() -> dice([luck, test, choice2, choice2, choice2, ability2, ability2]).
result() -> dice([damage_low, damage_low, fill, fill, item_gain]).

ability() -> dice(["Vaulting", "Climbing", "Architecture", "History", "Nature"]).

step() ->
  case prompt() of
    luck -> {luck, result(), result()};
    test -> {test, ability(), result(), result()};
    choice2 -> {choice2, result(), result()};
    ability2 -> {ability2, ability(), result(), result()}
  end.

branch(0) -> fin;
branch(Remaining) -> [segment([], Remaining), segment([], Remaining)].

% branching every 3 steps
segment(Steps, 0) -> Steps;
segment(Steps = [_,_], Remaining) -> lists:append(Steps, [branch(Remaining - 1)]);
segment(Steps, Remaining) -> segment(lists:append(Steps, [step()]), Remaining).

path(Length) -> segment([], Length).