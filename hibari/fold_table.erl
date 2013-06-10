-module(fold_table).
-export([fold/0]).

display(K,Val) ->
	case list_to_integer(binary_to_list(Val)) > 300 of
		true ->
	  		io:format("*~ts*~p*~n", [K,Val]);
		false ->
			ok
	end.
		
fold() ->
	io:format("[~p]~n",[get_many()]).

get_many() ->
    Fun = fun({_Ch, {K,_TS,Val,_,_}}, _Acc) ->
	            display(K,Val)
	  end,
	    brick_simple:fold_table(hot_word_tab, Fun, ok, 1000, [])
.

%get_many() ->
%    Fun = fun({_Ch, {K,TS,Val,_,_}}, _Acc) ->
%	            display(K,TS,Val)
%		  end,
%	    brick_simple:fold_table(hot_word_tab, Fun, ok, 1000, [])
%.

%Fun = fun({_Ch, {K,_TS}}, _Acc) -> ok = brick_simple:delete(Tab, K) end,
