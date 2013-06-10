#!/usr/bin/env escript
%% -*- erlang -*-
%%! -name wiki_load@192.168.0.157 -kernel net_ticktime 20 -setcookie hibari

%-module(wiki_load).
%-export([m/2]).

-define(HIBARI_CLIENT_NODE,'hibariclient@192.168.0.157').
-define(RPC_TIMEOUT, 500000).
-define(MAX_KEY_TAB, 10).
-define(WIKI_DIR,"/home/public/frontier/").

main([N,M]) ->
	get_file(list_to_integer(N),list_to_integer(M))
.
   %% file:delete(Filename);

get_file(N,M) when is_integer(N), is_integer(M), N >= 0, N =< M ->

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
    ok = read_file(Fname)
.

read_file(FileName) ->
   case file:open(FileName,read) of 
      {ok,Handle} ->
			case read_key(Handle) of
				{ok,{KeyNo},{Key}} ->
					ok = set_rev_key_tab(KeyNo,Key),
					ok = set_key_tab(Key,KeyNo),
					{_Num,CategoryList} = read_line(Handle,[],0),
  						CList = lists:concat(lists:map(fun(X) -> string:concat(X,",") end,CategoryList)),
					ok = set_sub_key_tab(KeyNo,CList),

					case call_store_wiki_key(CategoryList,KeyNo) of
						ok ->
							ok;
						miss ->
							miss
					end;
				eof ->
					eof;
				Error ->
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
	   					{ok,{KeyNo},{Key}};
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
			case Str of 
				[] ->
					read_line(Handle,Text,Line + 1);
				_Other ->
					read_line(Handle,lists:concat([Str,",",Text]),Line + 1)
			end;
     	eof ->
        	file:close(Handle),
        	{Line,string:tokens(Str,",")}; 
		Error -> file:close(Handle),
       		{Line, Error}
	end
.

make_category_tab(Mode) ->
	%list_to_atom("category_tab_1")
	random:seed(now()),
	case Mode of 
		category_tab ->
			list_to_atom(string:concat("category_tab_",integer_to_list(random:uniform(?MAX_KEY_TAB)))) ;
		key_tab ->
			list_to_atom(string:concat("key_tab_",integer_to_list(random:uniform(?MAX_KEY_TAB)))) ;
		rev_key_tab ->
			list_to_atom(string:concat("rev_key_tab_",integer_to_list(random:uniform(?MAX_KEY_TAB)))) ;
		sub_key_tab ->
			list_to_atom(string:concat("sub_key_tab_",integer_to_list(random:uniform(?MAX_KEY_TAB)))) 
	end
.

set_rev_key_tab(KeyNo,Key) ->
    Tab = make_category_tab(rev_key_tab),
    case rpc(brick_simple,set,[Tab,KeyNo,Key]) of
    	ok ->
			ok;
		 brick_not_available ->
		    io:format("Brick Not Available~n",[])
	end
.

call_store_wiki_key([Top | CategoryList],KeyNo) ->
	store_wiki_key(KeyNo,Top),
	call_store_wiki_key(CategoryList,KeyNo)
;

call_store_wiki_key([],_KeyNo) ->
ok
.

set_key_tab(KeyNo,Key) ->
	Tab = make_category_tab(key_tab),
  	case rpc(brick_simple,set,[Tab,KeyNo,Key]) of
     ok ->
	 	ok;
     brick_not_available ->
         io:format("Brick Not Available~n",[])
   end
.

set_sub_key_tab(KeyNo,Key) ->
	Tab = make_category_tab(sub_key_tab),
  	case rpc(brick_simple,set,[Tab,KeyNo,Key]) of
     ok ->
	 	ok;
     brick_not_available ->
         io:format("Brick Not Available~n",[])
   end
.
store_wiki_key(KeyNo,Category) ->
	Tab = make_category_tab(category_tab),
  	case rpc(brick_simple,get,[Tab,Category]) of
     {ok,_,Val} ->
		%N = lists:usort(
		%	lists:concat([KeyNo,",",binary_to_list(Val)])),
		N = lists:concat([KeyNo,",",binary_to_list(Val)]),
		%%NewValue = lists:map(fun(X) -> string:concat(X,",") end, N),
		_Ret = rpc(brick_simple,set,[Tab,Category,N]),
		ok;
     key_not_exist ->
         _Ret = rpc(brick_simple,set,[Tab,Category,KeyNo]),
		 ok;
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

