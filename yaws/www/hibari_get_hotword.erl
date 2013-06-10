-module(hibari_get_hotword).
-define(HIBARI_CLIENT_NODE,'hibariclient@192.168.0.157').
-define(RPC_TIMEOUT, 500000).
-define(MAX_KEYLIST, 10000).
-define(MAX_HOTWORD, 50).

-export([get_hotword/0]).

display_Next_value([],VList) ->
	lists:sublist(lists:reverse(lists:sort(VList)),?MAX_HOTWORD);
	%lists:sublist(lists:reverse(lists:sort(VList)),?MAX_HOTWORD);

display_Next_value([Val|T],ZZ) ->
	{Key,_Ts,Cnt,_,_} = Val,
	ICnt = list_to_integer(binary_to_list(Cnt)),
	Z = [{{ICnt},{binary_to_list(Key)}}] ++ ZZ,
	display_Next_value(T,Z).

hotword_list([Val|Next]) ->
	{Key,_Ts,Cnt,_,_} = Val,
	ICnt = list_to_integer(binary_to_list(Cnt)),
	display_Next_value(Next,[{{ICnt},{binary_to_list(Key)}}]).

get_hotword() ->
  case rpc(brick_simple,get_many,[hot_word_tab,"",?MAX_KEYLIST]) of
     {ok,{Val,Boolen}} ->
	 		case Val of
				[] ->
					key_not_exit;
				_Other ->
					{ok,Boolen,hotword_list(Val)}
			end;
     brick_not_available ->
         brick_not_available;
     {txn_fail,_Reason} ->
	 	txn_fail
  end.

rpc(Module, Fun, Params) ->
    case rpc:call(?HIBARI_CLIENT_NODE, Module, Fun, Params, ?RPC_TIMEOUT) of
        {badrpc, nodedown} ->
            io:format("Hibari client ~p is not running~n", [?HIBARI_CLIENT_NODE]),
            {error, nodedown};
        Response ->
            Response
    end.
