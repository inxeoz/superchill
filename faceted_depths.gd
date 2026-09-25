extends Node2D

const TILE_WIDTH := 96.0
const TILE_HEIGHT := 48.0
const WALL_HEIGHT := 58.0
const MAP_ORIGIN := Vector2(640.0, 248.0)
const CAMERA_PIVOT := Vector2(640.0, 420.0)
const PLAYER_SPEED := 3.8
const ENEMY_SPEED := 1.45
const ATTACK_COOLDOWN := 0.34
const MAX_HEALTH := 5
const LIFE_JACKET_BOTTLES := 8
const SOURCE_REACH := 1.35
const SOURCE_ITEMS := {
	"dustbin": ["plastic wrapper", "rope", "leaves"],
	"recycling": ["plastic wrapper", "coiled spring"],
	"crate": ["wood scrap", "rope"],
	"cooler": ["coiled spring", "plastic wrapper"],
	"bag": ["plastic wrapper", "rope", "leaves"],
	"compost": ["leaves", "wood scrap"],
}
const ITEM_PHRASES := {
	"leaves": "some leaves",
	"plastic wrapper": "a plastic wrapper",
	"rope": "a length of rope",
	"wood scrap": "a scrap of wood",
	"coiled spring": "a coiled spring",
}
const ITEM_PLURALS := {
	"leaves": "leaves",
	"plastic wrapper": "plastic wrappers",
	"rope": "lengths of rope",
	"wood scrap": "wood scraps",
	"coiled spring": "coiled springs",
}
const DEFAULT_CAMERA_ZOOM := 1.08
const CAMERA_FOLLOW_RATE := 2.4
const LEVELS := [
	{
		"name": "RIVER RUN",
		"kind": "surface",
		"map": [
			"################",
			"#.....~........#",
			"#..#..~........#",
			"#.....~........#",
			"#..#..~........#",
			"#.....~........#",
			"#.##..~........#",
			"#.....~........#",
			"#..#..~........#",
			"#.....~........#",
			"################",
		],
		"shards": [],
		"spawns": [],
		"sources": [
			{"kind": "dustbin", "name": "GARBAGE DUSTBIN", "cell": Vector2i(4, 6), "charges": 3, "bottles": 2},
			{"kind": "recycling", "name": "RECYCLING BIN", "cell": Vector2i(1, 3), "charges": 1, "bottles": 3},
			{"kind": "crate", "name": "BOTTLE CRATE", "cell": Vector2i(4, 1), "charges": 1, "bottles": 2},
			{"kind": "cooler", "name": "PICNIC COOLER", "cell": Vector2i(2, 4), "charges": 1, "bottles": 3},
			{"kind": "bag", "name": "TRASH BAG", "cell": Vector2i(5, 2), "charges": 1, "bottles": 2},
			{"kind": "compost", "name": "COMPOST HEAP", "cell": Vector2i(1, 5), "charges": 1, "bottles": 3},
		],
		"start": Vector2i(1, 7),
		"exit": Vector2i(14, 1),
		"litter": [
			{"kind": "leaves", "cell": Vector2i(2, 1)},
			{"kind": "plastic wrapper", "cell": Vector2i(4, 3)},
			{"kind": "rope", "cell": Vector2i(3, 7)},
			{"kind": "wood scrap", "cell": Vector2i(2, 2)},
			{"kind": "coiled spring", "cell": Vector2i(5, 4)},
			{"kind": "leaves", "cell": Vector2i(1, 1)},
			{"kind": "rope", "cell": Vector2i(4, 8)},
			{"kind": "plastic wrapper", "cell": Vector2i(2, 8)},
			{"kind": "coiled spring", "cell": Vector2i(10, 7)},
			{"kind": "wood scrap", "cell": Vector2i(12, 3)},
			{"kind": "leaves", "cell": Vector2i(13, 5)},
			{"kind": "plastic wrapper", "cell": Vector2i(9, 1)},
		],
		"void": "102f3a",
		"deep": "79bee3",
		"ink": "294f59",
		"ink_soft": "3c6b68",
		"wall_alt": "557f5f",
		"slate": "79a96f",
		"slate_light": "9bc47a",
		"floor_mist": "b4d489",
		"floor_petrol": "70a77c",
		"floor_plum": "d4c887",
		"accent": "f2b84b",
		"safe": "45d9d2",
		"danger": "cf4f5e",
		"enemy": "cf4f5e",
		"enemy_accent": "f2b84b",
		"gate": "70594a",
		"paper": "fffdf0",
		"muted": "b7d0d0",
	},
	{
		"name": "FACETED DEPTHS",
		"map": [
			"############",
			"#....#.....#",
			"#....#.....#",
			"#.##.##.##.#",
			"#......#...#",
			"#.####.#.#.#",
			"#....#...#.#",
			"#..........#",
			"############",
		],
		"shards": [Vector2i(2, 1), Vector2i(5, 4), Vector2i(9, 2)],
		"spawns": [Vector2i(3, 6), Vector2i(4, 2), Vector2i(6, 4), Vector2i(8, 6), Vector2i(10, 3)],
		"start": Vector2i(1, 7),
		"exit": Vector2i(10, 1),
		"enemy_kind": "shardling",
		"enemy_health": 2,
		"enemy_speed": 1.45,
		"void": "060914",
		"deep": "0b1020",
		"ink": "111629",
		"ink_soft": "1b2238",
		"wall_alt": "202840",
		"slate": "26334d",
		"slate_light": "364765",
		"floor_mist": "303a54",
		"floor_petrol": "294654",
		"floor_plum": "40344f",
		"accent": "f0ad4e",
		"safe": "6de5df",
		"danger": "c04a5d",
		"enemy": "c04a5d",
		"enemy_accent": "f0ad4e",
		"gate": "6b5268",
		"paper": "e8edf5",
		"muted": "9aa8bd",
	},
	{
		"name": "MOSSGLASS CISTERN",
		"map": [
			"############",
			"#.#...#....#",
			"#.##....#..#",
			"#.#..###.#.#",
			"#....##...##",
			"##.........#",
			"#..##.#...##",
			"#...##..#.##",
			"############",
		],
		"shards": [Vector2i(3, 1), Vector2i(7, 4), Vector2i(9, 6)],
		"spawns": [Vector2i(4, 2), Vector2i(5, 5), Vector2i(8, 5), Vector2i(2, 6), Vector2i(10, 3)],
		"start": Vector2i(1, 7),
		"exit": Vector2i(10, 1),
		"enemy_kind": "mireling",
		"enemy_health": 3,
		"enemy_speed": 1.1,
		"void": "041512",
		"deep": "0b241e",
		"ink": "12352d",
		"ink_soft": "1c4a3d",
		"wall_alt": "28624b",
		"slate": "245648",
		"slate_light": "32765b",
		"floor_mist": "2a6750",
		"floor_petrol": "3c8060",
		"floor_plum": "456d45",
		"accent": "b7e36b",
		"safe": "7ef0c1",
		"danger": "d77955",
		"enemy": "4f9e69",
		"enemy_accent": "d9f27c",
		"gate": "477b68",
		"paper": "eaf6dc",
		"muted": "a6c4aa",
	},
	{
		"name": "EMBER VAULT",
		"map": [
			"############",
			"##....#..#.#",
			"###..#.....#",
			"#..#...#...#",
			"#...#....#.#",
			"#...###....#",
			"#.#.....##.#",
			"#..#.###...#",
			"############",
		],
		"shards": [Vector2i(2, 1), Vector2i(5, 4), Vector2i(9, 2)],
		"spawns": [Vector2i(3, 6), Vector2i(4, 2), Vector2i(6, 4), Vector2i(8, 5), Vector2i(10, 5)],
		"start": Vector2i(1, 7),
		"exit": Vector2i(10, 1),
		"enemy_kind": "forge_golem",
		"enemy_health": 4,
		"enemy_speed": 0.9,
		"void": "140b08",
		"deep": "26130b",
		"ink": "321a13",
		"ink_soft": "4a281b",
		"wall_alt": "6b3422",
		"slate": "5a3020",
		"slate_light": "81452a",
		"floor_mist": "6b3422",
		"floor_petrol": "8a4526",
		"floor_plum": "3a2420",
		"accent": "f7c45b",
		"safe": "74d4c4",
		"danger": "e0523d",
		"enemy": "d85a32",
		"enemy_accent": "f7c45b",
		"gate": "8a4934",
		"paper": "ffeed2",
		"muted": "c7a58a",
	},
	{
		"name": "STARFALL RELIQUARY",
		"map": [
			"############",
			"#.......#..#",
			"#.#..###...#",
			"#.......#..#",
			"##.#...#...#",
			"##..#...#..#",
			"##.#.##...##",
			"#.......#..#",
			"############",
		],
		"shards": [Vector2i(2, 1), Vector2i(5, 4), Vector2i(9, 2)],
		"spawns": [Vector2i(3, 7), Vector2i(4, 2), Vector2i(6, 5), Vector2i(8, 6), Vector2i(10, 4)],
		"start": Vector2i(1, 7),
		"exit": Vector2i(10, 1),
		"enemy_kind": "astral_sentry",
		"enemy_health": 3,
		"enemy_speed": 1.7,
		"void": "08091b",
		"deep": "111333",
		"ink": "1b1e3b",
		"ink_soft": "292651",
		"wall_alt": "353565",
		"slate": "353565",
		"slate_light": "4a4a7d",
		"floor_mist": "3e3d70",
		"floor_petrol": "314f72",
		"floor_plum": "563b70",
		"accent": "e6a6ff",
		"safe": "7de7ff",
		"danger": "e05c9b",
		"enemy": "7656b8",
		"enemy_accent": "e6a6ff",
		"gate": "5b4a86",
		"paper": "f3edff",
		"muted": "a9a6cf",
	},
]

