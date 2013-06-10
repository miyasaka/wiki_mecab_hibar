
<erl>
start() ->
   case rpc:call(?HIBARI_CLIENT_NODE,brick_simple,get,[max_no_tab,key_no],?RPC_TIMEOUT) of
   		{badrpc,Reason} ->
        	io:format("badrpc[~p]~n",[Reason]),
		    {error,Reason};
		Response ->
	    	io:format("response:[~p]~n",[Response])
	end.

</erl>
