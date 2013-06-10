-module(make_html).
-export([key_list/1]).
-define(ROWS_MAX,5).

make_html([],Str,_) ->
    Ts = Str ,
    io:format("path1}*~p*~n",[Ts]),
    Ts;

make_html([Val|T],Str,0) ->
    Ts = ["]})"],
    Ts = string:concat("[{tr, [],[{td, [],",tuple_to_list(Val),"}}]}"),
   io:format("path2*~p*~n",[Str ++ Ts]),
    make_html(T,Str ++ Ts, ?ROWS_MAX);

make_html([Val|T],Str,?ROWS_MAX) ->
	[A|_] = tuple_to_list(Val),
    Ts = ["{tr, [],[{td, [],"] ++ [A] ++ ["}}"],
   io:format("path3*~p*~n",[Str ++ Ts]),
    make_html(T,Str ++ Ts, ?ROWS_MAX - 1);

make_html([Val|T],Str,Rows) ->
	[A|_] = tuple_to_list(Val),
    Ts = ["[[{td, [],"] ++ [A] ++ ["}}"],
    io:format("path4*~p*~n",[Str ++ Ts]),
    make_html(T, Str ++ Ts, Rows - 1 ).

key_list(Val) ->
	Th = {ehtml,
			   {table,[{border,"2"},{bgcolor,"tan"}],
				[
	         		make_html(Val,[],?ROWS_MAX)
				]
			   }
		  },
	Th
.