const PLAYER_PIXELS_CHARS := "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"
const PLAYER_PIXELS := {
	"palette": [Color("000000"), Color("0a0707"), Color("1a0d07"), Color("22240a"), Color("32190d"), Color("391f10"), Color("39393a"), Color("4a2a13"), Color("523017"), Color("525354"), Color("70491e"), Color("734422"), Color("737373"), Color("744124"), Color("868686"), Color("8b522f"), Color("8f5426"), Color("8f6236"), Color("959492"), Color("a16139"), Color("bababa"), Color("c7814c"), Color("d18357"), Color("edbd7a"), Color("f4ab77"), Color("fccb9f"), Color("ffffff")],
	"ne": [
		{"ox": 18, "oy": 15, "rows": [
			".....11111.......",
			".1111FFFFJ111....",
			"1FFJJJJJJJJJD11..",
			".1FJJJJJJJJJJJD1.",
			"1FFLJJJJJJJJJJ1..",
			"1FFLLJJJJLFFFFJ1.",
			"1DFFFFFFFFDDOFDD1",
			"1DDDDDDODOOOPODD1",
			".1DDDDOOPOPPPPP11",
			"..1MOFPP1PPPP1P1.",
			"..1MOOPPPPMMMPP1.",
			"..1MOPPPPPPPPPO1.",
			"...1MOOOOOOOOO1..",
			".....1MMMMMMMM1..",
			".....1CCCCCMMC1..",
			".....16CC999CC1..",
			".....16CEEEEE91..",
			".....169CCCC991..",
			"......15888NNN81.",
			"......1CC99HHHC1.",
			"......1699999991.",
			"......17B1111171.",
			"......111....111.",
		]},
		{"ox": 18, "oy": 14, "rows": [
			".....111.........",
			".1111FFF1111111..",
			"1FFJJJJJJJJJDD1..",
			"1FJJJJJJJJJJJD1..",
			"1FFLJJJJJJJJJJ1..",
			"1FFJLLLLJLFFFFJ1.",
			"1DFFFFFFFFDDOFDD1",
			"1DDDDDDODOOOPODD1",
			"1DDDDOOPOPPPPP11.",
			"..1MOFPP1PPPP1P1.",
			"..1MOOPPPPMMMPP1.",
			"..1MOPPPPPPPPPO1.",
			"...1MOOOOOOOOO1..",
			"....1MMMMMMMM1...",
			".....1CCCCCMMC1..",
			".....16CC999CC1..",
			".....16CEEEEE91..",
			".....169CCCC991..",
			".....15888NNN81..",
			"......169CCHHHC1.",
			"......169CCC111..",
			".......169CC11...",
			"........117B1....",
			"..........111....",
		]},
		{"ox": 18, "oy": 15, "rows": [
			"...11111....11...",
			".11FFFF11111D1...",
			"1FFJJJJJJJJJD1...",
			".1FJJJJJJJJJJJ1..",
			"1FFJJJJJJJJJJJ1..",
			"1FFJLJLLLLFFFFJ1.",
			"1DFFFFFFFFDDOFDD1",
			"1DDDDDDODOOOPODD1",
			".1DDDDOOPOPPPPP11",
			"..1MOFPP1PPPP1P1.",
			"..1MOOPPPPMMMPP1.",
			"..1MOPPPPPPPPPO1.",
			"...1MOOOOOOOOO1..",
			".....1MMMMMMMM1..",
			".....1CCCCCMMC1..",
			".....16CC999CC61.",
			".....16CEEEEE961.",
			".....169CCCC9961.",
			"......15888NNN881",
			"......1CC99HHHC91",
			"......16999999991",
			"......17B111117B1",
			"......111....1111",
		]},
		{"ox": 18, "oy": 14, "rows": [
			".....11111.......",
			".1111FFFFJ111....",
			"1FFJJJJJJJJJD11..",
			"1FLJJJJJJJJJJD1..",
			"1FFLJJJJJJJJJJ1..",
			"1FFJLJJJLLFFFFJ1.",
			"1DFFFFFFFFDDOFDD1",
			"1DDDDDDODOOOPODD1",
			"1DDDDOOPOPPPPP11.",
			"..1MOFPP1PPPP1P1.",
			"..1MOOPPPPMMMPP1.",
			"..1MOPPPPPPPPPO1.",
			"...1MOOOOOOOOO1..",
			"....1MMMMMMMM1...",
			".....1CCCCCMMC1..",
			".....16CC999CC1..",
			".....16CEEEEE91..",
			".....169CCCC991..",
			".....15888NNN81..",
			"......169CCHHHC1.",
			"......169CCC111..",
			".......169CC11...",
			"........177B1....",
			".........111.....",
		]},
	],
	"se": [
		{"ox": 18, "oy": 15, "rows": [
			".....11111.......",
			".1111FFFFJ111....",
			"1FFJJJJJJJJJD11..",
			".1FLJJJJJJJJJJD1.",
			"1FFLJJJJJJJJJJ1..",
			"1FFJLJJJJJFFFFJ1.",
			"1DFFFFFFFFDDOFDD1",
			"1DDDDDDODOOOPODD1",
			".1DDDOOOPOPPPPP11",
			"..1MOP1PPPPP1PP1.",
			"..1MOPPPMMMPPPP1.",
			"..1MOPPPPPPPPPO1.",
			"...1MOOOOOOOOO1..",
			".....1MMMMMMMM1..",
			"....196C9DDD9C61.",
			"....166CC999CC61.",
			"....166CEEEEE991.",
			"....1669CCCC9991.",
			".....1558NNNN8551",
			".....16CC99HHHC91",
			".....166999999991",
			".....17B1111117B1",
			".....111......111",
		]},
		{"ox": 18, "oy": 14, "rows": [
			"...1111..........",
			".11FFFF111111....",
			"1FFJJJJJJJJJD1...",
			"1FJJJJJJJJJJJ1...",
			"1FFJJJJJJJJJJJ1..",
			"1FFJLLLJLJFFFFJ1.",
			"1DFFFFFFFFDDOFDD1",
			"1DDDDDDODOOOPODD1",
			"1DDDOOOPOPPPPP11.",
			"..1MOP1PPPPP1PP1.",
			"..1MOPPPMMMPPPP1.",
			"..1MOPPPPPPPPPO1.",
			"...1MOOOOOOOOO1..",
			"....1MMMMMMMM1...",
			"....196C9DDD9C61.",
			"....166CC999CC61.",
			"....166CEEEEE991.",
			"....1669CCCC9991.",
			"....1558NNNN8551.",
			".....1111HHHHCC91",
			".....144419999991",
			".....122211117B1.",
			"......2221...111.",
		]},
		{"ox": 18, "oy": 15, "rows": [
			".....11111.......",
			".1111FFFFF1111...",
			"1FFJJJJJJJJJJJ1..",
			".1FJJJJJJJJJJJF1.",
			"1FFJJJJJJJJJJF1..",
			"1FFJLJLLLJFFFFJ1.",
			"1DFFFFFFFFDDOFDD1",
			"1DDDDDDODOOOPODD1",
			".1DDDOOOPOPPPPP11",
			"..1MOP1PPPPP1PP1.",
			"..1MOPPPMMMPPPP1.",
			"..1MOPPPPPPPPPO1.",
			"...1MOOOOOOOOO1..",
			".....1MMMMMMMM1..",
			"....196C9DDD9C61.",
			"....166CC999CC61.",
			"....166CEEEEE991.",
			"....1669CCCC9991.",
			".....1558NNNN8551",
			".....16CC99HHHC91",
			".....166999999991",
			".....17B1111117B1",
			".....111......111",
		]},
		{"ox": 18, "oy": 14, "rows": [
			"...111111111.....",
			".11FFFFFFJJD1....",
			"1FFJJJJJJJJJD11..",
			"1FJJJJJJJJJJJD1..",
			"1FFJJJJJJJJJJJ1..",
			"1FFJJJLJLLFFFFJ1.",
			"1DFFFFFFFFDDOFDD1",
			"1DDDDDDODOOOPODD1",
			"1DDDOOOPOPPPPP11.",
			"..1MOP1PPPPP1PP1.",
			"..1MOPPPMMMPPPP1.",
			"..1MOPPPPPPPPPO1.",
			"...1MOOOOOOOOO1..",
			"....1MMMMMMMM1...",
			"....196C9DDD9C61.",
			"....166CC999CC61.",
			"....166CEEEEE991.",
			"....1669CCCC9991.",
			"....1558NNNN8551.",
			".....1999HHHH1111",
			".....199999914441",
			"......1B711112221",
			"......111...1222.",
		]},
	],
	"sw": [
		{"ox": 29, "oy": 15, "rows": [
			".......11111.....",
			"....111JFFFF1111.",
			"..11DJJJJJJJJJFF1",
			".1DJJJJJJJJJJJF1.",
			"..1JJJJJJJJJJLFF1",
			".1JFFFFLJJJJLLFF1",
			"1DDFODDFFFFFFFFD1",
			"1DDOPOOODODDDDDD1",
			"11PPPPPOPOODDDD1.",
			".1P1PPPP1PPFOM1..",
			".1PPMMMPPPPOOM1..",
			".1OPPPPPPPPPOM1..",
			"..1OOOOOOOOOM1...",
			"..1MMMMMMMM1.....",
			"..1CMMCCCCC1.....",
			"..1CC999CC61.....",
			"..19EEEEEC61.....",
			"..199CCCC961.....",
			".18NNN88851......",
			".1CHHH99CC1......",
			".1999999961......",
			".1711111B71......",
			".111....111......",
		]},
		{"ox": 28, "oy": 14, "rows": [
			".......111.......",
			"...1111FFF1111111",
			"..1FFJJJJJJJJJDD1",
			"..1FJJJJJJJJJJJD1",
			"1FFLJJJJJJJJJJ1..",
			"1FFJLLLLJLFFFFJ1.",
			"1DFFFFFFFFDDOFDD1",
			"1DDDDDDODOOOPODD1",
			"1DDDDOOPOPPPPP11.",
			"1MOFPP1PPPP1P1...",
			"1MOOPPPPMMMPP1...",
			"1MOPPPPPPPPPO1...",
			".1MOOOOOOOOO1....",
			"..1MMMMMMMM1.....",
			".1CCCCCMMC1......",
			".16CC999CC1......",
			".16CEEEEE91......",
			".169CCCC991......",
			".15888NNN81......",
			"169CCHHHC1.......",
			"169CCC111........",
			".169CC11.........",
			"..117B1..........",
			"....111..........",
		]},
		{"ox": 27, "oy": 15, "rows": [
			"......11111....11.",
			"....11FFFF11111D1.",
			"...1FFJJJJJJJJJD1.",
			"..1FJJJJJJJJJJJ1..",
			".1FFJJJJJJJJJJJ1..",
			".1FFJLJLLLLFFFFJ1.",
			".1DFFFFFFFFDDOFDD1",
			".1DDDDDDODOOOPODD1",
			"1DDDDOOPOPPPPP11..",
			".1MOFPP1PPPP1P1...",
			".1MOOPPPPMMMPP1...",
			".1MOPPPPPPPPPO1...",
			"..1MOOOOOOOOO1....",
			"..1MMMMMMMM1......",
			"..1CCCCCMMC1......",
			"..16CC999CC61.....",
			"..16CEEEEE961.....",
			"..169CCCC9961.....",
			".15888NNN881......",
			".1CC99HHHC91......",
			".16999999991......",
			".17B111117B1......",
			".111....1111......",
		]},
		{"ox": 28, "oy": 14, "rows": [
			".......11111.....",
			"...1111FFFFJ111..",
			"..1FFJJJJJJJJJD11",
			"..1FLJJJJJJJJJJD1",
			"1FFLJJJJJJJJJJ1..",
			"1FFJLJJJLLFFFFJ1.",
			"1DFFFFFFFFDDOFDD1",
			"1DDDDDDODOOOPODD1",
			"1DDDDOOPOPPPPP11.",
			"1MOFPP1PPPP1P1...",
			"1MOOPPPPMMMPP1...",
			"1MOPPPPPPPPPO1...",
			".1MOOOOOOOOO1....",
			"..1MMMMMMMM1.....",
			".1CCCCCMMC1......",
			".16CC999CC1......",
			".16CEEEEE91......",
			".169CCCC991......",
			".15888NNN81......",
			"169CCHHHC1.......",
			"169CCC111........",
			".169CC11.........",
			"..177B1..........",
			"...111...........",
		]},
	],
	"nw": [
		{"ox": 27, "oy": 15, "rows": [
			"........11111.....",
			"....1111FFFFJ111..",
			"...1FFJJJJJJJJJD11",
			"..1FLJJJJJJJJJJD1.",
			".1FFLJJJJJJJJJJ1..",
			".1FFJLJJJJJFFDFJ1.",
			".1DFFFFFFFFDDDFDD1",
			".1DDDDDDDDDDDDDDD1",
			"1DDDDDDDDDDDDD11..",
			".1DDDDDDDDDDDD1...",
			".1DDDDDDDDDDDD1...",
			".1DDDDDDDDDDDD1...",
			"..1DDD6666DDD1....",
			"..1669999661......",
			".166999999961.....",
			".169999999961.....",
			".169999999961.....",
			".166666666661.....",
			"155888888551......",
			"166669996661......",
			"166666666661......",
			"17B1111117B1......",
			"111......111......",
		]},
		{"ox": 27, "oy": 13, "rows": [
			"......1111........",
			"....11FFFF111111..",
			"...1FFJJJJJJJJJD1.",
			"...1FJJJJJJJJJJJ1.",
			"..1FFJJJJJJJJJJJ1.",
			".1FFJLLLJLJFFFFJ1.",
			".1DFFFFFFFFDDDFDD1",
			".1DDDDDDDDDDDDDDD1",
			".1DDDDDDDDDDDDDD1.",
			".1DDDDDDDDDDDDDD1.",
			".1DDDDDDDDDDDD1...",
			".1DDDDDDDDDDDD1...",
			".1DDDDDDDDDDDD1...",
			"..1DDD6666DDD1....",
			"...1666999661.....",
			".166999999661.....",
			".169999999961.....",
			".169999999961.....",
			".166666666661.....",
			".155888888551.....",
			"166669966661......",
			"11111111B71.......",
			".1111...771.......",
			"........111.......",
		]},
		{"ox": 27, "oy": 15, "rows": [
			"........11111.....",
			"....1111FFFFF1111.",
			"...1FFJJJJJJJJJJJ1",
			"..1FJJJJJJJJJJJF1.",
			".1FFJJJJJJJJJJF1..",
			".1FFJLJLLLJFFFFD1.",
			".1DFFFFFFFFDDDDDD1",
			".1DDDDDDDDDDDDDDD1",
			"1DDDDDDDDDDDDD11..",
			".1DDDDDDDDDDDD1...",
			".1DDDDDDDDDDDD1...",
			".1DDDDDDDDDDDD1...",
			"..1DDD6666DDD1....",
			"..1669999661......",
			".166999999961.....",
			".169999999961.....",
			".169999999961.....",
			".166666666661.....",
			"155888888551......",
			"166699999661......",
			"166666666661......",
			"17B1111117B1......",
			"111......111......",
		]},
		{"ox": 27, "oy": 13, "rows": [
			"......111111111...",
			"....11FFFFFFJJD1..",
			"...1FFJJJJJJJJJD11",
			"...1FJJJJJJJJJJJD1",
			"..1FFJJJJJJJJJJJ1.",
			".1FFJJJLJLLFFFFJ1.",
			".1DFFFFFFFFDDDFDD1",
			".1DDDDDDDDDDDDDDD1",
			".1DDDDDDDDDDDDDD1.",
			".1DDDDDDDDDDDDDD1.",
			".1DDDDDDDDDDDD1...",
			".1DDDDDDDDDDDD1...",
			".1DDDDDDDDDDDD1...",
			"..1DDD6666DDD1....",
			"...1669999661.....",
			".166999999661.....",
			".169999999961.....",
			".169999999961.....",
			".166666666661.....",
			".155888888551.....",
			"166669996661......",
			".1B71111111.......",
			".177...1111.......",
			".111..............",
		]},
	],
	"sword_ne": {"ox": 17, "oy": 28, "rows": [
		".............00......",
		".............0A0.....",
		"..00000000000GG000...",
		".0QQQKQQQKKQKGA333000",
		"0IIIIIIIIIIIIGG333330",
		"..000000000000GA00000",
		"..............0G0....",
		"..............00.....",
	]},
	"sword_se": {"ox": 25, "oy": 23, "rows": [
		"..00....",
		"..030...",
		"..030...",
		".0330...",
		".0330...",
		".003300.",
		"0AGAGAG0",
		"00GGGG00",
		"..0KI0..",
		"..0QI0..",
		"...0KI0.",
		"...0KI0.",
		"...0QI0.",
		"...0QI0.",
		"...0QI0.",
		"....0KI0",
		"....0QI0",
		"....0QI0",
		"....0QI0",
		".....0I0",
		".......0",
	]},
	"sword_sw": {"ox": 24, "oy": 26, "rows": [
		".......00............",
		"......0G0............",
		".00000AG000000000000.",
		"033333GGIIIIIIIIIIII0",
		"000333AGKQKKQQQKQQQ0.",
		"...000GG00000000000..",
		".....0A0.............",
		".....00..............",
	]},
	"sword_nw": {"ox": 30, "oy": 20, "rows": [
		"......0..",
		".....0I0.",
		".....0IQ0",
		"....0IQ0.",
		"....0IQ0.",
		"....0IK0.",
		"....0IQ0.",
		"....0IQ0.",
		"...0IQ0..",
		"...0IK0..",
		"...0IK0..",
		"...0IQ0..",
		"...0IK0..",
		"00GGGG00.",
		"0GAGAGA0.",
		".003300..",
		"..0330...",
		"..0330...",
		".030.....",
		".030.....",
		"..00.....",
	]},
}

var void_color := Color("060914")
var deep_color := Color("0b1020")
var ink_color := Color("111629")
var ink_soft_color := Color("1b2238")
var wall_alt_color := Color("202840")
var slate_color := Color("26334d")
var slate_light_color := Color("364765")
var floor_mist_color := Color("303a54")
var floor_petrol_color := Color("294654")
var floor_plum_color := Color("40344f")
var accent_color := Color("f0ad4e")
var safe_color := Color("6de5df")
var danger_color := Color("c04a5d")
var enemy_color := Color("c04a5d")
var enemy_accent_color := Color("f0ad4e")
var gate_color := Color("6b5268")
var paper_color := Color("e8edf5")
var muted_color := Color("9aa8bd")
var fallback_color := Color("6e4b8b")

var walkable: Dictionary = {}
var water_cells: Dictionary = {}
var solid_cells: Dictionary = {}
var flow: Dictionary = {}
var shards: Array[Dictionary] = []
var enemies: Array[Dictionary] = []
var bottle_sources: Array[Dictionary] = []
var litter: Array[Dictionary] = []
var item_count := 0
var item_inventory: Dictionary = {}
var effects: Array[Dictionary] = []
var player_position := Vector2.ZERO
var player_facing := Vector2(1.0, 1.0).normalized()
var health := MAX_HEALTH
var shards_collected := 0
var bottle_count := 0
var bottle_inventory: Dictionary = {}
var has_life_jacket := false
var life_jacket_on_ground := false
var life_jacket_position := Vector2.ZERO
var craft_selected := 0
var pickup_selected := 0
var recipe_index := 0
var has_fishing_catcher := false
var craft_slots: Array[int] = []
var state := "playing"
var message := ""
var message_timer := 0.0
var elapsed := 0.0
var walk_animation := 0.0
var attack_cooldown := 0.0
var player_running := false
var player_jumping := false
var player_jump_time := 0.0
const JUMP_DURATION := 0.5
const JUMP_HEIGHT := 18.0
var invulnerability := 0.0
var shake_strength := 0.0
var screen_shake := Vector2.ZERO
var last_player_cell := Vector2i(-999, -999)
var ui_font: Font
var random := RandomNumberGenerator.new()
var map_rows: Array = []
var shard_cells: Array = []
var enemy_spawns: Array = []
var start_cell := Vector2i.ZERO
var exit_cell := Vector2i.ZERO
var level_index := 0
var selected_level := 0
var level_kind := "surface"
var level_name := "RIVER RUN"
var enemy_kind := "shardling"
var enemy_health := 2
var enemy_speed := ENEMY_SPEED
var camera_offset := Vector2.ZERO
var camera_zoom := 1.0
var camera_angle := 0.0
var camera_target := Vector2.ZERO
var camera_dragging := false
var camera_drag_origin := Vector2.ZERO
var camera_drag_start := Vector2.ZERO

func _ready() -> void:
	random.seed = 260925
	ui_font = SystemFont.new()
	ui_font.font_names = PackedStringArray(["DejaVu Sans", "sans-serif"])
	reset_game()
	open_level_select()

func reset_game() -> void:
	level_index = 0
	load_level(level_index)

func open_level_select() -> void:
	selected_level = level_index
	state = "level_select"
	message_timer = 0.0

func move_level_selection(step: int) -> void:
	selected_level = posmod(selected_level + step, LEVELS.size())

func confirm_level_selection() -> void:
	load_level(selected_level)

func close_level_select() -> void:
	state = "playing"

