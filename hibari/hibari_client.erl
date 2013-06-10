-module(hibari_client).

-export([start/0,
         stop/0,
         start_applications/0,
         add_client_monitor/2,
         delete_client_monitor/2,
         wait_for_tables/2
        ]).

-define(HIBARI_ADMIN_NODE, 'hibari@192.168.0.183').
-define(HIBARI_COOKIE, hibari).
-define(TABLES, [tab1]).

-define(RPC_TIMEOUT, 15000).


%% ====================================================================
%% API
%% ====================================================================

start() ->
    true = erlang:set_cookie(?HIBARI_ADMIN_NODE, ?HIBARI_COOKIE),
    case start_applications() of
        ok -> 
        case add_client_monitor(?HIBARI_ADMIN_NODE, node()) of
            ok ->
                case wait_for_tables(?HIBARI_ADMIN_NODE, ?TABLES) of
                    ok ->
                        {started, node()};
                    Response ->
                        {error, Response}
                end;
            Response ->
                {error, Response}
        end;
        Response ->
            {error, Response}
    end.

stop() ->
    ok = delete_client_monitor(?HIBARI_ADMIN_NODE, node()),
    timer:sleep(1000),
	io:format("Stop!!!!~n",[]),
    halt(0).


start_applications() ->
    ok = start_net_kernel(node()),
    ok = start_gmt_util(),
    ok = start_gdss_client(),
    ok.

add_client_monitor(HibariAdminNode, ClientNode) ->
    rpc:call(HibariAdminNode,
             brick_admin,
             add_client_monitor,
             [ClientNode],
             ?RPC_TIMEOUT).

delete_client_monitor(HibariAdminNode, ClientNode) ->
    rpc:call(HibariAdminNode,
             brick_admin,
             delete_client_monitor,
             [ClientNode],
             ?RPC_TIMEOUT).

wait_for_tables(HibariAdminNode, Tables) ->
    _ = [ ok = gmt_loop:do_while(fun poll_table/1, {HibariAdminNode, not_ready, Tab})
          || {Tab, _, _} <- Tables ],
    ok.


%% ====================================================================
%% Internal functions
%% ====================================================================

start_net_kernel(Node) ->
    case net_kernel:start(Node) of
        {ok, _} ->
            ok;
        {error, {already_started, _}} ->
            ok;
        {error, {{already_started, _}, _}} ->
            %% TODO: doesn't match documentation
            ok;
        {error, Reason} ->
            {error, Reason}
    end.

start_gmt_util() ->
    case application:start(gmt_util) of
        ok ->
            ok;
        {error, {already_started, gmt_util}} ->
            ok;
        {error, Reason} ->
            {error, Reason}
    end.

start_gdss_client() ->
    case application:start(gdss_client) of
        ok ->
            ok;
        {error, {already_started, gdss_client}} ->
            ok;
        {error, Reason} ->
            {error, Reason}
    end.

poll_table({HibariAdminNode,not_ready,Tab} = T) ->
    TabCh = gmt_util:atom_ify(gmt_util:list_ify(Tab) ++ "_ch1"),
    case rpc:call(HibariAdminNode, brick_sb, get_status, [chain, TabCh], ?RPC_TIMEOUT) of
        {ok, healthy} ->
            {false, ok};
        _ ->
            ok = timer:sleep(5),
            {true, T}
    end.
