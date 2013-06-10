#!/usr/bin/env escript
%% -*- erlang -*-
%%! -name hibari_get_script@192.168.0.157 -kernel net_ticktime 20 -setcookie hibari

-define(HIBARI_CLIENT_NODE,'hibariclient@192.168.0.157').
-define(RPC_TIMEOUT, 5000).

main(Args) ->
   [Tab|Key] = Args,
   ok = hibari_get(list_to_atom(Tab),Key).

display_value(Val,Ts) ->
	io:format("[~ts][~p]~n",[binary_to_list(Val),misc_lib:make_date(Ts)]),
    ok.

%%List_Values = string:tokens(unicode:characters_to_list(Val),"\t"),
make_html([],Str) ->
	Str;
make_html([Val|T],Str) ->
    Z = lists:concat(["<li>",tuple_to_list(Val),"</li>"]),
    make_html(T, Str ++ Z).

read_more([],Str) ->
	Vlist = make_html(Str,[]),
     io:format("~ts~n~n",[Vlist]),
     ok;

read_more([Key|List],ZZ) ->
  	case rpc(brick_simple,get,[msg_tab,Key]) of
     {ok,Ts,Val} ->
	 	Z = [misc_lib:make_date(Ts)] ++ [{binary_to_list(Val)} |  ZZ],
	 	%Z = [{binary_to_list(Val)} | ZZ],
		read_more(List,Z);
     key_not_exist ->
         io:format("Key Not Exist[~ts]~n",[Key]);
     brick_not_available ->
         io:format("Brick Not Available~n",[]);
     {txn_fail,[{A,B}]} ->
         io:format("Error[~p][~p]~n",[A,B])
  	end.

make_key_list(Val) ->
     List_Key = lists:reverse(lists:usort(string:tokens(binary_to_list(Val),","))),
	 io:format("~p~n",[List_Key]),
     read_more(List_Key,[]),
     ok.

hibari_get(Tab,Key) ->
  case rpc(brick_simple,get,[Tab,Key]) of
     {ok,Ts,Val} ->
	 	case Tab of
	     	key_tab ->
         		make_key_list(Val);
			_ ->
         		display_value(Val,Ts)
		 end;
     key_not_exist ->
         io:format("Key Not Exist[~ts]~n",[Key]);
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