func load_level(index: int) -> void:
	level_index = clampi(index, 0, LEVELS.size() - 1)
	selected_level = level_index
	var level: Dictionary = LEVELS[level_index]
	level_name = String(level["name"])
	level_kind = String(level.get("kind", "dungeon"))
	var rows: Array = level["map"]
	map_rows = rows
	var configured_shards: Array = level["shards"]
	shard_cells = configured_shards
	var configured_spawns: Array = level["spawns"]
	enemy_spawns = configured_spawns
	start_cell = Vector2i(level["start"])
	exit_cell = Vector2i(level["exit"])
	enemy_kind = String(level.get("enemy_kind", "shardling"))
	enemy_health = int(level.get("enemy_health", 2))
	enemy_speed = float(level.get("enemy_speed", ENEMY_SPEED))
	apply_level_colors(level)
	build_walkable()
	player_position = Vector2(start_cell) + Vector2(0.5, 0.5)
	player_facing = Vector2(1.0, 1.0).normalized()
	health = MAX_HEALTH
	shards_collected = 0
	bottle_count = 0
	has_life_jacket = false
	has_fishing_catcher = false
	life_jacket_on_ground = false
	life_jacket_position = Vector2.ZERO
	state = "playing"
	if level_kind == "surface":
		message = "Search bins with F • press B to craft"
	elif level_index == 1:
		message = "Recover the three light shards"
	else:
		message = "Descend to " + level_name
	message_timer = 3.0
	elapsed = 0.0
	walk_animation = 0.0
	attack_cooldown = 0.0
	invulnerability = 0.0
	shake_strength = 0.0
	screen_shake = Vector2.ZERO
	camera_offset = Vector2.ZERO
	camera_zoom = DEFAULT_CAMERA_ZOOM
	camera_angle = 0.0
	camera_target = player_position
	camera_dragging = false
	last_player_cell = Vector2i(-999, -999)
	shards.clear()
	enemies.clear()
	bottle_sources.clear()
	litter.clear()
	item_count = 0
	item_inventory.clear()
	bottle_inventory.clear()
	solid_cells.clear()
	effects.clear()
	craft_selected = 0
	craft_slots.clear()
	for source_data in level.get("sources", []):
		var source: Dictionary = source_data
		bottle_sources.append(source.duplicate(true))
		bottle_inventory[String(source["kind"])] = 0
		solid_cells[Vector2i(source["cell"])] = true
	for shard_index in range(shard_cells.size()):
		var cell: Vector2i = shard_cells[shard_index]
		shards.append({
			"position": Vector2(cell) + Vector2(0.5, 0.5),
			"taken": false,
			"phase": shard_index * 1.7,
		})
	for item_index in range(level.get("litter", []).size()):
		var item_data: Dictionary = level["litter"][item_index]
		litter.append({
			"kind": String(item_data["kind"]),
			"position": Vector2(item_data["cell"]) + Vector2(0.5, 0.5),
			"phase": item_index * 1.3,
		})
	rebuild_flow()
	for spawn_index in range(enemy_spawns.size()):
		var cell: Vector2i = enemy_spawns[spawn_index]
		if not walkable.has(cell) or not flow.has(cell):
			continue
		var enemy_index := enemies.size()
		enemies.append({
			"position": Vector2(cell) + Vector2(0.5, 0.5),
			"kind": enemy_kind,
			"health": enemy_health,
			"speed": enemy_speed,
			"hit_flash": 0.0,
			"attack_cooldown": 0.45 + enemy_index * 0.08,
			"phase": enemy_index * 0.9,
		})

func apply_level_colors(level: Dictionary) -> void:
	void_color = Color(String(level["void"]))
	deep_color = Color(String(level["deep"]))
	ink_color = Color(String(level["ink"]))
	ink_soft_color = Color(String(level["ink_soft"]))
	wall_alt_color = Color(String(level["wall_alt"]))
	slate_color = Color(String(level["slate"]))
	slate_light_color = Color(String(level["slate_light"]))
	floor_mist_color = Color(String(level["floor_mist"]))
	floor_petrol_color = Color(String(level["floor_petrol"]))
	floor_plum_color = Color(String(level["floor_plum"]))
	accent_color = Color(String(level["accent"]))
	safe_color = Color(String(level["safe"]))
	danger_color = Color(String(level["danger"]))
	enemy_color = Color(String(level["enemy"]))
	enemy_accent_color = Color(String(level["enemy_accent"]))
	gate_color = Color(String(level["gate"]))
	paper_color = Color(String(level["paper"]))
	muted_color = Color(String(level["muted"]))
	fallback_color = floor_plum_color.lightened(0.15)

func build_walkable() -> void:
	walkable.clear()
	water_cells.clear()
	for y in range(map_rows.size()):
		var row: String = map_rows[y]
		for x in range(row.length()):
			var cell := Vector2i(x, y)
			if row[x] != "#":
				walkable[cell] = true
			if row[x] == "~":
				water_cells[cell] = true

func _process(delta: float) -> void:
	elapsed += delta
	message_timer = maxf(0.0, message_timer - delta)
	attack_cooldown = maxf(0.0, attack_cooldown - delta)
	invulnerability = maxf(0.0, invulnerability - delta)
	if player_jumping:
		player_jump_time += delta
		if player_jump_time >= JUMP_DURATION:
			player_jumping = false
	if shake_strength > 0.0:
		shake_strength = maxf(0.0, shake_strength - delta * 2.2)
		screen_shake = Vector2(random.randf_range(-1.0, 1.0), random.randf_range(-1.0, 1.0)) * shake_strength * 7.0
	else:
		screen_shake = Vector2.ZERO
	if state == "playing":
		update_player(delta)
		if level_kind == "surface":
			update_surface_level()
		else:
			update_enemies(delta)
			collect_shards()
		update_camera(delta)
	update_effects(delta)
	queue_redraw()

func update_player(delta: float) -> void:
	var input_direction := Vector2(
		float(Input.is_physical_key_pressed(KEY_D) or Input.is_physical_key_pressed(KEY_RIGHT)) - float(Input.is_physical_key_pressed(KEY_A) or Input.is_physical_key_pressed(KEY_LEFT)),
		float(Input.is_physical_key_pressed(KEY_S) or Input.is_physical_key_pressed(KEY_DOWN)) - float(Input.is_physical_key_pressed(KEY_W) or Input.is_physical_key_pressed(KEY_UP))
	)
	if input_direction.length_squared() > 0.0:
		input_direction = input_direction.normalized()
		var world_direction := Vector2(
			input_direction.x + input_direction.y,
			input_direction.y - input_direction.x
		).normalized().rotated(-camera_angle)
		var before_move := player_position
		player_position = move_with_collisions(player_position, world_direction * PLAYER_SPEED * delta, 0.22)
		if level_kind == "surface" and not has_life_jacket and player_position == before_move and message_timer <= 0.0:
			if water_cells.has(cell_at(player_position + world_direction * 0.55)):
				message = "The river is too deep — find a life jacket"
				message_timer = 2.4
		player_facing = world_direction
		player_running = Input.is_physical_key_pressed(KEY_SHIFT)
		walk_animation += delta * (13.0 if player_running else 8.0)
		var current_cell := cell_at(player_position)
		if current_cell != last_player_cell:
			last_player_cell = current_cell
			rebuild_flow()
	else:
		player_running = false
	if level_kind == "surface" and state == "playing" and not player_jumping and Input.is_physical_key_pressed(KEY_SPACE):
		player_jumping = true
		player_jump_time = 0.0
	if level_kind != "surface" and Input.is_physical_key_pressed(KEY_SPACE):
		attack()

func move_with_collisions(current: Vector2, movement: Vector2, radius: float) -> Vector2:
	var candidate := current + movement
	if can_occupy(candidate, radius):
		return candidate
	var horizontal := Vector2(candidate.x, current.y)
	if can_occupy(horizontal, radius):
		return horizontal
	var vertical := Vector2(current.x, candidate.y)
	if can_occupy(vertical, radius):
		return vertical
	return current

func can_occupy(position: Vector2, radius: float) -> bool:
	for offset: Vector2 in [Vector2(-radius, -radius), Vector2(radius, -radius), Vector2(-radius, radius), Vector2(radius, radius)]:
		var probe: Vector2 = position + offset
		var cell := cell_at(probe)
		if not walkable.has(cell):
			return false
		if solid_cells.has(cell):
			return false
		if water_cells.has(cell) and not has_life_jacket:
			return false
	return true

func cell_at(position: Vector2) -> Vector2i:
	return Vector2i(int(floor(position.x)), int(floor(position.y)))

func rebuild_flow() -> void:
	flow.clear()
	var start := cell_at(player_position)
	if not walkable.has(start):
		return
	flow[start] = 0
	var queue: Array[Vector2i] = [start]
	var directions := [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]
	while not queue.is_empty():
		var current: Vector2i = queue.pop_front()
		for direction in directions:
			var neighbor: Vector2i = current + direction
			if walkable.has(neighbor) and not flow.has(neighbor):
				flow[neighbor] = int(flow[current]) + 1
				queue.append(neighbor)

func best_flow_step(current: Vector2i) -> Vector2i:
	var best := current
	var best_distance := int(flow.get(current, 9999))
	for direction in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
		var neighbor: Vector2i = current + direction
		if flow.has(neighbor) and int(flow[neighbor]) < best_distance:
			best = neighbor
			best_distance = int(flow[neighbor])
	return best

func update_enemies(delta: float) -> void:
	for enemy in enemies:
		enemy["hit_flash"] = maxf(0.0, float(enemy["hit_flash"]) - delta)
		enemy["attack_cooldown"] = maxf(0.0, float(enemy["attack_cooldown"]) - delta)
		var enemy_position: Vector2 = enemy["position"]
		var distance := enemy_position.distance_to(player_position)
		if distance < 0.72:
			if float(enemy["attack_cooldown"]) <= 0.0:
				enemy["attack_cooldown"] = 0.9
				hurt_player()
			continue
		var current := cell_at(enemy_position)
		var next := best_flow_step(current)
		if next == current:
			continue
		var target := Vector2(next) + Vector2(0.5, 0.5)
		var movement := (target - enemy_position).normalized() * float(enemy["speed"]) * delta
		var candidate := move_with_collisions(enemy_position, movement, 0.2)
		if can_occupy(candidate, 0.2):
			enemy["position"] = candidate

func attack() -> void:
	if state != "playing" or attack_cooldown > 0.0:
		return
	attack_cooldown = ATTACK_COOLDOWN
	effects.append({
		"kind": "slash",
		"position": player_position,
		"direction": player_facing,
		"age": 0.0,
		"life": 0.2,
		"phase": 0.0,
		"color": accent_color,
	})
	var connected := false
	for index in range(enemies.size() - 1, -1, -1):
		var enemy := enemies[index]
		var enemy_position: Vector2 = enemy["position"]
		var offset := enemy_position - player_position
		var distance := offset.length()
		var in_facing := distance < 0.001 or player_facing.dot(offset / distance) > 0.05
		if distance <= 1.2 and in_facing:
			connected = true
			enemy["health"] = int(enemy["health"]) - 1
			enemy["hit_flash"] = 0.18
			spawn_burst(enemy_position, safe_color)
			if int(enemy["health"]) <= 0:
				spawn_burst(enemy_position, danger_color, 10)
				enemies.remove_at(index)
	if connected:
		add_shake(0.28)

func hurt_player() -> void:
	if state != "playing" or invulnerability > 0.0:
		return
	health = maxi(0, health - 1)
	invulnerability = 0.85
	add_shake(0.5)
	spawn_burst(player_position, danger_color)
	if health <= 0:
		state = "lost"
		message = "The depths reclaimed the light"
		message_timer = 99.0

func collect_shards() -> void:
	for shard in shards:
		if not bool(shard["taken"]) and player_position.distance_to(shard["position"]) < 0.62:
			shard["taken"] = true
			shards_collected += 1
			health = mini(MAX_HEALTH, health + 1)
			spawn_burst(shard["position"], safe_color, 12)
			add_shake(0.22)
			if shards_collected >= shard_cells.size():
				message = "The gate is open — find the exit"
				message_timer = 4.0
			else:
				message = "Light shard " + str(shards_collected) + " / " + str(shard_cells.size())
				message_timer = 2.2
	var exit_position := Vector2(exit_cell) + Vector2(0.5, 0.5)
	if shards_collected >= shard_cells.size() and player_position.distance_to(exit_position) < 0.56:
		if level_index < LEVELS.size() - 1:
			load_level(level_index + 1)
		else:
			state = "won"
			message = "All depths are clear"
			message_timer = 99.0

const ITEM_ORDER := ["leaves", "plastic wrapper", "rope", "wood scrap", "coiled spring"]
const ITEM_LABELS := {
	"leaves": "LEAVES",
	"plastic wrapper": "PLASTIC WRAPPERS",
	"rope": "ROPE",
	"wood scrap": "WOOD SCRAPS",
	"coiled spring": "COILED SPRINGS",
}
# Buildable recipes. "bottles" groups every empty bottle source; other keys
# are item kinds (ITEM_ORDER). Add a new entry here to offer another build.
const RECIPES := [
	{
		"id": "life_jacket",
		"name": "LIFE JACKET",
		"blurb": "Eight empty bottles for a flotation jacket",
		"needs": {"bottles": 8},
	},
	{
		"id": "fishing_catcher",
		"name": "FISHING CATCHER",
		"blurb": "Rope, wood, wrapper and spring for a river catch",
		"needs": {"rope": 2, "wood scrap": 1, "plastic wrapper": 1, "coiled spring": 1},
	},
]

func nearest_litter_index() -> int:
	var best := -1
	var best_distance := SOURCE_REACH
	for index in range(litter.size()):
		var distance := player_position.distance_to(litter[index]["position"])
		if distance <= best_distance:
			best = index
			best_distance = distance
	return best

func pickable_litter_entries() -> Array:
	var entries: Array = []
	var seen: Dictionary = {}
	for index in range(litter.size()):
		var position: Vector2 = litter[index]["position"]
		if player_position.distance_to(position) > SOURCE_REACH:
			continue
		var kind := String(litter[index]["kind"])
		if seen.has(kind):
			var entry: Dictionary = entries[seen[kind]]
			entry["count"] = int(entry["count"]) + 1
		else:
			seen[kind] = entries.size()
			entries.append({"kind": kind, "count": 1, "distance": player_position.distance_to(position)})
	entries.sort_custom(func(a, b): return float(a["distance"]) < float(b["distance"]))
	return entries

func pick_litter_kind(pick_kind: String) -> int:
	if state != "playing" or level_kind != "surface":
		return 0
	var picked := 0
	for index in range(litter.size() - 1, -1, -1):
		var item := litter[index]
		if String(item["kind"]) != pick_kind:
			continue
		if player_position.distance_to(item["position"]) > SOURCE_REACH:
			continue
		litter.remove_at(index)
		picked += 1
		item_inventory[pick_kind] = int(item_inventory.get(pick_kind, 0)) + 1
		spawn_burst(item["position"], safe_color, 6)
	if picked > 0:
		item_count += picked
		if picked == 1:
			message = "You pick up " + String(ITEM_PHRASES[pick_kind])
		else:
			message = "You pick up " + str(picked) + " " + String(ITEM_PLURALS[pick_kind])
		message_timer = 2.0
		add_shake(0.1)
	return picked

func try_pick_litter() -> void:
	var entries := pickable_litter_entries()
	if entries.is_empty():
		search_bottle_source()
		return
	var total := 0
	for entry in entries:
		total += int(entry["count"])
	if total > 1:
		pickup_selected = 0
		state = "pickup_select"
		message_timer = 0.0
	else:
		pick_litter_kind(String(entries[0]["kind"]))

func confirm_pickup_selection() -> void:
	if state != "pickup_select":
		return
	var entries := pickable_litter_entries()
	if entries.is_empty():
		state = "playing"
		return
	var entry: Dictionary = entries[clampi(pickup_selected, 0, entries.size() - 1)]
	state = "playing"
	pick_litter_kind(String(entry["kind"]))

