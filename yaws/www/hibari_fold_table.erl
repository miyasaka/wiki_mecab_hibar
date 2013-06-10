-module(hibari_get_keylist).
-define(HIBARI_CLIENT_NODE,'hibariclient@192.168.0.157').
-define(RPC_TIMEOUT, 5000).
-define(MAX_KEYLIST, 500).

-export([get_keylist/0]).

display_Next_value([],VList) ->
	VList;

display_Next_value([Val|T],ZZ) ->
	{Key,_Ts} = Val,
	Z = [{binary_to_list(Key)}] ++ ZZ,
	display_Next_value(T,Z).

display_value([Val|Next]) ->
	{Key,_Ts} = Val,
	display_Next_value(Next,[{binary_to_list(Key)}]).

get_keylist() ->
	Fun = fun({_Ch, {Val,_Ts}},_Acc) ->
	           display_value(Val) end,
  	case rpc(brick_simple,fold_table,[key_tab, Fun, ok, ?MAX_KEYLIST, [witness]]) of
    	{ok,Acc,_} ->
			{ok,Acc,Val};
     	{error,_GdssError,_Acc,_Interations} ->
	 		error
end.

rpc(Module, Fun, Params) ->
    case rpc:call(?HIBARI_CLIENT_NODE, Module, Fun, Params, ?RPC_TIMEOUT) of
        {badrpc, nodedown} ->
            io:format("Hibari client ~p is not running~n", [?HIBARI_CLIENT_NODE]),
            {error, nodedown};
        Response ->
            Response
    end.
