-module(tactics).
-export([flowchart/0]).

-define(MAX_LENGTH, 5).

roll(Num) -> rand:uniform(Num).
dice(List) -> lists:nth(rand:uniform(length(List)), List).

mixup() -> dice([tactic, tactic, tactic, tactic, tactic, tactic, tactic, tactic, tactic, tactic, tactic,
  item_use, item_use, historical]).
result() -> dice([-6, -3, 0, 3, 6]).

tactic() -> {mixup(), result()}.

branch(Remaining) ->
  {
   {tactic(), segment([], Remaining)},
   {tactic(), segment([], Remaining)}}. 

connection(0) -> steady;
connection(Remaining) -> branch(Remaining).

segment(Flow, 0) -> Flow;
segment(Flow, Remaining) -> lists:append(Flow, [connection(Remaining - 1)]).

flowchart() -> 
  Res = segment([], ?MAX_LENGTH),
  file:write_file("./flowchart", io_lib:fwrite("~p.\n", [Res])),
  Res.