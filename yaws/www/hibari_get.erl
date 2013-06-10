-module(hibari_get).
%%-define(HIBARI_CLIENT_NODE,'hibariclient@192.168.0.157').
-define(HIBARI_CLIENT_NODE,'hibariclient@192.168.0.183').
-define(RPC_TIMEOUT,8000).
-define(TABLE_NUMS,10).

-export([read_key/3]).

read_key(_Tab,Key,Mode) ->
	case read_key_more(Key,[],1) of
		{true,KeyNo} ->
			StrList = read_sub_key_more(KeyNo,[],1),
			case Mode of
				deep ->
					CategoryList = read_category_more(Key,[],1),
					M = re:split(CategoryList,"\s*,\s*"),
					L = read_key_from_category(M,[]),

					AimaiList = read_aimai_more(Key,[],1),
					N = re:split(AimaiList,"\s*,\s*"),
					O = read_key_from_aimai(N,[]),

					%%MergeList = lists:merge(StrList,L),
					%%AimaiMergeList = lists:merge(MergeList,O),
					MergeList = lists:concat([StrList,L]),
					AimaiMergeList = lists:concat([MergeList,O]),
					{ok,Response} = replace_tokens(AimaiMergeList),
					{ok,key_category_aimai,Response};
				_Other ->
					{ok,Response} = replace_tokens(StrList),
					{ok,key,Response}
			end;
		{false,_KeyNo} ->
			CategoryList = read_category_more(Key,[],1),
			%M = [980450,400453,30135],
			M = re:split(CategoryList,"\s*,\s*"),
			StrList = read_key_from_category(M,[]),
			{ok,Response} = replace_tokens(StrList),
			{ok,key_not_exist_read_category,Response}
	end
.

to_html(Str,MP) ->
	case re:run(Str, MP) of
		{match, _Captured} ->
			Rep = "<br>",
			Replace = re:replace(Str, MP, [Rep]),
			Sub = binList_to_list(Replace),
			to_html([Sub],MP);
		nomatch ->
			Str
	end
.

replace_tokens(Str) ->
	Regexp = [","],
	case re:compile(Regexp) of
		{ok,MP} ->
			StrHtml = to_html(Str,MP),
			{ok,StrHtml};
		{error, _ErrSpec} ->
			{ng,Str}
	end
.

binList_to_list([]) ->
    []
;

binList_to_list(Lists) when is_binary(Lists) ->
    binary_to_list(Lists)
;
binList_to_list(Lists) when is_list(Lists) ->
    [H | T] = Lists,
    case is_binary(H) of
        true ->
            HeadStr = binary_to_list(H),
            HeadStr ++ binList_to_list(T);
        false ->
            H ++ binList_to_list(T)
    end
.

read_key_more(_Key,Str,N) when N > ?TABLE_NUMS ->
	case length(Str) of
		0 ->
			{false,Str};
		_Other ->
			{true,Str}
	end;

read_key_more(Key,Str,N) when N =< ?TABLE_NUMS -> 
	 Tab = list_to_atom(string:concat("key_tab_", integer_to_list(N))),
	 case rpc(brick_simple,get,[Tab,Key]) of
     {ok,_Ts,Val} ->
		read_key_more(Key,binary_to_list(Val),?TABLE_NUMS + 100);
     key_not_exist ->
		read_key_more(Key,Str,N + 1);
     brick_not_available ->
         brick_not_available;
     {txn_fail, _Reason} ->
         txn_fail
  	end.

read_sub_key_more(_Key,Str,N) when N > ?TABLE_NUMS ->
    Str
;

read_sub_key_more(Key,Str,N) when N =< ?TABLE_NUMS -> 
	 Tab = list_to_atom(string:concat("sub_key_tab_", integer_to_list(N))),
	 case rpc(brick_simple,get,[Tab,Key]) of
     {ok,_Ts,Val} ->
		read_sub_key_more(Key,binary_to_list(Val) ++ Str,N + 1);
     key_not_exist ->
		read_sub_key_more(Key,Str,N + 1);
     brick_not_available ->
         brick_not_available;
     {txn_fail, _Reason} ->
         txn_fail
  	end.

read_category_more(_Key,Str,N) when N > ?TABLE_NUMS ->
    Str
;

