-- | A little text-based adventure in haskell
-- This code has been written by JP Moresmau (jp_at_moresmau_dot_fr)
-- This is no copyright at all on it, feel free to reuse
module AdventureGame where

import Char
import qualified Data.Map as DataMap
import qualified Data.List as DataList
import Utils (capitalize)
import System.IO
import System.IO.Error

-- * Types

-- | information about an exit way from a location
data DirectionInfo = DirectionInfo {
		descDir::Description -- ^ the description of the exit
		,locationCode::LocationCode -- ^ the code for the location where the exit goes to
		}
	deriving Show

-- | information about a specific location in the game world
data LocationInfo = LocationInfo {
	descLoc::Description -- ^ the description of the location
	,directions::DirectionMap -- ^ the available exits 
	,lookable::LookableMap -- ^ the different items one can look at 
	,takeable::TakeableMap -- ^ the different items one can take
	}
	deriving Show

-- | information about an item
data ItemInfo = ItemInfo {
	itemCode::ItemCode -- ^ the code for the item
	,itemDescription::Description -- ^ a description
	}
	deriving Show
	
-- | the current game state. This is the only mutable object (of course, it is not mutable, but a different instance will be built every time the state change 
data GameState = GameState {
	location::LocationCode -- ^ where the player is
	,items::ItemMap -- ^ the items the player is carrying
	,changedLookableMap::ChangedLookableMap -- ^the changes in what can be looked at in the world (items taken are not present any more...)
	}
	deriving (Show,Read)

-- | action of taking an item
data TakeAction = 
	-- | action succeeds
	TakeActionOK {
		takeDescription::Description -- ^ the description of the item
		, changedLookable::LookableMap -- ^ the changes to the lookable map
		}
	-- | action fails
	| TakeActionFail {
		takeDescription::Description -- ^ the description of the failure
		}
	-- | you need another item to get the object
	| TakeActionNeedItem {
		neededItem::ItemCode -- ^ the other item needed to get this item
		,failDescription::Description -- ^ description of failure
		,okDescription::Description -- ^ description of success
		, changedLookable::LookableMap -- ^ the changes to the lookable map
		}
	deriving Show

-- | map of locations by code
type LocationMap = DataMap.Map LocationCode LocationInfo 
-- | map of directions by code
type DirectionMap = DataMap.Map DirectionCode DirectionInfo
-- | map of lookable items by code
type LookableMap = DataMap.Map ItemCode Description
-- | map of items by code. Note the newtype because we need it to be Show and Read
newtype ItemMap = ItemMap (DataMap.Map ItemCode Description)
-- | the map of changes in what the player can look at 
newtype ChangedLookableMap = ChangedLookableMap (DataMap.Map LocationCode LookableMap)
-- | map of items the player can take, by code
type TakeableMap = DataMap.Map ItemCode TakeAction
-- | code for location
type LocationCode = String
-- | code for item
type ItemCode = String
-- | description of something
type Description= String
-- | code for direction 
type DirectionCode = String

-- * Data

churchDirections= DataMap.fromList [
	("south", DirectionInfo "A little vaulted door leads to the south" "cloister"),
	("west" , DirectionInfo "The church entrance leads west to the square" "square"),
	("east" , DirectionInfo "" "garden")
	]
	
cloisterDirections = DataMap.fromList [
	("north", DirectionInfo "A little vaulted door leading north to the church" "church")
	]
	
squareDirections = DataMap.fromList [
	("east", DirectionInfo "The church entrance is to the east." "church")
	]
	
gardenDirections = DataMap.fromList [
	("west", DirectionInfo "The little door leads west into the church." "church")
	]

churchLookable = DataMap.fromList [
	("church", "A fine roman church. You notice a little discrete door opening east.")
	]
	
cloisterLookable = DataMap.fromList [
	("cloister","A quiet cloister, with a basin in the middle."),
	("basin","Among the bigh fish, you see a golden necklace."),
	("fish","Big fish, bit teeth."),
	("necklace","A shiny golden necklace.")
	]

gardenLookable = DataMap.fromList [
	("garden","There's a rake against the wall"),
	("rake","A sturdy rake, with a long handle")
	]

squareLookable = DataMap.fromList [
	("square","You see the village square"),
	("market","You can trade items at the market")
	]

churchTakeable= DataMap.empty
cloisterTakeable= DataMap.fromList [
		("necklace",TakeActionNeedItem "rake" "Ouch! The fish bite you when you put your hand in the basin" "You use the rake to get the necklace from the bottom of the basin" (DataMap.fromList [("basin","The fish look hungry")]))
	]
gardenTakeable= DataMap.fromList [
		("rake",TakeActionOK "You take the rake" (DataMap.fromList [("garden","You see rows of vegetables"),("rake","")])) 
	]
squareTakeable= DataMap.empty

locations= DataMap.fromList [
	("church",LocationInfo "You are in a beautiful roman church." churchDirections churchLookable churchTakeable),
	("cloister",LocationInfo "You are in a quiet cloister. The sun shines through the sculpted columns. A basin is in the middle." cloisterDirections cloisterLookable cloisterTakeable),
	("square",LocationInfo "You are on the village square. There is a market on today." squareDirections squareLookable squareTakeable),
	("garden",LocationInfo "You are in a little tidy vegetable garden." gardenDirections gardenLookable gardenTakeable)
	]

tradeItems= DataMap.fromList [
	("rake", ItemInfo "boots" "Solid boots, good for walking"),
	("necklace", ItemInfo "sword" "A strong, sharp, two handed sword.")
	]

-- | what you get when you look at something uninteresting
seeNothing = "You see nothing worthwhile there"

-- | all actions possible to the player
actions :: DataMap.Map String (GameState -> [String] -> (GameState,[String]))
actions = DataMap.fromList [
	("move",move),
	("go",move),
	("help",help),
	("?",help),
	("look",look),
	("carry",carry),
	("take",takeItem),
	("trade",trade)]

-- | all IO actions
ioactions :: DataMap.Map String (GameState -> [FilePath] -> IO (GameState,String))
ioactions = DataMap.fromList [
	("save",save),
	("load",load)
	]

-- * Functions

-- | start the game
start :: IO()
start = 
	do 
		getCommand (GameState "church" (ItemMap DataMap.empty) (ChangedLookableMap DataMap.empty))

-- | command loop: shows the current state, asks for a command, executes it, and loops
-- | till exit is typed or till the game over state is reached
getCommand :: GameState -- ^ the current game state
	-> IO() -- ^ resulting IO
getCommand gs 
	| gameOver gs = 
		do
			putStrLn "You have everything you need to go and live some more exciting adventures now."
			putStrLn "Bye bye."
			return ()
	| otherwise =
		do
			putStrLn $ locationDescription $ location gs
			mapM putStrLn (locationDirections $ location gs)
			input <- getLine
			let cmds = words (map Char.toLower input)
			if null cmds
				then
					getCommand gs
				else
					do
						let (cmd:rest)=cmds
						if cmd=="exit" || cmd=="quit"
							then do
								putStrLn "Bye bye."
								return ()
							else
								do
									case DataMap.lookup (cmd) actions of
										Just f ->	
											do
												let (gs2,msg)= f gs rest
												mapM_ putStrLn msg
												getCommand gs2
										Nothing ->
											do
												case DataMap.lookup (cmd) ioactions of
													Just iof ->
														do
															(gs2,msg)<-iof gs rest
															putStrLn msg
															getCommand gs2	
													Nothing ->
														do
															putStrLn ("I don't know how to " ++ cmd)
															getCommand gs

-- | the description of a given location
locationDescription :: LocationCode -> String
locationDescription lc =  case DataMap.lookup lc locations of
	Nothing -> ""
	Just li -> descLoc li

-- | the directions possible from a location
locationDirections :: LocationCode -> [String]
locationDirections lc = case DataMap.lookup lc locations of
	Nothing -> []
	Just li -> map descDir ( filter (\x -> length (descDir x)>0) (DataMap.elems $ directions li))
	
-- | move one or several steps 
move :: GameState -> [DirectionCode] -> (GameState,[String])
move gs dcs 	= processMove gs dcs []

-- | process the move
processMove :: GameState -> [DirectionCode] -> [String] -> (GameState,[String]) 		
processMove gs [] acc 			= (gs,acc)
processMove gs (dc:dcs) acc 	= case DataMap.lookup (location gs) locations of
	Nothing -> (gs,acc ++ ["Wrong location!"])
	Just li -> case DataMap.lookup dc (directions li) of
		Nothing -> (gs,acc ++ ["You cannot go there!"])
		Just di -> processMove (gs {location=(locationCode di)}) dcs (acc ++ ["You move " ++ dc] )
				
-- | shows all possible commands
help :: GameState -> [String] -> (GameState,[String])	
help gs s = (gs,(DataList.sort [
	"move | go <direction(s)>: move in the given direction(s)",
	"exit: leave the game",
	"help: show this message",
	"look <item(s) | location(s)>: look closely at something",
	"carry: display the list of items you have with you",
	"take <item>: take an item with you",
	"trade <item>: trade an item against another one",
	"save <path>: save a game",
	"load <path>:load a saved game"
	]))

-- | look at an item or a location (or several)
look :: GameState -> [ItemCode] -> (GameState,[String])	
look gs s = (gs,lookOne gs s)

-- | look at one item recursively
lookOne :: GameState -> [ItemCode] -> [String]
lookOne gs [] = []
lookOne gs (ic:ics) = (lookInState gs ic):(lookOne gs ics)

-- | look at one item in the game state
lookInState :: GameState -> ItemCode -> String
lookInState gs@(GameState loc (ItemMap im) (ChangedLookableMap clm)) ic = case DataMap.lookup ic im of
	Just desc 	-> if length desc >0 
		then	desc 
		else	seeNothing
	Nothing 	-> case DataMap.lookup loc clm of
			Nothing -> (lookDefault gs ic)
			Just lm -> case DataMap.lookup ic lm of
					Nothing -> (lookDefault gs ic)
					Just d -> if length d>0
						then	d
						else	seeNothing

-- | look at one item in the game world
lookDefault :: GameState -> ItemCode -> String	
lookDefault gs s = case DataMap.lookup (location gs) locations of
		Nothing -> "Wrong location!"
		Just li -> case DataMap.lookup s (lookable li) of
			Nothing -> seeNothing
			Just d -> if length d>0
						then	d
						else	seeNothing


-- | show what the player is carrying
carry :: GameState -> [ItemCode] -> (GameState,[String])	
carry gs@(GameState loc (ItemMap im) clm) s 
	| (DataMap.size im==0) = (gs,["You are carrying nothing."])
	| otherwise = (gs,"You are carrying:": (DataList.sort (map capitalize (DataMap.keys im))))

-- | take an item
takeItem :: GameState -> [ItemCode] -> (GameState,[String])	
takeItem gs@(GameState loc (ItemMap im) clm) (ic:ics)= case DataMap.lookup ic im of
	Just desc 	-> (gs,["You already have that"])
	Nothing 	-> case DataMap.lookup loc locations of
		Nothing -> (gs,["Wrong location!"])
		Just li ->  case DataMap.lookup (ic) (takeable li) of
			Nothing -> (gs,["You cannot take that"])
			Just ta -> processTakeAction gs ic ta

-- | process the actual take action
processTakeAction :: GameState -> ItemCode -> TakeAction -> (GameState,[String])
processTakeAction gs ic (TakeActionFail s) = (gs,[s])
processTakeAction gs@(GameState loc (ItemMap im) (ChangedLookableMap clm)) ic (TakeActionOK s cl)= 
	let ds= lookInState gs ic
	in
	(GameState 
		(location gs) 
		(ItemMap (DataMap.insert ic ds (im)))
		(ChangedLookableMap (DataMap.unionWithKey
		 	(\k a b -> DataMap.union a b)
		 	clm 
		 	(DataMap.fromList[((location gs),cl)])))
	,[s])
processTakeAction gs@(GameState loc (ItemMap im) clm) ic (TakeActionNeedItem neededIC failS okS okCL)= case DataMap.lookup neededIC im of
	Just desc 	-> processTakeAction gs ic (TakeActionOK okS okCL)
	Nothing 	-> processTakeAction gs ic (TakeActionFail failS)

-- | trade an item in. Here, you don't get to choose what you get in exchange!
trade :: GameState -> [ItemCode] -> (GameState,[String])
trade gs [] = (gs,["You need to trade something"])
trade gs@(GameState loc (ItemMap im) clm) (ic:ics) 
	| loc == "square" = case DataMap.lookup (ic) im of
		Nothing -> (gs,["You don't have that item"])
		Just desc -> case DataMap.lookup ic tradeItems of
			Nothing -> (gs,["You cannot trade that"])
			Just ii -> 	let 	gs2 = gs {items= 
									(ItemMap (DataMap.insert (itemCode ii) (itemDescription ii) 
										(DataMap.delete ic im)))
									};
								(gs3,s) = carry gs2 []
						in (gs3,["Deal: "++(itemDescription ii)]++s)
	| otherwise = (gs,["You cannot trade here"])
	
-- | are the exit conditions filled?
gameOver :: GameState -> Bool
gameOver gs@(GameState loc (ItemMap im) clm) = (DataMap.member "sword" im) && (DataMap.member "boots" im)

-- | save the current game
save :: 
	GameState -- ^ the current game state 
	-> [FilePath] -- ^ the file paths (we use only the first one)
	-> IO (GameState,String) -- ^ the io operations
save gs filePaths= 
		if null filePaths
			then
				return (gs,"No path provided")
			else
				do
					catch (do 
						h <- openFile (head filePaths) WriteMode
						hPutStrLn h (show gs)
						hClose h
						return (gs,"Game saved")
						)
						(\ioe -> return (gs,"Cannot open file " ++ (head filePaths) ++ ": "++(ioeGetErrorString ioe)))

-- | load a saved game
load :: 
	GameState -- ^ the current game state 
	-> [FilePath] -- ^ the file paths (we use only the first one)
	-> IO (GameState,String) -- ^ the io operations
load gs filePaths= 
		if null filePaths
			then
				return (gs,"No path provided")
			else
				do
					catch (do 
						h <- openFile (head filePaths) ReadMode
						l <- hGetLine h
						hClose h
						let 	(gs,next) = head (readsPrec 1 l)
						return (gs,"Game loaded")
						)
						(\ioe -> return (gs,"Cannot open file " ++ (head filePaths) ++ ": "++(ioeGetErrorString ioe)))

-- | implementation of show for an item map: transform the map in list						
showItemMap :: ItemMap -> ShowS
showItemMap (ItemMap im) = showList (DataMap.toList im)

-- | implementation of read for ItemMap: from list to map
readItemMap :: ReadS (ItemMap)
readItemMap s = let (l,rest)=head (readList s)
	in [(ItemMap(DataMap.fromList l),rest)]

-- | define how an ItemMap can be serialized
instance Show ItemMap where
	showsPrec n = showItemMap

-- | define how an ItemMap can be deserialized
instance Read ItemMap where
	readsPrec n = readItemMap	

-- | implementation of show for a changedLookableMap: transform the map of map into a list of lists
showChangedLookableMap :: ChangedLookableMap -> ShowS
showChangedLookableMap (ChangedLookableMap clm) s = showList ((DataMap.toList (DataMap.map DataMap.toList clm))) s

-- | implementation of read for a changedLookableMap: from a list of lists to a map of maps
readChangedLookableMap :: ReadS (ChangedLookableMap)
readChangedLookableMap s= let (l,rest)=head (readList s)
	in [(ChangedLookableMap(DataMap.map DataMap.fromList (DataMap.fromList l)),rest)]

-- | define how a ChangedLookableMap can be serialized	
instance Show ChangedLookableMap where
	showsPrec n = showChangedLookableMap

	
-- | define how a ChangedLookableMap can be deserialized
instance Read ChangedLookableMap where
	readsPrec n = readChangedLookableMap	

