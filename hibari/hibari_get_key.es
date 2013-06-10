#!/usr/bin/env escript
%% -*- erlang -*-
%%! -name hibari_simple_get@192.168.0.157 -kernel net_ticktime 20 -setcookie hibari

-define(HIBARI_CLIENT_NODE,'hibariclient@192.168.0.157').
-define(RPC_TIMEOUT, 5000).

main(Args) ->
	[Tab|_] = Args,
   	ok = hibari_get(list_to_atom(Tab)).

display_Next_value([]) ->
	ok;

display_Next_value(Val) ->
	[A2|Next] = Val,
	{Key,Ts,_,_,_} = A2,
	io:format("[~ts][~p]~n",[binary_to_list(Key),Ts]),
	display_Next_value(Next).

display_value(Val) ->
	{A1,_} = Val,
	[A2|Next] = A1,
	{Key,Ts,_,_,_} = A2,
	io:format("[~ts][~p]~n",[binary_to_list(Key),Ts]),
	display_Next_value(Next).

hibari_get(Tab) ->
  case rpc(brick_simple,get_many,[Tab,"",50]) of
     {ok,Val} ->
         	display_value(Val);
     brick_not_available ->
         io:format("Brick Not Available~n",[]);
     {txn_fail,[{A,B}]} ->
         io:format("Error[~p][~p]~n",[A,B])
  end.

rpc(Module, Fun, Params) ->
    case rpc:call(?HIBARI_CLIENT_NODE, Module, Fun, Params, ?RPC_TIMEOUT) of
        {badrpc, nodedown} ->
            io:format("Hibari client ~p is not running~n", [?HIBARI_CLIENT_NODE]),
            {error, nodedown};
        Response ->
            Response
    end.
