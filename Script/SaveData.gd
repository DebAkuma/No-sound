class_name SaveData
extends Resource

@export var player_pos : Vector3
@export var enemy_pos : Vector3
@export var items : Array[String] = []
@export var firstGemStone : bool = true
@export var player_rotation : Vector3
@export var enemy_rotation : Vector3
@export var stone_rune_pickUp : bool
@export var bookList : Array[String] = []
@export var SDquestTitle : String
@export var SDquestDetails : String
	

func add_books(book_name : String):
	if bookList == null :
		bookList.append(book_name)
		Global.bookList = bookList
	else:
		for i in bookList.size():
			if bookList[i] != book_name:
				bookList.append(book_name)
				Global.bookList = bookList
	
func add_items(item_id : String):
		# Check if items is empty; if not, avoid duplicates
	if items == null:
		items.append(item_id)
		Global.items = items
	else:
		for i in items.size():
			if items[i] != item_id:
				items.append(item_id)
				Global.items = items

func to_data():
	return{
		"avioubnaiova" : player_pos,
		"mniojo" : enemy_pos,
		"navnbiapojv" : player_rotation,
		"oknpompopo" : enemy_rotation,
		"anaiun98anv" : stone_rune_pickUp,
		"amvi0anvia" : items,
		"nbiotigfok" : bookList,
		"komnmdi" : firstGemStone,
		"haviuaivua" : SDquestTitle,
		"ovmjoavmjio" : SDquestDetails
 	}

func from_data(dat):
	player_pos = dat["avioubnaiova"]
	enemy_pos = dat["mniojo"]
	player_rotation = dat["navnbiapojv"]
	enemy_rotation = dat["oknpompopo"]
	stone_rune_pickUp = dat["anaiun98anv"]
	firstGemStone = dat["komnmdi"]
	SDquestTitle = dat["haviuaivua"]
	SDquestDetails = dat["ovmjoavmjio"]
	items.clear()
	for i in dat["amvi0anvia"]:
		items.append(i)
		
	bookList.clear()
	for i in dat["nbiotigfok"]:
		bookList.append(i)
