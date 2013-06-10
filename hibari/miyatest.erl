%% erl -name xxxx@127.0.0.1 
-module(miyatest).
-export([start/0]).

-define(HIBARI_CLIENT_NODE,'hibariclient@127.0.0.1').
-define(RPC_TIMEOUT,5000).

start() ->
   case rpc:call(?HIBARI_CLIENT_NODE,brick_simple,get,[msg_no_tab,key_no],?RPC_TIMEOUT) of
   	{badrpc,Reason} ->
   		io:format("badrpc[~p]~n",[Reason]),
		{error,Reason};
   	Response ->
   		io:format("response:[~p]~n",[Response])
	end.