func close_pickup_select() -> void:
	if state != "pickup_select":
		return
	state = "playing"
	message_timer = 0.0

func search_bottle_source() -> void:
	if state != "playing" or level_kind != "surface":
		return
	var nearest_index := -1
	var nearest_distance := SOURCE_REACH
	for index in range(bottle_sources.size()):
		var source: Dictionary = bottle_sources[index]
		if int(source["charges"]) <= 0:
			continue
		var source_position := Vector2(source["cell"]) + Vector2(0.5, 0.5)
		var distance := player_position.distance_to(source_position)
		if distance <= nearest_distance:
			nearest_index = index
			nearest_distance = distance
	if nearest_index < 0:
		for source_data in bottle_sources:
			var nearby_source: Dictionary = source_data
			var nearby_position := Vector2(nearby_source["cell"]) + Vector2(0.5, 0.5)
			if player_position.distance_to(nearby_position) <= SOURCE_REACH:
				message = "This source is empty — find another"
				message_timer = 2.0
				return
		message = "Move closer to a bottle source"
		message_timer = 2.0
		return
	var source: Dictionary = bottle_sources[nearest_index]
	var source_kind := String(source["kind"])
	var found_bottles := int(source["bottles"])
	bottle_count += found_bottles
	bottle_inventory[source_kind] = int(bottle_inventory.get(source_kind, 0)) + found_bottles
	source["charges"] = int(source["charges"]) - 1
	var source_position := Vector2(source["cell"]) + Vector2(0.5, 0.5)
	var found_message := "You find " + str(found_bottles) + " empty bottles"
	if String(source["kind"]) == "dustbin":
		found_message = "You sift through leaves and find " + str(found_bottles) + " empty bottles"
	elif String(source["kind"]) == "bag":
		found_message = "You untie the trash bag and find " + str(found_bottles) + " empty bottles"
	elif String(source["kind"]) == "compost":
		found_message = "You dig through the compost and find " + str(found_bottles) + " empty bottles"
	var item_pool: Array = SOURCE_ITEMS.get(source_kind, [])
	if not item_pool.is_empty():
		var found_item := String(item_pool[random.randi_range(0, item_pool.size() - 1)])
		found_message += " and " + String(ITEM_PHRASES[found_item])
	message = found_message + " — " + str(total_collected_items()) + " / " + str(LIFE_JACKET_BOTTLES)
	message_timer = 2.8
	spawn_burst(source_position, safe_color, 10)
	add_shake(0.16)

func open_craft_table() -> void:
	if state != "playing" or level_kind != "surface":
		return
	craft_slots.clear()
	craft_selected = 0
	recipe_index = 0
	state = "crafting"
	message_timer = 0.0

func close_craft_table() -> void:
	if state != "crafting":
		return
	craft_slots.clear()
	state = "playing"
	message_timer = 0.0

func craft_element_count() -> int:
	return bottle_sources.size() + ITEM_ORDER.size()

func craft_element_kind(element_index: int) -> String:
	if element_index < bottle_sources.size():
		return String(bottle_sources[element_index]["kind"])
	return String(ITEM_ORDER[element_index - bottle_sources.size()])

func craft_element_inventory(element_index: int) -> Dictionary:
	return bottle_inventory if element_index < bottle_sources.size() else item_inventory

func craft_element_available(element_index: int) -> int:
	if element_index < 0 or element_index >= craft_element_count():
		return 0
	var inventory := craft_element_inventory(element_index)
	var kind := craft_element_kind(element_index)
	var reserved := 0
	for slot in craft_slots:
		if slot == element_index:
			reserved += 1
	return maxi(0, int(inventory.get(kind, 0)) - reserved)

func craft_visible_elements() -> Array:
	var visible: Array = []
	for element_index in range(craft_element_count()):
		var inventory := craft_element_inventory(element_index)
		var kind := craft_element_kind(element_index)
		if int(inventory.get(kind, 0)) > 0 or craft_slots.has(element_index):
			visible.append(element_index)
	return visible

func total_collected_items() -> int:
	var total := bottle_count
	for value in item_inventory.values():
		total += int(value)
	return total

func recipe_needs(index: int) -> Dictionary:
	return RECIPES[clampi(index, 0, RECIPES.size() - 1)]["needs"]

func recipe_slot_targets(index: int) -> Array:
	var targets: Array = []
	var needs := recipe_needs(index)
	for kind in needs:
		var count: int = needs[kind]
		for i in range(count):
			targets.append(String(kind))
	return targets

func recipe_built(index: int) -> bool:
	match String(RECIPES[clampi(index, 0, RECIPES.size() - 1)]["id"]):
		"life_jacket":
			return has_life_jacket
		"fishing_catcher":
			return has_fishing_catcher
		_:
			return false

func craft_build_kind(element_index: int) -> String:
	if element_index < bottle_sources.size():
		return "bottles"
	return craft_element_kind(element_index)

func recipe_kind_label(kind: String) -> String:
	if kind == "bottles":
		return "EMPTY BOTTLES"
	return String(ITEM_LABELS.get(kind, "ITEMS"))

func switch_recipe(step: int) -> void:
	craft_slots.clear()
	recipe_index = clampi(recipe_index + step, 0, RECIPES.size() - 1)
	clamp_craft_selection()
	message_timer = 0.0

func clamp_craft_selection() -> void:
	craft_selected = clampi(craft_selected, 0, maxi(0, craft_visible_elements().size() - 1))

func add_craft_element() -> void:
	if state != "crafting":
		return
	if recipe_built(recipe_index):
		message = String(RECIPES[recipe_index]["name"]) + " is already built"
		message_timer = 2.0
		return
	var targets := recipe_slot_targets(recipe_index)
	var visible := craft_visible_elements()
	if visible.is_empty():
		message = "Nothing collected yet — search garbage with F"
		message_timer = 2.0
		return
	var element_index: int = visible[clampi(craft_selected, 0, visible.size() - 1)]
	var build_kind := craft_build_kind(element_index)
	var need_count := 0
	for kind in targets:
		if kind == build_kind:
			need_count += 1
	if need_count == 0:
		message = "This item is not used to build " + String(RECIPES[recipe_index]["name"])
		message_timer = 2.0
		return
	var added_count := 0
	for slot in craft_slots:
		if craft_build_kind(slot) == build_kind:
			added_count += 1
	if added_count >= need_count:
		message = "No more room for " + recipe_kind_label(build_kind)
		message_timer = 2.0
		return
	if craft_element_available(element_index) <= 0:
		message = "No more " + recipe_kind_label(build_kind) + " in your stash"
		message_timer = 2.0
		return
	craft_slots.append(element_index)
	message_timer = 0.0

func remove_last_craft_element() -> void:
	if state != "crafting" or craft_slots.is_empty():
		return
	craft_slots.pop_back()
	clamp_craft_selection()
	message_timer = 0.0

func combine_craft_elements() -> void:
	if state != "crafting":
		return
	if recipe_built(recipe_index):
		close_craft_table()
		message = String(RECIPES[recipe_index]["name"]) + " is already built"
		message_timer = 2.0
		return
	var targets := recipe_slot_targets(recipe_index)
	if craft_slots.size() < targets.size():
		message = "Can't create — " + str(targets.size() - craft_slots.size()) + " more items required"
		message_timer = 2.0
		return
	for slot in craft_slots:
		var inventory := craft_element_inventory(slot)
		var kind := craft_element_kind(slot)
		inventory[kind] = maxi(0, int(inventory.get(kind, 0)) - 1)
		if slot < bottle_sources.size():
			bottle_count = maxi(0, bottle_count - 1)
	match String(RECIPES[recipe_index]["id"]):
		"life_jacket":
			has_life_jacket = true
			life_jacket_on_ground = false
			message = "Life jacket woven — the river is passable"
		"fishing_catcher":
			has_fishing_catcher = true
			message = "Fishing catcher crafted — take it to the river"
		_:
			message = "Crafted!"
	craft_slots.clear()
	state = "playing"
	message_timer = 3.0
	spawn_burst(player_position, safe_color, 18)
	add_shake(0.32)

func drop_life_jacket() -> void:
	if state != "playing" or level_kind != "surface" or not has_life_jacket:
		return
	has_life_jacket = false
	life_jacket_on_ground = true
	life_jacket_position = player_position
	message = "Life jacket dropped — press G nearby to pick it up"
	message_timer = 2.8
	spawn_burst(life_jacket_position, accent_color, 10)
	add_shake(0.16)

func pick_up_life_jacket() -> bool:
	if not life_jacket_on_ground:
		return false
	if player_position.distance_to(life_jacket_position) > 0.85:
		message = "Move closer to the dropped life jacket"
		message_timer = 2.0
		return false
	has_life_jacket = true
	life_jacket_on_ground = false
	if state == "crafting":
		close_craft_table()
	message = "Life jacket equipped"
	message_timer = 2.0
	spawn_burst(player_position, safe_color, 12)
	add_shake(0.18)
	return true

func toggle_life_jacket() -> void:
	if has_life_jacket:
		drop_life_jacket()
	else:
		pick_up_life_jacket()

func update_surface_level() -> void:
	if state != "playing":
		return
	var exit_position := Vector2(exit_cell) + Vector2(0.5, 0.5)
	if player_position.distance_to(exit_position) < 0.56:
		load_level(level_index + 1)

func spawn_burst(position: Vector2, color: Color, count := 8) -> void:
	effects.append({
		"kind": "burst",
		"position": position,
		"direction": Vector2.ZERO,
		"age": 0.0,
		"life": 0.34,
		"phase": count * 0.37,
		"color": color,
	})

func add_shake(strength: float) -> void:
	shake_strength = maxf(shake_strength, strength)

func update_effects(delta: float) -> void:
	for index in range(effects.size() - 1, -1, -1):
		var effect := effects[index]
		effect["age"] = float(effect["age"]) + delta
		if float(effect["age"]) >= float(effect["life"]):
			effects.remove_at(index)

func update_camera(delta: float) -> void:
	var follow_weight := 1.0 - exp(-CAMERA_FOLLOW_RATE * delta)
	camera_target = camera_target.lerp(player_position, follow_weight)

func reset_camera() -> void:
	camera_offset = Vector2.ZERO
	camera_zoom = DEFAULT_CAMERA_ZOOM
	camera_angle = 0.0
	camera_target = player_position
	camera_dragging = false

func set_camera_offset(value: Vector2) -> void:
	camera_offset = Vector2(clampf(value.x, -420.0, 420.0), clampf(value.y, -280.0, 280.0))

func handle_camera_button(event: InputEventMouseButton) -> void:
	if state != "playing":
		return
	if event.button_index == MOUSE_BUTTON_RIGHT or event.button_index == MOUSE_BUTTON_MIDDLE:
		camera_dragging = event.pressed
		camera_drag_origin = event.position
		camera_drag_start = camera_offset
	elif event.pressed and event.button_index == MOUSE_BUTTON_WHEEL_UP:
		camera_zoom = clampf(camera_zoom + 0.08, 0.65, 1.35)
	elif event.pressed and event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
		camera_zoom = clampf(camera_zoom - 0.08, 0.65, 1.35)

func handle_camera_motion(event: InputEventMouseMotion) -> void:
	if state == "playing" and camera_dragging:
		set_camera_offset(camera_drag_start + event.position - camera_drag_origin)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		handle_camera_button(event)
		get_viewport().set_input_as_handled()
		return
	if event is InputEventMouseMotion:
		handle_camera_motion(event)
		if camera_dragging:
			get_viewport().set_input_as_handled()
		return
	if event is InputEventKey and event.pressed and not event.echo:
		var keycode: int = event.physical_keycode if event.physical_keycode != 0 else event.keycode
		if state == "level_select":
			if keycode == KEY_UP or keycode == KEY_W:
				move_level_selection(-1)
			elif keycode == KEY_DOWN or keycode == KEY_S:
				move_level_selection(1)
			elif keycode == KEY_ENTER or keycode == KEY_KP_ENTER or keycode == KEY_SPACE:
				confirm_level_selection()
			elif keycode == KEY_ESCAPE or keycode == KEY_L:
				close_level_select()
		elif state == "pickup_select":
			var pickup_entry_count := pickable_litter_entries().size()
			if keycode == KEY_UP or keycode == KEY_W:
				if pickup_entry_count > 0:
					pickup_selected = posmod(pickup_selected - 1, pickup_entry_count)
			elif keycode == KEY_DOWN or keycode == KEY_S:
				if pickup_entry_count > 0:
					pickup_selected = posmod(pickup_selected + 1, pickup_entry_count)
			elif keycode == KEY_ENTER or keycode == KEY_KP_ENTER or keycode == KEY_SPACE:
				confirm_pickup_selection()
			elif keycode == KEY_ESCAPE or keycode == KEY_B or keycode == KEY_F:
				close_pickup_select()
		elif state == "crafting":
			var craft_visible_count := craft_visible_elements().size()
			if keycode == KEY_TAB:
				switch_recipe(1)
			elif keycode == KEY_UP or keycode == KEY_W:
				if craft_visible_count > 0:
					craft_selected = posmod(craft_selected - 1, craft_visible_count)
			elif keycode == KEY_DOWN or keycode == KEY_S:
				if craft_visible_count > 0:
					craft_selected = posmod(craft_selected + 1, craft_visible_count)
			elif keycode == KEY_SPACE:
				add_craft_element()
			elif keycode == KEY_ENTER or keycode == KEY_KP_ENTER:
				combine_craft_elements()
			elif keycode == KEY_E and life_jacket_on_ground:
				pick_up_life_jacket()
			elif keycode == KEY_X or keycode == KEY_BACKSPACE or keycode == KEY_DELETE:
				remove_last_craft_element()
			elif keycode == KEY_B or keycode == KEY_ESCAPE:
				close_craft_table()
		else:
			if level_kind == "surface" and keycode == KEY_F:
				try_pick_litter()
			elif level_kind == "surface" and keycode == KEY_B:
				open_craft_table()
			elif level_kind == "surface" and keycode == KEY_G:
				toggle_life_jacket()
			elif keycode == KEY_Q:
				camera_angle = clampf(camera_angle + deg_to_rad(15.0), -PI, PI)
			elif keycode == KEY_E:
				camera_angle = clampf(camera_angle - deg_to_rad(15.0), -PI, PI)
			elif keycode == KEY_C:
				reset_camera()
			elif keycode == KEY_L:
				open_level_select()
			elif keycode == KEY_R:
				if state == "won" and level_index == LEVELS.size() - 1:
					reset_game()
				else:
					load_level(level_index)
		get_viewport().set_input_as_handled()

func iso_to_screen(world_position: Vector2) -> Vector2:
	var relative := world_position - camera_target
	var rotated := relative.rotated(camera_angle)
	var projected := Vector2(
		(rotated.x - rotated.y) * TILE_WIDTH * 0.5,
		(rotated.x + rotated.y) * TILE_HEIGHT * 0.5
	)
	return Vector2(round(projected.x * 0.5) * 2.0, round(projected.y * 0.5) * 2.0)

func player_face_name() -> String:
	var facing := player_facing.rotated(-camera_angle)
	if facing.x >= 0.0:
		return "ne" if facing.y < 0.0 else "se"
	return "nw" if facing.y < 0.0 else "sw"

func floor_color(cell: Vector2i) -> Color:
	var value := posmod(cell.x * 3 + cell.y * 5 + cell.x * cell.y, 5)
	match value:
		0:
			return slate_color
		1:
			return slate_light_color
		2:
			return floor_mist_color
		3:
			return floor_petrol_color
		_:
			return floor_plum_color

