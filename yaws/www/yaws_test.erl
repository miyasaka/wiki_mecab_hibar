-module(yaws_test).
-export([edit_ehtml/0]).
sub() ->
    {td,[],{a, [{href,"http://www.yahoo.co.jp"}],"Yahoo"}}.

edit_ehtml()->
    Z1 = {td,[],{a, [{href,"http://www.yahoo.co.jp"}],"Yahoo"}},
    Z2 = {td,[],{a, [{href,"http://www.nifty.com"}],"Nifty"}},
	Z3 = {td,[],"This is "},
	ZZZ = {tr,[],[Z1,Z2,Z3]},

	Th = {ehtml,
			{table,[{border,"2"},{bgcolor,"white"}
			       ],
			[
			 {tr, [],
			  [{td, [], {a, [{href,"http://www.google.co.jp"}],"google"}},
			  sub(),
			  Z1,
			  Z2,
			  Z3
			  ]
			 },
			 ZZZ
			]
			}
		  },
	Th
.
