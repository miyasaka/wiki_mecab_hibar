#!/usr/bin/env escript
%% -*- erlang -*-
%%! -name miya@192.168.0.157 -kernel net_ticktime 20 -setcookie hibari

-define (HIBARI_CLIENT_NODE,'hibariclient@192.168.0.157').
-define(RPC_TIMEOUT, 5000).

main([Filename]) ->
   ok = read_file(Filename);

main(_) ->
         io:format("usage:hibari_get_set_script.es [File Name]~n",[]),
         ok.

read_file(FileName) ->
   case file:open(FileName,read) of 
      {ok,Handle} ->
         	KeyList = read_line(Handle,[]),
        	file:close(Handle),
			set_keylist(KeyList);
	   {error,_} -> 
          	io:format("Can't Open [~s] ~n",[FileName])
end.

read_line(Handle,[]) ->
	case io:read(Handle,'') of
	   {ok,{_Text}} ->
			read_line(Handle,1,[]);
     	eof ->
        	ok;
   		Error ->
       		 Error
	end.

read_line(Handle,KeyNo,Str) ->
	case io:read(Handle,'') of
	   {ok,{Key_Text}} ->
	        case Str of
				[] ->
					read_line(Handle,KeyNo,Key_Text);
				_Other ->
					read_line(Handle,KeyNo,lists:concat([Str, ",", Key_Text]))
			end;
     	eof ->
        	Str;
   		Error ->
       		 Error
end.

set_keylist(Key_List) ->
  	case rpc(brick_simple,get,[key_list_tab,"list_no_1"]) of
     {ok,_,Val} ->
		 N = lists:usort(
		      lists:concat([string:tokens(Key_List,","),string:tokens(binary_to_list(Val),",")])),
		 NewValue = lists:map(fun(X) -> string:concat(X,",") end, N),
		 %io:format("NewValue:*~p*~p*~n",[is_list(NewValue),NewValue]),
         Ret = rpc(brick_simple,set,[key_list_tab,"list_no_1",NewValue]),
		 %io:format("Ret[~p]~n",[Ret]),
		ok;
     key_not_exist ->
		 %io:format("Value:*~ts*~n",[Key_List]),
         Ret = rpc(brick_simple,set,[key_list_tab,"list_no_1",Key_List]),
		 %io:format("Ret key not[~p]~n",[Ret]),
		 ok;
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

