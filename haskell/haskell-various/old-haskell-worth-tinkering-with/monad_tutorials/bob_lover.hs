
-- This is a type for Lover
-- It stores the name of the person's lover and how many "dates" they've had
newtype Lover a = Lover { loverDiary :: (Name,a) }
    deriving (Show)
type Name = String

-- createLover makes a lover seeing {name} a number of times
createLover name times = Lover (name,times)

-- this starts an affair between a Lover and  
-- a person of a certain name with 0 dates initially
startAffairWith name (Lover (names,times)) = Lover (name,0)

-- partial applications of women of certain names
-- these chicks are always looking for a lover
jenny = startAffairWith "Jenny "
luisa = startAffairWith "Luisa "
antonia = startAffairWith "Antonia "

-- bob is a lover, and he originally was seeing Paula
-- they previously had 5 dates
bob = createLover "Paula " 5

-- increase the count with a certain affair-ee
oneMoreTime (Lover (name,times)) = Lover (name,times + 1)

-- so, we want a way to have a new beloved, but keep track
-- of our "victories"
changeBeloved newname (Lover (name,times)) = Lover (name ++ newname,times)

-- so, we want to chain these affairs, 'cause Bob is a dawg
chainAffairs (Lover (names,oldtimes)) (Lover (newlady,newtimes)) = Lover (newlady++names,newtimes+oldtimes)

---- Some example output right now
-- *Main> chainAffairs (oneMoreTime $ oneMoreTime (antonia bob)) ( oneMoreTime $ changeBeloved "Carla " bob)
-- Lover {loverDiary = ("Paula Carla Antonia ",8)}
---- Remember, Bob started from ("Paula ", 5)

-- So we don't have to update every night, let's allow function application
-- so now we can do things like times (+3) or times (*2) in our calls
times f (Lover (name,times)) = Lover (name, f times)

-- We call these fellows like bob Playa's
class Playa f where
  chain :: (Num a) => f a -> f a -> f a
  
instance Playa Lover where
  chain mychicks = chainAffairs mychicks
  
-- -- Let's see this funky chain in action
-- *Main> chain (times (+3) (antonia bob)) (chain (times (*2) (changeBeloved "Carla " bob)) (times (+2) (luisa bob)))
-- Lover {loverDiary = ("Luisa Paula Carla Antonia ",15)}

-- Bob basically maps his diary with some function ('times')
-- Functors are pure calculating machines, without a soul.  Like bob.
-- They are the types who map objects that can be mapped over.

instance Functor Lover where
  fmap f = times f
  
-- now we can just use fmap instead of times, and it calls the 
-- appropriate mapping function

-- hmm..  strange soul stuff?
tellLover newtimes oldtimes = Lover ("", newtimes+oldtimes)
askLover lover answer = Lover (oldnames ++ newname, newtimes)
    where (oldnames,oldtimes) = loverDiary lover
          (newname, newtimes) = loverDiary (answer oldtimes)
tellMyself newtimes = Lover ("", newtimes)
newLove love = Lover (love,0)

-- let's have a female lover that isn't just a partial application
alessia = askLover (newLove "Joseph ") (tellLover 4)

-- physis is going to be born
physis = Lover ([],0)
andrea = physis

dies lover = Lover ([],0)

-- these are how a lover is born, and how one dies

-- this guy is based upon Momento, he loses his short term memory
newtype Leonard a = Leonard { leonardDiary :: (Name,a) }
    deriving (Show)
             
askLeonard lover answer = Leonard (oldnames,oldtimes)
    where (oldnames,oldtimes) = leonardDiary lover
          (newname, newtimes) = leonardDiary (answer oldtimes)
          
leonard = Leonard ("Jorja Fox", 1000)

tellLeonard newtimes oldtimes = Leonard ("", newtimes+oldtimes)
tellLeonardSelf newtimes = Leonard ("", newtimes)
newLeonardLove love = Leonard (love,0)

-- but even with his lack of memory, Leonard is a Playa
instance Playa Leonard where
  chain (Leonard (a,b)) (Leonard (c,d)) = (Leonard (a,b))
  
-- -- As quickly as you tell Leonard something, he forgets!
-- *Main> chain leonard (askLeonard (newLeonardLove "Angolie ") (tellLeonard 3))
-- Leonard {leonardDiary = ("Jorja Fox",1000)}
  
-- but let's allow leonard to keep his Jorja score updated,
-- at least until he sleeps
instance Functor Leonard where
  fmap f (Leonard (a,b)) = Leonard (a,f b)
  
-- well our bob has an outside, the Playa bob, but he has a secret
-- hidden inside too.  how monadic that bob is!
instance Monad Lover where
  return a = tellMyself a
  m >>= f = askLover m f
  
-- now let's see a drunk bob
drunk bob = do newLove "Paula "
               paula <- tellMyself 5
               newLove "Jennifer L. "
               jennyfer <- tellMyself 10
               newLove "Britney S. "
               brit <- tellMyself 20
               newLove "Alex "
               alex <- tellMyself 15
               tellMyself (jennyfer * brit * alex)
               
-- -- Let's see this drunk bob
-- *Main> drunk bob
-- Lover {loverDiary = ("Paula Jennifer L. Britney S. Alex ",3000)}

-- within the Monad, it is just bob's soul talking to bob.
-- all internal.  everything in the 'do' block.

-- Leonard doesn't have a soul
-- He doesn't have an internal side
-- He doesn't have state
-- He is constantly reset to just what you, and
-- cannot be a Monad!

whoLovedBy bob = do newLove "Andrea "
                    andrea <- tellMyself 1
                    newLove "Bob "
                    bob <- tellMyself 1
                    tellMyself (andrea + bob)
                    

-- hmm.  the story and code didn't make that much sense
-- maybe I should watch Memento?
-- fine looking / compiling code though
-- I'll keep this around

-- Back to learnyouahaskell!