func _draw() -> void:
	var viewport := get_viewport_rect().size
	draw_rect(Rect2(Vector2.ZERO, viewport), void_color, true)
	draw_atmosphere(viewport)
	draw_set_transform(CAMERA_PIVOT + camera_offset + screen_shake, 0.0, Vector2(camera_zoom, camera_zoom))
	draw_floors()
	draw_depth_sorted()
	draw_effects()
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	draw_hud(viewport)

func draw_atmosphere(viewport: Vector2) -> void:
	if level_kind == "surface":
		draw_surface_atmosphere(viewport)
		return
	var cavern := PackedVector2Array([
		Vector2(92, 270),
		Vector2(640, 8),
		Vector2(1190, 270),
		Vector2(640, 708),
	])
	draw_colored_polygon(cavern, deep_color)
	for index in range(9):
		var start := Vector2(90 + index * 142, 36 + posmod(index * 83, 180))
		draw_line(start, start + Vector2(86, 118), Color(accent_color, 0.08), 1.0)
	for index in range(34):
		var dust := Vector2(fposmod(index * 193.0 + 31.0, viewport.x), fposmod(index * 271.0 + 19.0, viewport.y))
		var pulse := 0.18 + sin(elapsed * 1.4 + index) * 0.08
		draw_circle(dust, 1.0 + float(index % 3) * 0.35, Color(safe_color, pulse))

func draw_surface_atmosphere(viewport: Vector2) -> void:
	draw_rect(Rect2(Vector2.ZERO, viewport), deep_color, true)
	draw_colored_polygon(PackedVector2Array([
		Vector2(0, 338),
		Vector2(190, 248),
		Vector2(360, 326),
		Vector2(548, 220),
		Vector2(752, 326),
		Vector2(958, 238),
		Vector2(viewport.x, 330),
		Vector2(viewport.x, viewport.y),
		Vector2(0, viewport.y),
	]), Color(floor_petrol_color, 0.58))
	draw_colored_polygon(PackedVector2Array([
		Vector2(0, 404),
		Vector2(260, 310),
		Vector2(520, 408),
		Vector2(796, 300),
		Vector2(viewport.x, 410),
		Vector2(viewport.x, viewport.y),
		Vector2(0, viewport.y),
	]), Color(wall_alt_color, 0.72))
	var sun_center := Vector2(916.0, 96.0)
	draw_colored_polygon(PackedVector2Array([
		sun_center + Vector2(0, -36),
		sun_center + Vector2(30, -21),
		sun_center + Vector2(36, 18),
		sun_center + Vector2(0, 36),
		sun_center + Vector2(-36, 18),
		sun_center + Vector2(-30, -21),
	]), Color(accent_color, 0.92))
	for index in range(3):
		var origin := Vector2(132.0 + index * 304.0, 92.0 + float(index % 2) * 72.0)
		draw_colored_polygon(PackedVector2Array([
			origin + Vector2(-66, 12),
			origin + Vector2(-28, -10),
			origin + Vector2(0, 2),
			origin + Vector2(34, -18),
			origin + Vector2(78, 10),
			origin + Vector2(24, 24),
			origin + Vector2(-34, 26),
		]), Color(paper_color, 0.48))
	for index in range(4):
		var origin := Vector2(310.0 + index * 176.0, 172.0 + float(index % 2) * 34.0)
		draw_line(origin, origin + Vector2(10, -6), Color(ink_color, 0.58), 2.0)
		draw_line(origin + Vector2(10, -6), origin + Vector2(20, 1), Color(ink_color, 0.58), 2.0)

func tile_polygon(cell: Vector2i, height := 0.0) -> PackedVector2Array:
	var center := Vector2(cell) + Vector2(0.5, 0.5)
	var points := PackedVector2Array()
	for corner: Vector2 in [
		center + Vector2(-0.5, -0.5),
		center + Vector2(0.5, -0.5),
		center + Vector2(0.5, 0.5),
		center + Vector2(-0.5, 0.5),
	]:
		var point := iso_to_screen(corner)
		point.y -= height
		points.append(point)
	points.append(points[0])
	return points

func wall_faces(floor: PackedVector2Array, top: PackedVector2Array) -> Array[PackedVector2Array]:
	return [
		PackedVector2Array([top[0], top[1], floor[1], floor[0]]),
		PackedVector2Array([top[1], top[2], floor[2], floor[1]]),
		PackedVector2Array([top[2], top[3], floor[3], floor[2]]),
		PackedVector2Array([top[3], top[0], floor[0], floor[3]]),
	]

func draw_floors() -> void:
	for key in walkable:
		var cell: Vector2i = key
		var center := iso_to_screen(Vector2(cell) + Vector2(0.5, 0.5))
		var diamond := tile_polygon(cell)
		if water_cells.has(cell):
			draw_river_tile(cell, center, diamond)
			continue
		var base := floor_color(cell)
		draw_colored_polygon(diamond, base)
		draw_colored_polygon(PackedVector2Array([
			center,
			diamond[1],
			diamond[2],
		]), base.lightened(0.07))
		draw_colored_polygon(PackedVector2Array([
			center,
			diamond[3],
			diamond[2],
		]), base.darkened(0.12))
		draw_polyline(diamond, Color(ink_color, 0.78), 1.0, true)

func draw_river_tile(cell: Vector2i, center: Vector2, diamond: PackedVector2Array) -> void:
	var water := safe_color.darkened(0.38)
	draw_colored_polygon(diamond, water)
	draw_colored_polygon(PackedVector2Array([center, diamond[1], diamond[2]]), water.lightened(0.1))
	draw_colored_polygon(PackedVector2Array([center, diamond[3], diamond[2]]), water.darkened(0.12))
	var drift := fposmod(elapsed * 18.0 + float(cell.y) * 11.0, 34.0) - 17.0
	draw_line(center + Vector2(-27.0 + drift, -3.0), center + Vector2(-5.0 + drift, -3.0), Color(paper_color, 0.52), 2.0)
	draw_line(center + Vector2(2.0 - drift, 7.0), center + Vector2(22.0 - drift, 7.0), Color(paper_color, 0.32), 1.5)
	draw_polyline(diamond, Color(safe_color.lightened(0.22), 0.72), 1.0, true)

func border_cells() -> Dictionary:
	var cells: Dictionary = {}
	var bottom_row := map_rows.size() - 1
	var right_column: int = int(map_rows[0].length()) - 1
	for x in range(map_rows[0].length()):
		cells[Vector2i(x, 0)] = true
		cells[Vector2i(x, bottom_row)] = true
	for y in range(map_rows.size()):
		cells[Vector2i(0, y)] = true
		cells[Vector2i(right_column, y)] = true
	return cells

func wall_render_height(cell: Vector2i) -> float:
	if level_kind == "surface" and border_cells().has(cell):
		return 16.0
	if front_boundary_cells().has(cell):
		return 16.0
	return WALL_HEIGHT

func front_boundary_cells() -> Dictionary:
	var normals := [Vector2(1.0, 0.0), Vector2(0.0, 1.0), Vector2(-1.0, 0.0), Vector2(0.0, -1.0)]
	var depths: Array[float] = []
	for normal: Vector2 in normals:
		var rotated := normal.rotated(camera_angle)
		depths.append((rotated.x + rotated.y) * TILE_HEIGHT * 0.5)
	var primary := 0
	for index in range(1, normals.size()):
		if depths[index] > depths[primary]:
			primary = index
	var previous := posmod(primary - 1, normals.size())
	var next := posmod(primary + 1, normals.size())
	var secondary := previous if depths[previous] >= depths[next] else next
	var cells: Dictionary = {}
	var bottom_row := map_rows.size() - 1
	var right_column: int = int(map_rows[0].length()) - 1
	for edge: int in [primary, secondary]:
		if edge == 0:
			for y in range(map_rows.size()):
				cells[Vector2i(right_column, y)] = true
		elif edge == 1:
			for x in range(map_rows[bottom_row].length()):
				cells[Vector2i(x, bottom_row)] = true
		elif edge == 2:
			for y in range(map_rows.size()):
				cells[Vector2i(0, y)] = true
		else:
			for x in range(map_rows[0].length()):
				cells[Vector2i(x, 0)] = true
	return cells

func wall_drawables() -> Array[Dictionary]:
	var drawables: Array[Dictionary] = []
	for y in range(map_rows.size()):
		var row: String = map_rows[y]
		for x in range(row.length()):
			var cell := Vector2i(x, y)
			if not walkable.has(cell):
				drawables.append({
					"depth": iso_to_screen(Vector2(cell) + Vector2(0.5, 0.5)).y,
					"kind": "wall",
					"cell": cell,
					"height": wall_render_height(cell),
				})
	drawables.sort_custom(func(a, b): return float(a["depth"]) < float(b["depth"]))
	return drawables

func draw_depth_sorted() -> void:
	var drawables := wall_drawables()
	for shard in shards:
		if not bool(shard["taken"]):
			drawables.append({
				"depth": iso_to_screen(shard["position"]).y,
				"kind": "shard",
				"shard": shard,
			})
	for source in bottle_sources:
		drawables.append({
			"depth": iso_to_screen(Vector2(source["cell"]) + Vector2(0.5, 0.5)).y,
			"kind": "source",
			"source": source,
		})
	for item in litter:
		drawables.append({
			"depth": iso_to_screen(item["position"]).y,
			"kind": "litter",
			"item": item,
		})
	drawables.append({
		"depth": iso_to_screen(Vector2(exit_cell) + Vector2(0.5, 0.5)).y,
		"kind": "exit" if level_kind == "surface" else "gate",
	})
	if life_jacket_on_ground:
		drawables.append({
			"depth": iso_to_screen(life_jacket_position).y,
			"kind": "dropped_jacket",
		})
	drawables.append({
		"depth": iso_to_screen(player_position).y,
		"kind": "player",
		"index": -1,
	})
	for index in range(enemies.size()):
		drawables.append({
			"depth": iso_to_screen(enemies[index]["position"]).y,
			"kind": "enemy",
			"index": index,
		})
	drawables.sort_custom(func(a, b): return float(a["depth"]) < float(b["depth"]))
	for drawable in drawables:
		match String(drawable["kind"]):
			"wall":
				var wall_cell: Vector2i = drawable["cell"]
				draw_wall(wall_cell, float(drawable["height"]))
			"shard":
				var shard: Dictionary = drawable["shard"]
				draw_shard(shard)
			"source":
				var source: Dictionary = drawable["source"]
				draw_bottle_source(source)
			"litter":
				var item: Dictionary = drawable["item"]
				draw_litter_item(item)
			"exit":
				draw_surface_exit()
			"gate":
				draw_gate()
			"dropped_jacket":
				draw_dropped_life_jacket()
			"player":
				draw_player()
			"enemy":
				var enemy_index: int = drawable["index"]
				draw_enemy(enemy_index)

func draw_wall(cell: Vector2i, height := WALL_HEIGHT) -> void:
	if level_kind == "surface":
		height = minf(height, 32.0)
	var floor := tile_polygon(cell)
	var top := tile_polygon(cell, height)
	var top_center := iso_to_screen(Vector2(cell) + Vector2(0.5, 0.5))
	top_center.y -= height
	var faces := wall_faces(floor, top)
	var top_color := ink_soft_color if posmod(cell.x + cell.y, 2) == 0 else wall_alt_color
	draw_colored_polygon(faces[0], ink_color.darkened(0.28))
	draw_colored_polygon(faces[3], ink_color.darkened(0.08))
	draw_colored_polygon(faces[1], ink_color.darkened(0.16))
	draw_colored_polygon(faces[2], ink_color)
	draw_colored_polygon(top, top_color)
	draw_colored_polygon(PackedVector2Array([
		top_center,
		top[1],
		top[2],
	]), top_color.lightened(0.08))
	draw_polyline(top, Color("0a0d18"), 1.5, true)
	draw_line(faces[1][0], faces[1][3], Color("0a0d18"), 1.0)
	draw_line(faces[2][0], faces[2][3], Color("0a0d18"), 1.0)

func draw_bottle_source(source: Dictionary) -> void:
	var cell: Vector2i = source["cell"]
	var position := iso_to_screen(Vector2(cell) + Vector2(0.5, 0.5))
	var charges := int(source["charges"])
	var kind := String(source["kind"])
	draw_shadow(position, 34.0, 0.3)
	if kind == "dustbin" or kind == "recycling":
		for index in range(3 + charges):
			var leaf_position := position + Vector2(-22.0 + float(index % 4) * 14.0, -30.0 - float(index / 4) * 9.0)
			draw_leaf(leaf_position, 0.72 + float(index % 2) * 0.12, accent_color if index % 2 == 0 else floor_petrol_color)
		for index in range(1 + charges):
			draw_bottle(position + Vector2(-15.0 + float(index) * 15.0, -39.0 - float(index % 2) * 5.0), 0.72, safe_color)
		var body := gate_color if kind == "dustbin" else safe_color.darkened(0.52)
		draw_colored_polygon(PackedVector2Array([
			position + Vector2(-28, -24),
			position + Vector2(28, -24),
			position + Vector2(23, 29),
			position + Vector2(-23, 29),
		]), body)
		draw_colored_polygon(PackedVector2Array([
			position + Vector2(-28, -24),
			position + Vector2(0, -35),
			position + Vector2(28, -24),
			position + Vector2(0, -13),
		]), body.lightened(0.12))
		draw_polyline(PackedVector2Array([
			position + Vector2(-28, -24),
			position + Vector2(28, -24),
			position + Vector2(23, 29),
			position + Vector2(-23, 29),
			position + Vector2(-28, -24),
		]), ink_color, 1.5, true)
		draw_line(position + Vector2(-8, -31), position + Vector2(-8, -17), ink_color, 3.0)
		draw_line(position + Vector2(8, -31), position + Vector2(8, -17), ink_color, 3.0)
		if kind == "recycling":
			draw_colored_polygon(PackedVector2Array([
				position + Vector2(0, -12),
				position + Vector2(11, 0),
				position + Vector2(0, 18),
				position + Vector2(-11, 0),
			]), safe_color)
	elif kind == "bag":
		for index in range(1 + charges):
			draw_bottle(position + Vector2(-14.0 + float(index) * 14.0, -45.0 - float(index % 2) * 6.0), 0.7, safe_color)
		var bag_body := PackedVector2Array([
			position + Vector2(-27, 17),
			position + Vector2(-29, -10),
			position + Vector2(-15, -24),
			position + Vector2(0, -26),
			position + Vector2(16, -23),
			position + Vector2(28, -6),
			position + Vector2(24, 18),
			position + Vector2(-2, 21),
		])
		draw_colored_polygon(bag_body, ink_soft_color.darkened(0.34))
		draw_colored_polygon(PackedVector2Array([
			bag_body[1],
			bag_body[2],
			bag_body[3],
			position + Vector2(0, -8),
			position + Vector2(-14, -2),
		]), ink_soft_color.darkened(0.14))
		draw_line(position + Vector2(-8, -33), position + Vector2(8, -33), ink_color, 3.0)
		draw_polyline(PackedVector2Array([bag_body[0], bag_body[1], bag_body[2], bag_body[3], bag_body[4], bag_body[5], bag_body[6], bag_body[7], bag_body[0]]), ink_color, 1.5, true)
	elif kind == "compost":
		var mound := PackedVector2Array([
			position + Vector2(-34, 2),
			position + Vector2(-20, -18),
			position + Vector2(0, -24),
			position + Vector2(20, -18),
			position + Vector2(33, 3),
			position + Vector2(16, 19),
			position + Vector2(-16, 19),
		])
		draw_colored_polygon(mound, floor_plum_color.darkened(0.2))
		draw_colored_polygon(PackedVector2Array([
			position + Vector2(0, -24),
			position + Vector2(20, -18),
			position + Vector2(33, 3),
			position + Vector2(16, 19),
		]), floor_plum_color)
		draw_polyline(PackedVector2Array([mound[0], mound[1], mound[2], mound[3], mound[4], mound[5], mound[6], mound[0]]), ink_color, 1.5, true)
		for index in range(1 + charges):
			draw_bottle(position + Vector2(-10.0 + float(index) * 20.0, -36.0 - float(index % 2) * 5.0), 0.72, safe_color)
		for index in range(6 + charges * 2):
			var leaf_position := position + Vector2(-27.0 + float(index) * 10.0, -15.0 + float(index % 3) * 9.0)
			draw_leaf(leaf_position, 0.7 + float(index % 3) * 0.08, accent_color if index % 3 == 0 else floor_petrol_color)
	else:
		var crate_color := floor_plum_color if kind == "crate" else muted_color
		draw_colored_polygon(PackedVector2Array([
			position + Vector2(-31, -18),
			position + Vector2(0, -36),
			position + Vector2(31, -18),
			position + Vector2(0, 0),
		]), crate_color.lightened(0.12))
		draw_colored_polygon(PackedVector2Array([
			position + Vector2(-31, -18),
			position + Vector2(0, 0),
			position + Vector2(0, 34),
			position + Vector2(-31, 16),
		]), crate_color.darkened(0.18))
		draw_colored_polygon(PackedVector2Array([
			position + Vector2(31, -18),
			position + Vector2(0, 0),
			position + Vector2(0, 34),
			position + Vector2(31, 16),
		]), crate_color)
		for index in range(1 + charges):
			draw_bottle(position + Vector2(-17.0 + float(index) * 17.0, -28.0 - float(index % 2) * 4.0), 0.72, safe_color)
		if kind == "crate":
			draw_line(position + Vector2(-20, 8), position + Vector2(-3, 24), crate_color.darkened(0.35), 3.0)
			draw_line(position + Vector2(3, 8), position + Vector2(20, 24), crate_color.darkened(0.35), 3.0)
		else:
			draw_colored_polygon(PackedVector2Array([
				position + Vector2(-32, -19),
				position + Vector2(0, -38),
				position + Vector2(32, -19),
				position + Vector2(0, 1),
			]), paper_color)
	draw_litter(position, kind)
	var source_position := Vector2(cell) + Vector2(0.5, 0.5)
	if charges > 0 and player_position.distance_to(source_position) <= SOURCE_REACH and nearest_litter_index() < 0:
		var prompt := Rect2(position + Vector2(-47, -79), Vector2(94, 23))
		draw_rect(Rect2(prompt.position + Vector2(3, 4), prompt.size), Color(0.0, 0.0, 0.0, 0.2), true)
		draw_rect(prompt, Color(void_color, 0.9), true)
		draw_line(prompt.position, prompt.position + Vector2(prompt.size.x, 0), accent_color, 1.5)
		draw_string(ui_font, prompt.position + Vector2(12, 16), "F  SEARCH", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, paper_color)

