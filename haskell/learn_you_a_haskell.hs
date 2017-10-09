sayNum :: (Integral a) => a -> String
sayNum 1 = "One!"
sayNum 2 = "Two!"
sayNum 3 = "Three!"
sayNum 4 = "Four!"
sayNum 5 = "Five!"
sayNum 6 = "Six!"
sayNum 7 = "Seven!"
sayNum 8 = "Eight!"
sayNum 9 = "Nine!"
sayNum 10 = "Ten!"
sayNum x = "Not between One and Ten."

factorial :: (Integral a) => a -> a
factorial 0 = 1
factorial n = n * factorial (n - 1)

addVectors :: (Integral a) => (a, a) -> (a, a) -> (a, a)
addVectors (x1, y1) (x2, y2) = (x1 + x2, y1 + y2)

tripleFirst :: (a, b, c) -> a
tripleFirst (x, _, _) = x

tripleSecond :: (a, b, c) -> b
tripleSecond (_, x, _) = x

tripleThird :: (a, b, c) -> c
tripleThird (_, _, x) = x

describeList :: (Show a) => [a] -> String
describeList [] = "This list is empty."
describeList (x:[]) = "This list has one element: " ++ show x
describeList (x:y:[]) = "This list has two elements: " ++ show x ++ " and " ++ show y
describeList (x:y:_) = "This is a long list. Here are the first two elements: " ++ show x ++ " and " ++ show y

gtLtEq :: (RealFloat a) => a -> a -> String
gtLtEq x y
  | x > y = "Greater than."
  | x < y = "Less than."
  | otherwise = "Equal to."


foo :: (RealFloat a) => a -> a -> String
foo x y
  | difference < 0 = "Negative number."
  | difference > 0 = "Positive number."
  | otherwise = "Equal."
  where difference = x - y 

maximum' :: (Ord a) => [a] -> a
maximum' [] = error "maximum of empty list"
maximum' [x] = x
maximum' (x:xs)
  | x > maxTail = x
  | otherwise = maxTail
  where maxTail = maximum' xs

replicate' :: (Num i, Ord i) => i -> a -> [a]
replicate' n x
  | n <= 0 = []
  | otherwise = x:replicate' (n - 1) x

take' :: (Num i, Ord i) => i -> [a] -> [a]
take' n _
  | n <= 0 = []
take' _ [] = []
take' n (x:xs) = x:take' (n - 1) xs

ruhverse :: [a] -> [a]
ruhverse [] = [] 
ruhverse (x:xs) = ruhverse xs ++ [x]

zipp :: [a] -> [b] -> [(a, b)]
zipp _ [] = []
zipp [] _ = []
zipp (x:xs) (y:ys) = (x, y):zipp xs ys 

elem' :: (Eq a) => a -> [a] -> Bool
elem' a [] = False
elem' a (x:xs)
  | a == x  = True
  | otherwise = elem' a xs

quicksort :: (Ord a) => [a] -> [a]
quicksort [] = []
quicksort (x:xs) =
  let smaller = quicksort [a | a <- xs, a <= x]
      bigger  = quicksort [a | a <- xs, a > x]
  in smaller ++ [x] ++ bigger