read_category_more(Key,Str,N) when N =< ?TABLE_NUMS -> 
	 Tab = list_to_atom(string:concat("category_tab_", integer_to_list(N))),
	 case rpc(brick_simple,get,[Tab,Key]) of
     {ok,_Ts,Val} ->
		 read_category_more(Key,binary_to_list(Val) ++ Str,N + 1);
     key_not_exist ->
		read_category_more(Key,Str,N + 1);
     brick_not_available ->
         brick_not_available;
     {txn_fail, _Reason} ->
         txn_fail
  	end.

read_aimai_more(_Key,Str,N) when N > ?TABLE_NUMS ->
    Str
;

read_aimai_more(Key,Str,N) when N =< ?TABLE_NUMS -> 
	 Tab = list_to_atom(string:concat("aimai_tab_", integer_to_list(N))),
	 case rpc(brick_simple,get,[Tab,Key]) of
     {ok,_Ts,Val} ->
		 read_aimai_more(Key,binary_to_list(Val),?TABLE_NUMS + 1);
     key_not_exist ->
		read_aimai_more(Key,Str,N + 1);
     brick_not_available ->
         brick_not_available;
     {txn_fail, _Reason} ->
         txn_fail
  	end.


read_key_from_aimai([],KeyList) ->
	KeyList
;

read_key_from_aimai([KeyNo | Tail],KeyList) ->
	Str = read_key_from_aimai_more(KeyNo,[],1),
	case length(Str) of
		0 ->
			read_key_from_aimai(Tail, KeyList);
		_Other ->
			read_key_from_aimai(Tail, Str ++ "," ++ KeyList)
	end
.

read_key_from_aimai_more(_Key,Str, N)  when N > ?TABLE_NUMS ->
	Str
;

read_key_from_aimai_more(Key,Str, N)  when N =< ?TABLE_NUMS ->
	 Tab = list_to_atom(string:concat("rev_key_tab_", integer_to_list(N))),
	 case rpc(brick_simple,get,[Tab,Key]) of
     {ok,_Ts,Val} ->
		read_key_from_category_more(Key,binary_to_list(Val),?TABLE_NUMS + 1);
     key_not_exist ->
		read_key_from_category_more(Key,Str,N + 1);
     brick_not_available ->
         brick_not_available;
     {txn_fail, _Reason} ->
         txn_fail
  	end.

read_key_from_category([],KeyList) ->
	KeyList
;

read_key_from_category([KeyNo | Tail],KeyList) ->
	Str = read_key_from_category_more(KeyNo,[],1),
	case length(Str) of
		0 ->
			read_key_from_category(Tail, KeyList);
		_Other ->
			read_key_from_category(Tail, Str ++ "," ++ KeyList)
	end
.

read_key_from_category_more(_Key,Str, N)  when N > ?TABLE_NUMS ->
	Str
;

read_key_from_category_more(Key,Str, N)  when N =< ?TABLE_NUMS ->
	 Tab = list_to_atom(string:concat("rev_key_tab_", integer_to_list(N))),
	 case rpc(brick_simple,get,[Tab,Key]) of
     {ok,_Ts,Val} ->
		read_key_from_category_more(Key,binary_to_list(Val),?TABLE_NUMS + 1);
     key_not_exist ->
		read_key_from_category_more(Key,Str,N + 1);
     brick_not_available ->
         brick_not_available;
     {txn_fail, _Reason} ->
         txn_fail
  	end.

%make_key_list(Val) ->
%     %L2 = lists:reverse(lists:sort(L1)),
%	 %List_Key = lists:map(fun(X) -> integer_to_list(X) end,L2),
%     %List_Key = string:tokens(binary_to_list(Val),","),
%     %List_Key = lists:usort(string:tokens(binary_to_list(Val),",")),
%     %List_Key = lists:reverse(lists:usort(string:tokens(binary_to_list(Val),","))),
%	 List_Key = string:tokens(binary_to_list(Val),","),
%	 List_Key.

rpc(Module, Fun, Params) ->
    case rpc:call(?HIBARI_CLIENT_NODE, Module, Fun, Params, ?RPC_TIMEOUT) of
        {badrpc, nodedown} ->
            io:format("Hibari client ~p is not running~n", [?HIBARI_CLIENT_NODE]),
            {error, nodedown};
        Response ->
            Response
    end.