func draw_litter_item(item: Dictionary) -> void:
	var position := iso_to_screen(item["position"])
	var bob := sin(elapsed * 3.0 + float(item["phase"])) * 2.0
	draw_shadow(position, 11.0, 0.26)
	match String(item["kind"]):
		"leaves":
			draw_leaf(position + Vector2(-3, -5 + bob), 0.5, floor_petrol_color)
			draw_leaf(position + Vector2(5, -3 - bob), 0.42, accent_color)
		"plastic wrapper":
			draw_plastic_wrapper(position + Vector2(0, -4 + bob))
		"rope":
			draw_rope_coil(position + Vector2(0, -3 + bob))
		"wood scrap":
			draw_wood_scrap(position + Vector2(0, -4 + bob))
		"coiled spring":
			draw_spring(position + Vector2(0, -6 + bob))
	var nearest := nearest_litter_index()
	if nearest >= 0 and litter[nearest]["position"].is_equal_approx(item["position"]):
		var prompt := Rect2(position + Vector2(-75, -100), Vector2(150, 44))
		draw_rect(Rect2(prompt.position + Vector2(3, 4), prompt.size), Color(0.0, 0.0, 0.0, 0.2), true)
		draw_rect(prompt, Color(void_color, 0.92), true)
		draw_line(prompt.position, prompt.position + Vector2(prompt.size.x, 0), safe_color, 1.5)
		draw_string(ui_font, prompt.position + Vector2(16, 18), String(item["kind"]).to_upper(), HORIZONTAL_ALIGNMENT_LEFT, -1, 13, paper_color)
		draw_string(ui_font, prompt.position + Vector2(16, 36), "F  PICK UP", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, muted_color)

func draw_litter(position: Vector2, kind: String) -> void:
	var variety := posmod(kind.hash(), 2147483647)
	for index in range(2):
		var point := position + Vector2(
			-32.0 + float(posmod(variety + index * 23, 65)),
			6.0 + float(posmod(variety / 7 + index * 13, 15))
		)
		match posmod(variety + index * 3, 4):
			0:
				draw_plastic_wrapper(point)
			1:
				draw_rope_coil(point)
			2:
				draw_wood_scrap(point)
			_:
				draw_spring(point)

func draw_item_icon(kind: String, center: Vector2) -> void:
	match kind:
		"leaves":
			draw_leaf(center + Vector2(-3, 0), 0.4, floor_petrol_color)
			draw_leaf(center + Vector2(4, 1), 0.32, accent_color)
		"plastic wrapper":
			draw_plastic_wrapper(center)
		"rope":
			draw_rope_coil(center)
		"wood scrap":
			draw_wood_scrap(center)
		_:
			draw_spring(center)

func draw_plastic_wrapper(center: Vector2) -> void:
	var points := PackedVector2Array([
		center + Vector2(-6, -4),
		center + Vector2(2, -6),
		center + Vector2(7, -1),
		center + Vector2(4, 5),
		center + Vector2(-3, 4),
		center + Vector2(-7, 1),
	])
	draw_colored_polygon(points, Color(muted_color, 0.9).lightened(0.15))
	draw_polyline(PackedVector2Array([points[0], points[1], points[2], points[3], points[4], points[5], points[0]]), ink_color, 1.0, true)
	draw_line(center + Vector2(-3, -2), center + Vector2(3, 1), Color(paper_color, 0.5), 1.0)

func draw_rope_coil(center: Vector2) -> void:
	draw_arc(center, 6.0, 0.0, TAU, 14, floor_plum_color.darkened(0.12), 2.2, true)
	draw_arc(center, 3.2, 0.0, TAU, 10, floor_plum_color.darkened(0.3), 1.6, true)

func draw_wood_scrap(center: Vector2) -> void:
	var points := PackedVector2Array([
		center + Vector2(-10, -2),
		center + Vector2(9, -2),
		center + Vector2(10, 2),
		center + Vector2(-9, 2),
	])
	draw_colored_polygon(points, floor_plum_color.darkened(0.22))
	draw_polyline(PackedVector2Array([points[0], points[1], points[2], points[3], points[0]]), ink_color, 1.0, true)
	draw_line(center + Vector2(-5, 0), center + Vector2(5, 0), ink_color, 1.0)

func draw_spring(center: Vector2) -> void:
	var points := PackedVector2Array()
	for index in range(5):
		points.append(center + Vector2(-5.0 if index % 2 == 0 else 5.0, -8.0 + index * 4.0))
	draw_polyline(points, muted_color.lightened(0.25), 2.0, true)

func draw_bottle(center: Vector2, scale: float, color: Color) -> void:
	var body := PackedVector2Array([
		center + Vector2(-5.0, -14.0) * scale,
		center + Vector2(5.0, -14.0) * scale,
		center + Vector2(6.0, -4.0) * scale,
		center + Vector2(9.0, 3.0) * scale,
		center + Vector2(8.0, 15.0) * scale,
		center + Vector2(-8.0, 15.0) * scale,
		center + Vector2(-9.0, 3.0) * scale,
		center + Vector2(-6.0, -4.0) * scale,
	])
	draw_colored_polygon(body, Color(paper_color, 0.7))
	draw_colored_polygon(PackedVector2Array([body[0], body[1], body[2], body[3], center]), Color(color, 0.34))
	draw_polyline(body, color, maxf(1.0, 1.4 * scale), true)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-4.0, -19.0) * scale,
		center + Vector2(4.0, -19.0) * scale,
		center + Vector2(4.0, -13.0) * scale,
		center + Vector2(-4.0, -13.0) * scale,
	]), color)
	draw_line(center + Vector2(-3.0, 4.0) * scale, center + Vector2(4.0, 4.0) * scale, Color(color, 0.72), maxf(1.0, scale))

func draw_leaf(center: Vector2, scale: float, color: Color) -> void:
	var points := PackedVector2Array([
		center + Vector2(0, -10.0) * scale,
		center + Vector2(8.0, 0) * scale,
		center + Vector2(0, 10.0) * scale,
		center + Vector2(-8.0, 0) * scale,
	])
	draw_colored_polygon(points, color)
	draw_line(center, points[0], color.lightened(0.24), maxf(1.0, scale))

func draw_surface_exit() -> void:
	var position := iso_to_screen(Vector2(exit_cell) + Vector2(0.5, 0.5))
	var glow := safe_color
	draw_shadow(position, 42.0, 0.34)
	draw_colored_polygon(PackedVector2Array([
		position + Vector2(-43, 18),
		position + Vector2(-34, -43),
		position + Vector2(-15, -70),
		position + Vector2(18, -67),
		position + Vector2(41, -33),
		position + Vector2(46, 18),
	]), gate_color)
	draw_colored_polygon(PackedVector2Array([
		position + Vector2(-26, 16),
		position + Vector2(-22, -34),
		position + Vector2(0, -52),
		position + Vector2(24, -31),
		position + Vector2(28, 16),
	]), Color(glow, 0.3))
	draw_colored_polygon(PackedVector2Array([
		position + Vector2(-18, 16),
		position + Vector2(-15, -28),
		position + Vector2(0, -43),
		position + Vector2(17, -26),
		position + Vector2(20, 16),
	]), ink_color)
	draw_line(position + Vector2(0, -42), position + Vector2(0, 12), Color(glow, 0.8), 2.0)
	draw_colored_polygon(PackedVector2Array([
		position + Vector2(-47, 18),
		position + Vector2(-34, -43),
		position + Vector2(-15, -70),
		position + Vector2(-5, -38),
		position + Vector2(-16, 16),
	]), gate_color.lightened(0.12))

func draw_gate() -> void:
	var position := iso_to_screen(Vector2(exit_cell) + Vector2(0.5, 0.5))
	var open := shards_collected >= shard_cells.size()
	var color := safe_color if open else gate_color
	var pulse := 0.5 + sin(elapsed * 3.0) * 0.5
	draw_colored_polygon(PackedVector2Array([
		position + Vector2(-38, 4),
		position + Vector2(0, -32),
		position + Vector2(38, 4),
		position + Vector2(0, 40),
	]), Color(color, 0.07 + pulse * 0.06))
	draw_colored_polygon(PackedVector2Array([
		position + Vector2(-27, -4),
		position + Vector2(-14, -4),
		position + Vector2(-14, -67),
		position + Vector2(-27, -54),
	]), color.darkened(0.28))
	draw_colored_polygon(PackedVector2Array([
		position + Vector2(14, -4),
		position + Vector2(27, -4),
		position + Vector2(27, -54),
		position + Vector2(14, -67),
	]), color.darkened(0.12))
	draw_colored_polygon(PackedVector2Array([
		position + Vector2(-32, -58),
		position + Vector2(0, -82),
		position + Vector2(32, -58),
		position + Vector2(0, -40),
	]), color)
	draw_circle(position + Vector2(0, -58), 4.0 + pulse * 2.0, paper_color)
	if not open:
		for offset in range(3):
			draw_line(position + Vector2(-15 + offset * 15, -58), position + Vector2(-15 + offset * 15, -12), Color(danger_color, 0.55), 3.0)

func draw_shard(shard: Dictionary) -> void:
	var position := iso_to_screen(shard["position"])
	var bob := sin(elapsed * 3.0 + float(shard["phase"])) * 5.0
	var center := position + Vector2(0, -24 + bob)
	draw_shadow(position, 22.0, 0.28)
	draw_crystal(center, 15.0, safe_color)
	for index in range(3):
		var angle := elapsed * 1.8 + float(shard["phase"]) + index * TAU / 3.0
		var orbit := center + Vector2(cos(angle), sin(angle) * 0.42) * 25.0
		draw_circle(orbit, 1.8, Color(paper_color, 0.8))

func draw_player() -> void:
	var base := iso_to_screen(player_position)
	draw_shadow(base, 24.0, 0.38)
	var face := player_face_name()
	var tint := Color.WHITE
	if invulnerability > 0.0 and int(elapsed * 18.0) % 2 == 0:
		tint = Color(1.0, 0.72, 0.76, 0.46)
	# screen-space forward for lean (matches the facing grid)
	var fwd := Vector2(1, -1).normalized()
	match face:
		"se":
			fwd = Vector2(1, 1).normalized()
		"sw":
			fwd = Vector2(-1, 1).normalized()
		"nw":
			fwd = Vector2(-1, -1).normalized()
	var spring := base
	# jump: raise the sprite over a parabola, keep shadow grounded
	if player_jumping:
		spring.y -= absf(sin(player_jump_time / JUMP_DURATION * PI)) * JUMP_HEIGHT
	# run: lean forward slightly
	if player_running and not player_jumping:
		spring += fwd * 2.0
	# hurt: quick recoil shake
	if invulnerability > 0.0:
		spring.x += sin(invulnerability * 40.0) * 3.0
	if face == "nw":
		draw_pixel_sprite("sword_" + face, spring, tint)
	draw_pixel_sprite(face, spring, tint)
	if face != "nw":
		draw_pixel_sprite("sword_" + face, spring, tint)
	if has_life_jacket:
		draw_life_jacket(spring)

# The original 64x64 pixel sprite (assets/player/isometric) is baked into
# PLAYER_PIXELS (shared palette + content grids of every walk frame + sword
# facing). Each opaque pixel draws as a 2x2 rect at the sprite's original
# screen anchor; transparent-boundary pixels get a soft feather so the
# silhouette reads smooth/HD instead of hard-stepped.
func draw_pixel_sprite(art_key: String, position: Vector2, tint: Color) -> void:
	var palette: Array = PLAYER_PIXELS["palette"]
	var frame: Dictionary
	var art = PLAYER_PIXELS[art_key]
	if art is Array:
		var frames: Array = art
		frame = frames[int(walk_animation) % frames.size()]
	else:
		frame = art
	var ox: int = int(frame["ox"])
	var oy: int = int(frame["oy"])
	var rows: Array = frame["rows"]
	var origin := Vector2(position.x - 64.0, position.y - 90.0)
	var scale := 2.0
	var aa := 0.6
	for r in range(rows.size()):
		var row: String = String(rows[r])
		for c in range(row.length()):
			var ch := row[c]
			if ch == ".":
				continue
			var ci := PLAYER_PIXELS_CHARS.find(ch)
			if ci < 0:
				continue
			var base_c: Color = palette[ci]
			var draw_color := Color(base_c.r * tint.r, base_c.g * tint.g, base_c.b * tint.b, base_c.a * tint.a)
			var px := origin + Vector2((ox + c) * scale, (oy + r) * scale)
			draw_rect(Rect2(px, Vector2(scale, scale)), draw_color)
			# feather steps into transparent neighbours
			if not pixel_opaque(rows, c, r - 1):
				draw_rect(Rect2(px.x, px.y - aa, scale, aa), Color(draw_color, draw_color.a * 0.4))
			if not pixel_opaque(rows, c, r + 1):
				draw_rect(Rect2(px.x, px.y + scale, scale, aa), Color(draw_color, draw_color.a * 0.4))
			if not pixel_opaque(rows, c - 1, r):
				draw_rect(Rect2(px.x - aa, px.y, aa, scale), Color(draw_color, draw_color.a * 0.4))
			if not pixel_opaque(rows, c + 1, r):
				draw_rect(Rect2(px.x + scale, px.y, aa, scale), Color(draw_color, draw_color.a * 0.4))

