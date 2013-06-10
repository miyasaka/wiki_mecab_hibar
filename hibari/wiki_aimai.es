#!/usr/bin/env escript
%% -*- erlang -*-
%%! -name wiki_aimai@192.168.0.183 -kernel net_ticktime 20 -setcookie hibari

%-module(wiki_aimai).
%-export([m/2]).

-define(HIBARI_CLIENT_NODE,'hibariclient@192.168.0.183').
-define(RPC_TIMEOUT, 50000).
-define(MAX_KEY_TAB, 10).
-define(WIKI_DIR,"/var/tmp/wiki/aimai/").
%%-define(WIKI_DIR,"/var/tmp/wiki/test/").

main(_Args) ->
	get_file()
.
   %% file:delete(Filename);

get_file() ->

	Fun = fun(Fname,Acc) ->
		catch_file(Fname,Acc)
	end,
	filelib:fold_files(?WIKI_DIR,"^fr_*", true, Fun,[])
.

catch_file(Fname,_Acc) ->
	io:format("[~p]~n",[Fname]),
    ok = read_file(Fname)
.

read_file(FileName) ->
   case file:open(FileName,read) of 
      {ok,Handle} ->
			case read_key(Handle) of
				{ok,{_KeyNo},{Key}} ->
					{_Num,KeyList} = read_line(Handle,[],0),
					SS = lists:usort(re:split(KeyList,"\s*,\s*")),
					[TTop|T] = SS,
					case string:len(binary_to_list(TTop)) of
						0 ->
							TList = T;
						_Other ->
							TList = SS
					end,
					 SortKeyList = [lists:concat([binary_to_list(X),","]) || X <- TList],
					ok = set_aimai_key_tab(Key,SortKeyList);
				eof ->
					eof;
				error ->
					ok
					%%Error
			end;
	   {error,_} -> 
          	io:format("Can't Open [~s] ~n",[FileName])
end.

read_key(Handle) ->
		%read first line
		case io:read(Handle,'') of
	   		{ok,{KeyNo}} ->
				case io:read(Handle,'') of
	   				{ok,{Key}} ->
						Index_A = string:rstr(Key,"("),
						if
							Index_A > 0 ->
								N = string:sub_string(Key,1,Index_A - 1),
								Index_B = string:rstr(N," "),
								if
									Index_B > 0 ->
										O = string:sub_string(N,1,Index_B - 1);
									Index_B =< 0 ->
										O = N
								end;
   							Index_A =< 0 ->
	                            O = Key
	                    end,
	   					{ok,{KeyNo},{O}};
					eof ->
						eof;
					Error ->
						Error
				end;
			eof ->
				eof;
			Error ->
				Error
		end
.

read_line(Handle,Str,Line) ->
	case io:read(Handle,'') of
	   {ok,{Text}} ->
			{ok,KeyNo} = read_key_tab(Text,1),
			case Str of 
				[] ->
					read_line(Handle,KeyNo,Line + 1);
				_Other ->
					N = lists:concat([KeyNo,",",Str]),
					read_line(Handle,N,Line + 1)
			end;
     	eof ->
        	file:close(Handle),
        	{Line,Str}; 
		error ->
        	{Line,error}
	end
.

make_tab_name() ->
	%%random:seed(now()),
	list_to_atom(string:concat("aimai_tab_",integer_to_list(random:uniform(?MAX_KEY_TAB)))) 
	%%tab1
.

set_aimai_key_tab(Key,KeyList) ->
	Tab = make_tab_name(),
  	case rpc(brick_simple,set,[Tab,Key,KeyList]) of
     ok ->
	 	ok;
     brick_not_available ->
         io:format("Brick Not Available~n",[])
   end
.

read_key_tab(_Key,N) when N > ?MAX_KEY_TAB ->
	{ok,[]}
;

read_key_tab(Key,N) when N =< ?MAX_KEY_TAB ->
	Tab = list_to_atom(string:concat("key_tab_",integer_to_list(N))) ,
  	case rpc(brick_simple,get,[Tab,Key]) of
     {ok,_,Val} ->
	 	{ok,binary_to_list(Val)};
     key_not_exist ->
	 	read_key_tab(Key,N+1);
     brick_not_available ->
         io:format("Brick Not Available~n",[]);
     {txn_fail,[{A,B}]} ->
         io:format("Error[~p][~p]~n",[A,B])
   end
.

rpc(Module, Fun, Params) ->
    case rpc:call(?HIBARI_CLIENT_NODE, Module, Fun, Params, ?RPC_TIMEOUT) of
        {badrpc, nodedown} ->
            io:format("Hibari client ~p is not running~n", [?HIBARI_CLIENT_NODE]),
            {error, nodedown};
        Response ->
            Response
end.

