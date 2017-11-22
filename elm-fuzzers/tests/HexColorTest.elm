module HexColorTest exposing (..)

import Expect
import Fuzz exposing (Fuzzer)
import Test exposing (Test)


hexColor : Fuzzer String
hexColor =
    Fuzz.oneOf
        [ Fuzz.map2 (++) hash digit3
        , Fuzz.map2 (++) hash digit6
        ]


hash : Fuzzer String
hash =
    Fuzz.constant "#"


digit6 : Fuzzer String
digit6 =
    repeat2 digit3


digit3 : Fuzzer String
digit3 =
    repeat3 digit1


digit1 : Fuzzer String
digit1 =
    Fuzz.oneOf [ alpha, num ]


alpha : Fuzzer String
alpha =
    Fuzz.oneOf [ a, b, c, d, e, f ]


a : Fuzzer String
a =
    Fuzz.oneOf
        [ Fuzz.constant "A"
        , Fuzz.constant "a"
        ]


b : Fuzzer String
b =
    Fuzz.oneOf
        [ Fuzz.constant "B"
        , Fuzz.constant "b"
        ]


c : Fuzzer String
c =
    Fuzz.oneOf
        [ Fuzz.constant "C"
        , Fuzz.constant "c"
        ]


d : Fuzzer String
d =
    Fuzz.oneOf
        [ Fuzz.constant "D"
        , Fuzz.constant "d"
        ]


e : Fuzzer String
e =
    Fuzz.oneOf
        [ Fuzz.constant "E"
        , Fuzz.constant "e"
        ]


f : Fuzzer String
f =
    Fuzz.oneOf
        [ Fuzz.constant "F"
        , Fuzz.constant "f"
        ]


num : Fuzzer String
num =
    Fuzz.oneOf
        [ Fuzz.constant "1"
        , Fuzz.constant "2"
        , Fuzz.constant "3"
        , Fuzz.constant "4"
        , Fuzz.constant "5"
        , Fuzz.constant "6"
        , Fuzz.constant "7"
        , Fuzz.constant "8"
        , Fuzz.constant "9"
        ]


repeat3 : Fuzzer String -> Fuzzer String
repeat3 fuzzer =
    Fuzz.map2 (++) fuzzer <| repeat2 fuzzer


repeat2 : Fuzzer String -> Fuzzer String
repeat2 fuzzer =
    Fuzz.map2 (++) fuzzer fuzzer


test : Test
test =
    Test.describe "Fake test"
        [ Test.fuzz hexColor "Produces a valid hex color" <|
            \hexColor ->
                let
                    _ =
                        Debug.log "hexColor" hexColor
                in
                    Expect.pass
        ]