func pixel_opaque(rows: Array, c: int, r: int) -> bool:
	if r < 0 or r >= rows.size():
		return false
	var row: String = String(rows[r])
	if c < 0 or c >= row.length():
		return false
	var ch := row[c]
	return ch != "." and PLAYER_PIXELS_CHARS.find(ch) >= 0


func draw_life_jacket(position: Vector2) -> void:
	for side: float in [-1.0, 1.0]:
		var center := position + Vector2(side * 15.0, -37.0)
		var points := PackedVector2Array([
			center + Vector2(-8, -18),
			center + Vector2(8, -18),
			center + Vector2(10, 17),
			center + Vector2(0, 22),
			center + Vector2(-10, 17),
		])
		draw_colored_polygon(points, safe_color)
		draw_colored_polygon(PackedVector2Array([points[0], center + Vector2(0, -18), points[1], center + Vector2(0, 20)]), safe_color.lightened(0.2))
		draw_polyline(points, ink_color, 1.5, true)
		draw_line(center + Vector2(-8, -8), center + Vector2(8, -8), ink_color, 2.0)

func draw_dropped_life_jacket() -> void:
	var position := iso_to_screen(life_jacket_position)
	draw_shadow(position, 22.0, 0.34)
	for side: float in [-1.0, 1.0]:
		var center := position + Vector2(side * 11.0, -8.0)
		var points := PackedVector2Array([
			center + Vector2(-10, -6),
			center + Vector2(8, -6),
			center + Vector2(13, 0),
			center + Vector2(8, 7),
			center + Vector2(-9, 7),
		])
		draw_colored_polygon(points, safe_color)
		draw_colored_polygon(PackedVector2Array([points[0], points[1], center + Vector2(9, 2), center + Vector2(-8, 4)]), safe_color.lightened(0.2))
		draw_polyline(points, ink_color, 1.5, true)
		draw_line(center + Vector2(-6, 0), center + Vector2(6, 0), ink_color, 2.0)
	if player_position.distance_to(life_jacket_position) <= 0.85:
		var prompt := Rect2(position + Vector2(-48, -57), Vector2(96, 23))
		draw_rect(Rect2(prompt.position + Vector2(3, 4), prompt.size), Color(0.0, 0.0, 0.0, 0.22), true)
		draw_rect(prompt, Color(void_color, 0.92), true)
		draw_line(prompt.position, prompt.position + Vector2(prompt.size.x, 0), safe_color, 1.5)
		draw_string(ui_font, prompt.position + Vector2(14, 16), "G  PICK UP", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, paper_color)

func draw_enemy(index: int) -> void:
	if index < 0 or index >= enemies.size():
		return
	var enemy := enemies[index]
	var position := iso_to_screen(enemy["position"])
	var bob := sin(elapsed * 5.0 + float(enemy["phase"])) * 3.0
	match String(enemy["kind"]):
		"mireling":
			draw_mireling(enemy, position, bob)
		"forge_golem":
			draw_forge_golem(enemy, position, bob)
		"astral_sentry":
			draw_astral_sentry(enemy, position, bob)
		_:
			draw_shardling(enemy, position, bob)

func draw_shardling(enemy: Dictionary, position: Vector2, bob: float) -> void:
	var body_center := position + Vector2(0, -28 + bob)
	var color := paper_color if float(enemy["hit_flash"]) > 0.0 else enemy_color
	draw_shadow(position, 21.0, 0.32)
	draw_crystal(body_center, 23.0, color)
	draw_colored_polygon(PackedVector2Array([
		body_center + Vector2(-18, -9),
		body_center + Vector2(-12, -28),
		body_center + Vector2(-5, -17),
	]), color.lightened(0.12))
	draw_colored_polygon(PackedVector2Array([
		body_center + Vector2(18, -9),
		body_center + Vector2(12, -28),
		body_center + Vector2(5, -17),
	]), color.lightened(0.12))
	draw_circle(body_center + Vector2(-7, -4), 2.4, enemy_accent_color)
	draw_circle(body_center + Vector2(7, -4), 2.4, enemy_accent_color)
	if int(enemy["health"]) == 1:
		draw_crystal(position + Vector2(0, -65), 6.0, enemy_accent_color)

func draw_mireling(enemy: Dictionary, position: Vector2, bob: float) -> void:
	var body_center := position + Vector2(0, -25 + bob)
	var color := paper_color if float(enemy["hit_flash"]) > 0.0 else enemy_color
	draw_shadow(position, 22.0, 0.34)
	draw_crystal(body_center, 22.0, color)
	draw_colored_polygon(PackedVector2Array([
		body_center + Vector2(-21, -5),
		body_center + Vector2(-10, -29),
		body_center + Vector2(-3, -14),
	]), enemy_accent_color)
	draw_colored_polygon(PackedVector2Array([
		body_center + Vector2(21, -5),
		body_center + Vector2(10, -29),
		body_center + Vector2(3, -14),
	]), enemy_accent_color)
	for index in range(3):
		var angle := elapsed * 1.6 + float(index) * TAU / 3.0 + float(enemy["phase"])
		var bubble := body_center + Vector2(cos(angle) * 22.0, sin(angle) * 11.0 - 15.0)
		draw_circle(bubble, 3.0 + float(index % 2), Color(safe_color, 0.72))
	draw_circle(body_center + Vector2(-6, -3), 2.2, paper_color)
	draw_circle(body_center + Vector2(6, -3), 2.2, paper_color)

func draw_forge_golem(enemy: Dictionary, position: Vector2, bob: float) -> void:
	var body_center := position + Vector2(0, -27 + bob)
	var color := paper_color if float(enemy["hit_flash"]) > 0.0 else enemy_color
	draw_shadow(position, 25.0, 0.38)
	draw_colored_polygon(PackedVector2Array([
		body_center + Vector2(-20, -22),
		body_center + Vector2(20, -22),
		body_center + Vector2(24, 17),
		body_center + Vector2(0, 25),
		body_center + Vector2(-24, 17),
	]), color.darkened(0.12))
	draw_colored_polygon(PackedVector2Array([
		body_center + Vector2(-13, -15),
		body_center + Vector2(13, -15),
		body_center + Vector2(16, 11),
		body_center + Vector2(0, 18),
		body_center + Vector2(-16, 11),
	]), color.lightened(0.08))
	draw_colored_polygon(PackedVector2Array([
		body_center + Vector2(0, -10),
		body_center + Vector2(9, 0),
		body_center + Vector2(0, 10),
		body_center + Vector2(-9, 0),
	]), enemy_accent_color)
	draw_line(body_center + Vector2(-18, -25), body_center + Vector2(-25, -39), color, 4.0)
	draw_line(body_center + Vector2(18, -25), body_center + Vector2(25, -39), color, 4.0)
	draw_circle(body_center + Vector2(-7, -2), 2.4, paper_color)
	draw_circle(body_center + Vector2(7, -2), 2.4, paper_color)

func draw_astral_sentry(enemy: Dictionary, position: Vector2, bob: float) -> void:
	var body_center := position + Vector2(0, -29 + bob)
	var color := paper_color if float(enemy["hit_flash"]) > 0.0 else enemy_color
	draw_shadow(position, 22.0, 0.32)
	draw_colored_polygon(PackedVector2Array([
		body_center + Vector2(0, -28),
		body_center + Vector2(9, -8),
		body_center + Vector2(25, 0),
		body_center + Vector2(9, 8),
		body_center + Vector2(0, 28),
		body_center + Vector2(-9, 8),
		body_center + Vector2(-25, 0),
		body_center + Vector2(-9, -8),
	]), color)
	draw_crystal(body_center, 11.0, enemy_accent_color)
	draw_arc(body_center, 28.0, elapsed * 0.8, elapsed * 0.8 + PI * 1.4, 24, Color(safe_color, 0.78), 2.0, true)
	draw_circle(body_center + Vector2(-5, -2), 2.0, paper_color)
	draw_circle(body_center + Vector2(5, -2), 2.0, paper_color)
	if int(enemy["health"]) == 1:
		draw_crystal(position + Vector2(0, -70), 6.0, enemy_accent_color)

func draw_shadow(position: Vector2, radius: float, alpha: float) -> void:
	draw_colored_polygon(PackedVector2Array([
		position + Vector2(-radius, 0),
		position + Vector2(0, -radius * 0.38),
		position + Vector2(radius, 0),
		position + Vector2(0, radius * 0.38),
	]), Color(0.01, 0.015, 0.03, alpha))

func draw_crystal(center: Vector2, radius: float, color: Color) -> void:
	var points := PackedVector2Array([
		center + Vector2(0, -radius),
		center + Vector2(radius * 0.72, 0),
		center + Vector2(0, radius),
		center + Vector2(-radius * 0.72, 0),
		center + Vector2(0, -radius),
	])
	draw_colored_polygon(points, color)
	draw_colored_polygon(PackedVector2Array([
		center,
		points[1],
		points[2],
	]), color.darkened(0.2))
	draw_polyline(points, color.lightened(0.38), 1.5, true)
	draw_line(center, points[0], color.lightened(0.2), 1.0)

func draw_effects() -> void:
	for effect in effects:
		var progress := clampf(float(effect["age"]) / float(effect["life"]), 0.0, 1.0)
		var position := iso_to_screen(effect["position"])
		var color: Color = effect["color"]
		color.a *= 1.0 - progress
		if effect["kind"] == "slash":
			var direction: Vector2 = effect["direction"]
			var rotated_direction := direction.rotated(camera_angle)
			var screen_direction := Vector2(rotated_direction.x - rotated_direction.y, rotated_direction.x + rotated_direction.y).normalized()
			var start_angle := atan2(screen_direction.y, screen_direction.x) - 0.85
			draw_arc(position + Vector2(0, -22), 34.0 + progress * 18.0, start_angle, start_angle + 1.7, 24, color, 7.0 * (1.0 - progress) + 1.0, true)
		else:
			var count := int(effect["phase"])
			for index in range(count):
				var angle := index * TAU / float(count) + float(effect["phase"])
				var from := position + Vector2(cos(angle), sin(angle) * 0.55) * (8.0 + progress * 13.0)
				var to := position + Vector2(cos(angle), sin(angle) * 0.55) * (18.0 + progress * 42.0)
				draw_line(from, to, color, 2.5)

func enemy_display_name(kind: String) -> String:
	match kind:
		"mireling":
			return "MIRELING"
		"forge_golem":
			return "FORGE GOLEM"
		"astral_sentry":
			return "ASTRAL SENTRY"
		_:
			return "SHARDLING"

func draw_level_select(viewport: Vector2) -> void:
	draw_rect(Rect2(Vector2.ZERO, viewport), Color(void_color, 0.9), true)
	var panel := Rect2(170, 42, 940, 636)
	draw_rect(Rect2(panel.position + Vector2(7, 9), panel.size), Color(0.0, 0.0, 0.0, 0.3), true)
	draw_rect(panel, Color(void_color, 0.98), true)
	draw_line(panel.position, panel.position + Vector2(panel.size.x, 0), accent_color, 2.0)
	draw_line(panel.position + Vector2(0, panel.size.y), panel.position + panel.size, Color(accent_color, 0.35), 1.0)
	draw_string(ui_font, Vector2(0, 104), "SELECT LEVEL", HORIZONTAL_ALIGNMENT_CENTER, viewport.x, 40, paper_color)
	draw_string(ui_font, Vector2(0, 138), "Choose a remembered path", HORIZONTAL_ALIGNMENT_CENTER, viewport.x, 16, muted_color)
	for index in range(LEVELS.size()):
		var level: Dictionary = LEVELS[index]
		var selected := index == selected_level
		var surface_level := String(level.get("kind", "dungeon")) == "surface"
		var row := Rect2(220, 180 + index * 88, 840, 68)
		var row_color := accent_color if selected else muted_color
		var row_fill := Color(void_color, 0.98) if selected else Color(ink_color, 0.96)
		draw_rect(Rect2(row.position + Vector2(4, 5), row.size), Color(0.0, 0.0, 0.0, 0.22), true)
		draw_rect(row, row_fill, true)
		draw_line(row.position, row.position + Vector2(row.size.x, 0), row_color if selected else Color(muted_color, 0.35), 2.0 if selected else 1.0)
		draw_hud_diamond(row.position + Vector2(32, 34), 12.0 if selected else 8.0, row_color if selected else Color(muted_color, 0.45))
		draw_string(ui_font, row.position + Vector2(62, 27), "%02d" % index, HORIZONTAL_ALIGNMENT_LEFT, -1, 16, row_color)
		draw_string(ui_font, row.position + Vector2(112, 31), String(level["name"]), HORIZONTAL_ALIGNMENT_LEFT, -1, 22, paper_color if selected else muted_color)
		var detail := "RIVER CROSSING" if surface_level else enemy_display_name(String(level["enemy_kind"]))
		var summary := "BOTTLES  •  CRAFT  •  RIVER" if surface_level else "3 SHARDS  •  5 ENEMIES"
		draw_string(ui_font, row.position + Vector2(112, 52), detail, HORIZONTAL_ALIGNMENT_LEFT, -1, 13, row_color if selected else muted_color)
		draw_string(ui_font, row.position + Vector2(600, 40), summary, HORIZONTAL_ALIGNMENT_LEFT, -1, 13, row_color if selected else muted_color)
	var footer := "W / S or arrows select     ENTER / SPACE play     L / ESC close"
	draw_string(ui_font, Vector2(0, 632), footer, HORIZONTAL_ALIGNMENT_CENTER, viewport.x, 14, muted_color)

func craft_element_label(element_index: int) -> String:
	if element_index < bottle_sources.size():
		var source: Dictionary = bottle_sources[element_index]
		match String(source["kind"]):
			"dustbin":
				return "GARBAGE BOTTLES"
			"recycling":
				return "RECYCLED BOTTLES"
			"crate":
				return "RETURNED BOTTLES"
			"cooler":
				return "COOLER BOTTLES"
			"bag":
				return "TRASH BAG BOTTLES"
			"compost":
				return "COMPOST BOTTLES"
			_:
				return "EMPTY BOTTLES"
	return String(ITEM_LABELS.get(craft_element_kind(element_index), "ITEMS"))

