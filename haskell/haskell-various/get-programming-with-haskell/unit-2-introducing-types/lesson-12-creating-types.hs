
type FirstName = String
type LastName = String
type Age = Int
type Height = Int
type PatientName = (FirstName, LastName)

-- QC 12.1
patientInfo :: PatientName -> Age -> Height -> String
patientInfo (fname, lname) age height = name ++ " " ++ ageHeight
  where name = lname ++ ", " ++ fname
        ageHeight = "(" ++ show age ++ "yrs. " ++ show height ++ "in.)"

data Sex = Male | Female deriving (Eq, Show)

sexInitial :: Sex -> Char
sexInitial Male = 'M'
sexInitial Female = 'F'

data RhType = Pos | Neg deriving (Eq, Show)
data ABOType = A | B | AB | O deriving (Eq, Show)
data BloodType = BloodType ABOType RhType deriving (Eq, Show)

patient1BT :: BloodType
patient1BT = BloodType A Pos

canDonateTo :: BloodType -> BloodType -> Bool
canDonateTo (BloodType O _) _ = True  -- O can donate to anybody
canDonateTo _ (BloodType AB _) = True -- anyone can donate to AB
canDonateTo (BloodType A _) (BloodType A _) = True  -- A to A and AB
canDonateTo (BloodType B _) (BloodType B _) = True  -- B to B and AB
canDonateTo _ _ = False -- otherwise False

type MiddleName = String
-- a better type for name than a Tuple
data Name = Name FirstName LastName
          | NameWithMiddle FirstName MiddleName LastName deriving (Eq, Show)

type Weight = Int
-- Let's make a type to represent our patient using record syntax
data Patient = Patient { name :: Name
                       , sex :: Sex
                       , age :: Age
                       , height :: Height
                       , weight :: Weight
                       , bloodType :: BloodType }
  deriving (Eq, Show)

-- We can still create positionally
johnDoe :: Patient
johnDoe = Patient (Name "John" "Doe") Male 30 74 200 (BloodType AB Pos)

janeSmith :: Patient
janeSmith = Patient (NameWithMiddle "Jane" "Elizabeth" "Smith")
              Female 21 68 105 (BloodType O Neg)

-- or we can create with record syntax
jackieSmith :: Patient
jackieSmith = Patient { name = Name "Jackie" "Smith"
                      , age = 43
                      , sex = Female
                      , height = 62
                      , weight = 115
                      , bloodType = BloodType AB Pos }

-- record syntax makes updating (through creating copies) super easy
olderJackie = jackieSmith { age = 44 }

-- Q12.1
canPatientDonateTo :: Patient -> Patient -> Bool
canPatientDonateTo (Patient _ _ _ _ _ btA) (Patient _ _ _ _ _ btB) =
  canDonateTo btA btB
-- or don't use pattern matching
donorFor :: Patient -> Patient -> Bool
donorFor p1 p2 = canDonateTo (bloodType p1) (bloodType p2)

-- Q12.2
patientSummary :: Patient -> String
patientSummary patient = "*************\n"
                      ++ "Patient Name: " ++ showName (name patient) ++ "\n"
                      ++ "Sex: " ++ show (sex patient) ++ "\n"
                      ++ "Age: " ++ show (age patient) ++ " yrs\n"
                      ++ "Height: " ++ show (height patient) ++ " in.\n"
                      ++ "Weight: " ++ show (weight patient) ++ " lbs.\n"
                      ++ "Blood Type: " ++ show (bloodType patient) ++ "\n"
                      ++ "**************\n"
  where showName (Name fname lname) = lname ++ ", " ++ fname
        showName (NameWithMiddle fname _ lname) = lname ++ ", " ++ fname
