-module(hibari_get_keylist).
-define(HIBARI_CLIENT_NODE,'hibariclient@192.168.0.157').
-define(RPC_TIMEOUT, 5000).
-define(MAX_KEYLIST, 500).
-define(NODE_NUM, 3).

-export([get_keylist/1]).

get_keylist(KeyName) ->
  case rpc(brick_simple,get,[key_list_tab,KeyName]) of
     {ok,Ts,Val} ->
		{ok,Ts,binary_to_list(Val)};
		%{ok,Boolen,display_value(binary_to_list(Val),[])}
	 key_not_exist ->
	 	key_not_exist;
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