func draw_pickup_select(viewport: Vector2) -> void:
	draw_rect(Rect2(Vector2.ZERO, viewport), Color(void_color, 0.82), true)
	var panel := Rect2(330, 150, 620, 340)
	draw_rect(Rect2(panel.position + Vector2(7, 9), panel.size), Color(0.0, 0.0, 0.0, 0.34), true)
	draw_rect(panel, Color(void_color, 0.98), true)
	draw_line(panel.position, panel.position + Vector2(panel.size.x, 0), safe_color, 2.0)
	draw_line(panel.position + Vector2(0, panel.size.y), panel.position + panel.size, Color(safe_color, 0.35), 1.0)
	draw_string(ui_font, Vector2(0, 104), "CHOOSE ITEM", HORIZONTAL_ALIGNMENT_CENTER, viewport.x, 40, paper_color)
	draw_string(ui_font, Vector2(0, 138), "Several items are nearby", HORIZONTAL_ALIGNMENT_CENTER, viewport.x, 16, muted_color)
	var entries := pickable_litter_entries()
	for row_index in range(entries.size()):
		var entry: Dictionary = entries[row_index]
		var selected := row_index == pickup_selected
		var row := Rect2(370, 196 + row_index * 56, 540, 44)
		var row_color := accent_color if selected else safe_color
		draw_rect(Rect2(row.position + Vector2(4, 5), row.size), Color(0.0, 0.0, 0.0, 0.24), true)
		draw_rect(row, Color(ink_color, 0.96) if not selected else Color(void_color, 0.98), true)
		draw_line(row.position, row.position + Vector2(row.size.x, 0), row_color if selected else Color(muted_color, 0.3), 2.0 if selected else 1.0)
		draw_item_icon(String(entry["kind"]), row.position + Vector2(26, 28))
		draw_string(ui_font, row.position + Vector2(52, 29), String(entry["kind"]).to_upper(), HORIZONTAL_ALIGNMENT_LEFT, -1, 15, paper_color if selected else muted_color)
		draw_string(ui_font, row.position + Vector2(0, 29), "×%02d" % int(entry["count"]), HORIZONTAL_ALIGNMENT_RIGHT, row.size.x - 16, 15, row_color)
	draw_string(ui_font, Vector2(0, 472), "W / S select     ENTER / SPACE pick up     ESC / B close", HORIZONTAL_ALIGNMENT_CENTER, viewport.x, 14, muted_color)

func draw_craft_table(viewport: Vector2) -> void:
	draw_rect(Rect2(Vector2.ZERO, viewport), Color(void_color, 0.82), true)
	var panel := Rect2(230, 52, 820, 616)
	draw_rect(Rect2(panel.position + Vector2(7, 9), panel.size), Color(0.0, 0.0, 0.0, 0.34), true)
	draw_rect(panel, Color(void_color, 0.98), true)
	draw_line(panel.position, panel.position + Vector2(panel.size.x, 0), accent_color, 2.0)
	draw_line(panel.position + Vector2(0, panel.size.y), panel.position + panel.size, Color(accent_color, 0.35), 1.0)
	draw_string(ui_font, Vector2(0, 100), "CRAFTING TABLE", HORIZONTAL_ALIGNMENT_CENTER, viewport.x, 34, paper_color)
	draw_string(ui_font, Vector2(0, 132), "COLLECT MATERIALS  •  CHOOSE WHAT TO BUILD", HORIZONTAL_ALIGNMENT_CENTER, viewport.x, 14, muted_color)
	draw_line(Vector2(270, 158), Vector2(1010, 158), Color(slate_light_color, 0.45), 1.0)
	# ---- recipe selector ----
	draw_string(ui_font, Vector2(278, 180), "BUILD OPTIONS", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, muted_color)
	for recipe_i in range(RECIPES.size()):
		var selected_recipe := recipe_i == recipe_index
		var chip := Rect2(278 + recipe_i * 232, 192, 224, 30)
		var chip_color := accent_color if selected_recipe else safe_color
		draw_rect(Rect2(chip.position + Vector2(3, 4), chip.size), Color(0.0, 0.0, 0.0, 0.24), true)
		draw_rect(chip, Color(ink_color, 0.96) if not selected_recipe else Color(void_color, 0.98), true)
		draw_line(chip.position, chip.position + Vector2(chip.size.x, 0), chip_color if selected_recipe else Color(muted_color, 0.3), 2.0 if selected_recipe else 1.0)
		draw_string(ui_font, chip.position + Vector2(12, 20), String(RECIPES[recipe_i]["name"]), HORIZONTAL_ALIGNMENT_LEFT, -1, 13, paper_color if selected_recipe else muted_color)
		if recipe_built(recipe_i):
			draw_string(ui_font, chip.position + Vector2(0, 20), "BUILT", HORIZONTAL_ALIGNMENT_RIGHT, chip.size.x - 12, 11, safe_color)
	draw_line(Vector2(270, 234), Vector2(1010, 234), Color(slate_light_color, 0.45), 1.0)
	# ---- material palette ----
	draw_string(ui_font, Vector2(278, 254), "ELEMENT SOURCES", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, muted_color)
	var visible_elements := craft_visible_elements()
	if visible_elements.is_empty():
		draw_string(ui_font, Vector2(278, 300), "NOTHING COLLECTED YET", HORIZONTAL_ALIGNMENT_LEFT, -1, 15, paper_color)
		draw_string(ui_font, Vector2(278, 326), "SEARCH GARBAGE WITH F TO FIND ITEMS", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, muted_color)
	else:
		for row_index in range(visible_elements.size()):
			var element_index: int = visible_elements[row_index]
			var row := Rect2(278 + (row_index % 2) * 236, 268 + (row_index / 2) * 42, 230, 38)
			var selected := row_index == craft_selected
			var row_color := accent_color if selected else safe_color
			draw_rect(Rect2(row.position + Vector2(3, 4), row.size), Color(0.0, 0.0, 0.0, 0.24), true)
			draw_rect(row, Color(ink_color, 0.96) if not selected else Color(void_color, 0.98), true)
			draw_line(row.position, row.position + Vector2(row.size.x, 0), row_color if selected else Color(muted_color, 0.3), 2.0 if selected else 1.0)
			if element_index < bottle_sources.size():
				draw_bottle(row.position + Vector2(24, 24), 0.48, row_color)
			else:
				draw_item_icon(craft_element_kind(element_index), row.position + Vector2(22, 24))
			draw_string(ui_font, row.position + Vector2(50, 26), craft_element_label(element_index), HORIZONTAL_ALIGNMENT_LEFT, -1, 12, paper_color if selected else muted_color)
			draw_string(ui_font, row.position + Vector2(0, 26), "×%02d" % craft_element_available(element_index), HORIZONTAL_ALIGNMENT_RIGHT, row.size.x - 12, 15, row_color)
	# ---- build requirement for the selected recipe ----
	var recipe_targets := recipe_slot_targets(recipe_index)
	var recipe_done := craft_slots.size() >= recipe_targets.size()
	draw_string(ui_font, Vector2(760, 254), "BUILDING: " + String(RECIPES[recipe_index]["name"]), HORIZONTAL_ALIGNMENT_LEFT, -1, 15, accent_color)
	draw_string(ui_font, Vector2(760, 278), String(RECIPES[recipe_index]["blurb"]), HORIZONTAL_ALIGNMENT_LEFT, -1, 12, muted_color)
	var needs := recipe_needs(recipe_index)
	var row_y := 304
	for kind in needs:
		var need_count: int = needs[kind]
		var added := 0
		for slot in craft_slots:
			if craft_build_kind(slot) == String(kind):
				added += 1
		var ok := added >= need_count
		var line_color := safe_color if ok else accent_color
		draw_string(ui_font, Vector2(760, row_y), recipe_kind_label(String(kind)) + "   " + str(mini(added, need_count)) + " / " + str(need_count), HORIZONTAL_ALIGNMENT_LEFT, -1, 13, line_color)
		row_y += 24
	var status_color := safe_color if recipe_done else muted_color
	if recipe_built(recipe_index):
		var built_text := String(RECIPES[recipe_index]["name"]) + " — BUILT"
		if recipe_index == 0 and has_life_jacket:
			built_text = "LIFE JACKET — WEARING (G TO DROP)"
		draw_string(ui_font, Vector2(760, row_y + 8), built_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 13, safe_color)
	elif recipe_done:
		draw_string(ui_font, Vector2(760, row_y + 8), "PRESS ENTER TO BUILD", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, paper_color)
	else:
		draw_string(ui_font, Vector2(760, row_y + 8), "ADD MATERIALS", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, muted_color)
	if message_timer > 0.0:
		draw_string(ui_font, Vector2(0, 526), message, HORIZONTAL_ALIGNMENT_CENTER, viewport.x, 15, paper_color)
	var controls_rect := Rect2(300, 574, 680, 56)
	draw_plaque(controls_rect, slate_light_color)
	var controls_text := String("TAB RECIPE     W/S ITEM     SPACE ADD     X REMOVE     ENTER BUILD     B/ESC CLOSE")
	if life_jacket_on_ground:
		controls_text = "E EQUIP LIFE JACKET     " + controls_text
	draw_string(ui_font, Vector2(0, 608), controls_text, HORIZONTAL_ALIGNMENT_CENTER, viewport.x, 13, muted_color)

func draw_hud(viewport: Vector2) -> void:
	if state == "level_select":
		draw_level_select(viewport)
		return
	if state == "pickup_select":
		draw_pickup_select(viewport)
		return
	if state == "crafting":
		draw_craft_table(viewport)
		return
	draw_plaque(Rect2(30, 24, 330, 76), accent_color)
	var title := "RIVER RUN" if level_kind == "surface" else "FACETED DEPTHS"
	draw_string(ui_font, Vector2(50, 57), title, HORIZONTAL_ALIGNMENT_LEFT, -1, 30, paper_color)
	var level_text := "LEVEL 00 / %02d  •  %s" % [LEVELS.size(), level_name] if level_kind == "surface" else "DEPTH %02d / %02d  •  %s" % [level_index, LEVELS.size() - 1, level_name]
	draw_string(ui_font, Vector2(51, 83), level_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 13, accent_color)
	var shard_rect := Rect2(viewport.x - 244, 24, 214, 100) if level_kind == "surface" else Rect2(viewport.x - 244, 24, 214, 76)
	if level_kind == "surface":
		draw_bottle_plaque(shard_rect)
	else:
		draw_plaque(shard_rect, safe_color)
		draw_string(ui_font, shard_rect.position + Vector2(18, 26), "LIGHT SHARDS", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, muted_color)
		for index in range(shard_cells.size()):
			var center := shard_rect.position + Vector2(32 + index * 58, 52)
			if index < shards_collected:
				draw_hud_diamond(center, 13.0, safe_color)
			else:
				draw_hud_diamond(center, 13.0, Color(muted_color, 0.25))
	var health_rect := Rect2(30, viewport.y - 82, 280, 54)
	draw_plaque(health_rect, danger_color)
	draw_string(ui_font, health_rect.position + Vector2(18, 24), "VITALITY", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, muted_color)
	for index in range(MAX_HEALTH):
		var center := health_rect.position + Vector2(112 + index * 29, 27)
		if index < health:
			draw_hud_diamond(center, 10.0, danger_color.lightened(0.08))
		else:
			draw_hud_diamond(center, 10.0, Color(muted_color, 0.2))
	var controls := "WASD MOVE  SHIFT RUN  SPACE JUMP  F SEARCH/PICK  B TABLE  G WEAR/DROP  L LEVELS  R RESTART" if level_kind == "surface" else "WASD MOVE  SPACE STRIKE  DRAG PAN  WHEEL ZOOM  Q/E YAW  C RESET  L LEVELS  R RESTART"
	var controls_size := ui_font.get_string_size(controls, HORIZONTAL_ALIGNMENT_LEFT, -1, 13)
	var controls_rect := Rect2(viewport.x - controls_size.x - 68, viewport.y - 54, controls_size.x + 38, 30)
	draw_plaque(controls_rect, slate_light_color)
	draw_string(ui_font, controls_rect.position + Vector2(19, 20), controls, HORIZONTAL_ALIGNMENT_LEFT, -1, 13, muted_color)
	if message_timer > 0.0:
		draw_message(viewport)
	if state != "playing":
		draw_state_overlay(viewport)

func draw_bottle_plaque(rect: Rect2) -> void:
	draw_plaque(rect, safe_color)
	draw_string(ui_font, rect.position + Vector2(18, 25), "BOTTLES", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, muted_color)
	draw_bottle(rect.position + Vector2(29, 54), 0.58, safe_color)
	draw_string(ui_font, rect.position + Vector2(47, 59), "%02d" % bottle_count, HORIZONTAL_ALIGNMENT_LEFT, -1, 22, paper_color)
	draw_line(rect.position + Vector2(94, 17), rect.position + Vector2(94, 59), Color(muted_color, 0.4), 1.0)
	draw_string(ui_font, rect.position + Vector2(108, 29), "JACKET", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, muted_color)
	var jacket_color := safe_color if has_life_jacket else accent_color
	var jacket_text := str(maxi(0, LIFE_JACKET_BOTTLES - total_collected_items())) + " MORE"
	if total_collected_items() >= LIFE_JACKET_BOTTLES:
		jacket_text = "CAN CRAFT"
	if life_jacket_on_ground:
		jacket_text = "DROPPED"
	if has_life_jacket:
		jacket_text = "WEARING"
	draw_string(ui_font, rect.position + Vector2(108, 55), jacket_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 16, jacket_color)
	draw_line(rect.position + Vector2(18, 72), rect.position + Vector2(rect.size.x - 18, 72), Color(muted_color, 0.4), 1.0)
	draw_leaf(rect.position + Vector2(29, 88), 0.55, floor_petrol_color)
	draw_string(ui_font, rect.position + Vector2(47, 92), "%02d" % total_collected_items(), HORIZONTAL_ALIGNMENT_LEFT, -1, 20, paper_color)
	draw_string(ui_font, rect.position + Vector2(108, 88), "ITEMS", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, muted_color)

func draw_plaque(rect: Rect2, accent: Color) -> void:
	draw_rect(Rect2(rect.position + Vector2(5, 7), rect.size), Color(0.0, 0.0, 0.0, 0.25), true)
	draw_rect(rect, Color(void_color, 0.94), true)
	draw_line(rect.position, rect.position + Vector2(rect.size.x, 0), accent, 2.0)
	draw_line(rect.position + Vector2(0, rect.size.y), rect.position + rect.size, Color(accent, 0.28), 1.0)

func draw_hud_diamond(center: Vector2, radius: float, color: Color) -> void:
	var points := PackedVector2Array([
		center + Vector2(0, -radius),
		center + Vector2(radius * 0.72, 0),
		center + Vector2(0, radius),
		center + Vector2(-radius * 0.72, 0),
	])
	draw_colored_polygon(points, color)
	draw_polyline(PackedVector2Array([points[0], points[1], points[2], points[3], points[0]]), color.lightened(0.3), 1.0, true)

func draw_message(viewport: Vector2) -> void:
	var alpha := clampf(message_timer * 2.0, 0.0, 1.0)
	var text_size := ui_font.get_string_size(message, HORIZONTAL_ALIGNMENT_LEFT, -1, 18)
	var rect := Rect2((viewport.x - text_size.x) * 0.5 - 22, 108, text_size.x + 44, 42)
	draw_rect(Rect2(rect.position + Vector2(3, 5), rect.size), Color(0, 0, 0, 0.22 * alpha), true)
	draw_rect(rect, Color(void_color, 0.92 * alpha), true)
	draw_line(rect.position, rect.position + Vector2(rect.size.x, 0), Color(safe_color, alpha), 2.0)
	draw_string(ui_font, rect.position + Vector2(22, 28), message, HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color(paper_color, alpha))

func draw_state_overlay(viewport: Vector2) -> void:
	draw_rect(Rect2(Vector2.ZERO, viewport), Color(void_color, 0.82), true)
	var center := Vector2(viewport.x * 0.5, viewport.y * 0.48)
	var accent := safe_color if state == "won" else danger_color
	draw_crystal(center + Vector2(0, -76), 42.0 + sin(elapsed * 2.2) * 2.0, accent)
	var title := "THE DEPTHS ARE CLEARED" if state == "won" else "THE LIGHT FADES"
	var subtitle := "All four depths are clear" if state == "won" else "Press R to restart this depth"
	draw_string(ui_font, Vector2(0, center.y + 18), title, HORIZONTAL_ALIGNMENT_CENTER, viewport.x, 42, paper_color)
	draw_string(ui_font, Vector2(0, center.y + 58), subtitle, HORIZONTAL_ALIGNMENT_CENTER, viewport.x, 17, Color(accent, 0.9))
