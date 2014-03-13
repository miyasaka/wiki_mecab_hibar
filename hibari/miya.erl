-module(miya).
-import(lists,[foreach/2]).
-compile(export_all).

-include_lib("stdlib/include/qlc.hrl").

start() ->
	mnesia:start(),
	mnesia:wait_for_tables([hot_word], 20000).


stop() ->
	mnesia:stop().


example_tables() ->
	[
		{hot_word, "l000", <<"日本語123">> },
		%{hot_word, 2, "World"},
		%{hot_word, 1, "Hello-2"},
		%{hot_word, 2, "World-1"},
		{hot_word, "3", << "Night" >>}
	].

insert_data() ->
	F = fun() ->
		foreach(fun mnesia:write/1, example_tables())
		end,
	mnesia:transaction(F).


select_data() ->
	do(qlc:q([X || X <- mnesia:table(hot_word)])).

display([]) ->
	ok;
display([Row|Tail]) ->
    Mi = "日本語",
	{_TB,Num,Text} = Row,
	Str = binary_to_list(Text),
	% Str = mochijson2:encode(Text),
	io:format("~p~n~p~n~ts~n",[Num,Str,Mi]),
	display(Tail)
.

do(Q) ->
	F = fun() -> qlc:e(Q) end,
	{atomic, Val} = mnesia:transaction(F),
	display(Val).

clear_data() ->
	mnesia:clear_table(hot_word).

