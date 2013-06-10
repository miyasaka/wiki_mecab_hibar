-module(misc_lib).
-export([make_date/1,make_timestamp/0,make_msec_time/3,make_now/1,even/1]).
-define(EVEN, fun(X) -> (X rem 2) =:= 0 end).

even(Val) -> ?EVEN(Val).

make_timestamp() ->
	{MSec, Sec, USec} = now(),
	(MSec * 1000000 * 1000000) + (Sec * 1000000) + USec
.

make_now(Ts) ->
	MSec = Ts div (1000000 * 1000000),
	MTs = Ts rem (1000000 * 1000000),
	Sec = MTs div 1000000,
	STs = MTs rem 1000000,
	USec = STs,
	{MSec, Sec, USec}
.

make_date(Ts) ->
    Now = make_now(Ts),
    {_Mega, _Sec, _Micro} = Now,
    {Date, Time} = calendar:now_to_local_time(Now),
    {Year, Month, Day} = Date,
    {Hour, Minute, Second} = Time,
	{lists:concat([Year,"-",Month,"-",Day," ",Hour,":",Minute,":",Second])}
.

make_msec_time(Flag,Base_Ts,Day_term) ->
	Msec_Days = 86400 * 1000000 * Day_term, 
	case Flag of
		befor_days ->
			Base_Ts - Msec_Days ;
		after_days ->
			Base_Ts + Msec_Days
	end
.

