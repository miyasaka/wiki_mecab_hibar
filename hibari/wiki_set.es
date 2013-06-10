
-module(ff).
-export([get_file/2]).

%get_file(N) when is_integer(N), N < 999 ->
.



#!/usr/bin/env escript
%% -*- erlang -*-
%%! -name wiki_set@192.168.0.157 -kernel net_ticktime 20 -setcookie hibari

-define(HIBARI_CLIENT_NODE,'hibariclient@192.168.0.157').
-define(RPC_TIMEOUT, 50000).
-define(MAX_KEY_TAB, 10).
-define(WIKI_DIR,"/home/public/frontier/").

main(N,M) when is_integer(N), is_integer(M), N > 0, N =< M, M < 1000 ->
	get_file(N,M);
   %% file:delete(Filename);

main(_) ->
    io:format("usage:hibari_get_set_script.es [File Name]~n",[]),
    ok.

get_file(N,M) when is_integer(N), is_integer(M), N > 0, N =< M, M < 1000 ->
	Dir = lists:concat([?WIKI_DIR, integer_to_list(N)]),
	Fun = fun(Fname,Acc) ->
		catch_file(Fname,Acc)
	end,
	filelib:fold_files(Dir,"^fr_*", true, Fun,[]),
	get_file(N + 1,M)
;

get_file(N,_M) ->
	io:format("End:[~p]~n",[N])
.

catch_file(Fname,_Acc) ->
	io:format("[~p]~n",[Fname]),
    ok = read_file(Fname),
.

read_file(FileName) ->
   case file:open(FileName,read) of 
      {ok,Handle} ->
	  		%% read first Line 
			case io:read(Handle,'') of
	   			{ok,{KeyNo}} ->
					case io:read(Handle,'') of
	   					{ok,{Key}} ->
							read_line(Handle,CategoryList),
							io:format("[~p]:[~ts][~ts]~n",[KeyNo,Key,CategoryList]),
							ok;
						_Other ->
							io:format("Error~n",[_Other])
	   				end;
     			eof ->
        			eof;
   				Error ->
       		 		Error
			end,
        	file:close(Handle);
			ok = set_keylist(KeyList);
	   {error,_} -> 
          	io:format("Can't Open [~s] ~n",[FileName])
end.

read_line(Handle,Str) ->
	case io:read(Handle,'') of
	   {ok,{Text}} ->
			case Str of 
				[] ->
					read_line(Handle,Text);
				_Other ->
					read_line(Handle,lists:concat([Str,",",Text]))
			end;
     	eof ->
        	Str;
   		Error ->
       		 Error
end.

make_keyname() ->
	random:seed(now()),
	string:concat("list_no_",integer_to_list(random:uniform(?MAX_KEY_TAB))).

set_keylist(Key_List) ->
    KeyName = make_keyname(),
    %io:format("KeyName[~p]~n",[KeyName]),
  	case rpc(brick_simple,get,[key_list_tab,KeyName]) of
     {ok,_,Val} ->
		N = lists:usort(
			lists:concat([string:tokens(Key_List,","),string:tokens(binary_to_list(Val),",")])),
		NewValue = lists:map(fun(X) -> string:concat(X,",") end, N),
		_Ret = rpc(brick_simple,set,[key_list_tab,KeyName,NewValue]),
		ok;
     key_not_exist ->
         _Ret = rpc(brick_simple,set,[key_list_tab,KeyName,Key_List]),
		 %io:format("Ret key not[~p]~n",[Ret]),
		 ok;
     brick_not_available ->
         io:format("Brick Not Available~n",[]);
     {txn_fail,[{A,B}]} ->
         io:format("Error[~p][~p]~n",[A,B])
   end.

key_no_get() ->
  	case rpc(brick_simple,get,[key_list_tab,"key_no"]) of
     {ok,_,Val} ->
	     {KeyNo,_} = string:to_integer(binary_to_list(Val)),
         Value = integer_to_list(KeyNo + 1),
		 %io:format("i_to_b[~p]~n",[Value]),
         _Ret = rpc(brick_simple,set,[key_list_tab,"key_no",Value]),
		 %io:format("Ret[~p]~n",[Ret]),
		{Value};
     key_not_exist ->
         _Ret = rpc(brick_simple,set,[key_list_tab,"key_no","1"]),
		 %io:format("Ret key not[~p]~n",[Ret]),
		 {"1"};
     brick_not_available ->
         io:format("Brick Not Available~n",[]);
     {txn_fail,[{A,B}]} ->
         io:format("Error[~p][~p]~n",[A,B])
   end.

set_key_table(KeyNo,Text) ->
  	 case rpc(brick_simple,set,[msg_tab,KeyNo,Text]) of
     ok ->
		ok;
     brick_not_available ->
         io:format("Brick Not Available~n",[]);
     {txn_fail,[{A,B}]} ->
         io:format("Error[~p][~p]~n",[A,B])
   end.

hibari_get_set(TextNo,KeyText) ->
    %io:format("MsgNo[~p][~ts]~n",[TextNo,KeyText]),
  	case rpc(brick_simple,get,[key_tab,KeyText]) of
     {ok,_,Val} ->
		 NewValue = string:concat(string:concat(TextNo,","),binary_to_list(Val)),
         rpc(brick_simple,set,[key_tab,KeyText,NewValue]);
%%         Hot = integer_to_list(length(string:tokens(NewValue,","))),
%%        _Ret = rpc(brick_simple,set,[hot_word_tab,KeyText,Hot]);
		 %io:format("RPC*~p*~n",[Ret]);
     key_not_exist ->
         rpc(brick_simple,set,[key_tab,KeyText,TextNo]);
%%         _Ret = rpc(brick_simple,set,[hot_word_tab,KeyText,"1"]);
		 %io:format("RPC first*~p*~n",[Ret]);
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

