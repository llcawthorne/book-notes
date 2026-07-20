
robot (name,attack,hp) = \message -> message (name,attack,hp)

name (n,_,_) = n
attack (_,a,_) = a
hp (_,_,hp) = hp

getName aRobot = aRobot name
getAttack aRobot = aRobot attack
getHP aRobot = aRobot hp

-- setters return a new instances of the robot
setName aRobot newName = aRobot (\(n,a,h) -> robot (newName,a,h))
setAttack aRobot newAttack = aRobot (\(n,a,h) -> robot (n,newAttack,h))
setHP aRobot newHP = aRobot (\(n,a,h) -> robot (n,a,newHP))

printRobot aRobot = aRobot (\(n,a,h) -> n ++
                                        " attack:" ++ show a ++
                                        " hp:" ++ show h)

-- now we need a way to send messages.
damage aRobot attackDamage = aRobot (\(n,a,h) ->
                                      robot (n,a,h-attackDamage))

-- some robots
killerRobot = robot ("Kill3r", 25, 200)
nicerRobot = setName killerRobot "kitty"
gentlerRobot = setAttack killerRobot 5
softerRobot = setHP killerRobot 50
gentleGiant = robot ("Mr. Friendly", 10, 300)

-- now they gotta fight!
fight aRobot defender = damage defender attack
  where attack = if getHP aRobot > 10
                 then getAttack aRobot
                 else 0

-- now this is a little painful without reassignment
gentleGiantRound1 = fight killerRobot gentleGiant
killerRobotRound1 = fight gentleGiant killerRobot
gentleGiantRound2 = fight killerRobotRound1 gentleGiantRound1
killerRobotRound2 = fight gentleGiantRound1 killerRobotRound1
gentleGiantRound3 = fight killerRobotRound2 gentleGiantRound2
killerRobotRound3 = fight gentleGiantRound2 killerRobotRound2
displayResults a d = printRobot a ++ "\n" ++ printRobot d
displayResultsRound3 = displayResults gentleGiantRound3 killerRobotRound3

listOfRobots = [killerRobot, nicerRobot, gentlerRobot, softerRobot, gentleGiant]
