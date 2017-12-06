module Main exposing (..)


type State
    = S0
    | S1
    | S2


accepts : State -> String -> Bool
accepts state s =
    case String.uncons s of
        Just ( head, tail ) ->
            case state of
                S0 ->
                    case head of
                        'a' ->
                            accepts S1 tail

                        'b' ->
                            accepts S2 tail

                        _ ->
                            False

                S1 ->
                    case head of
                        'a' ->
                            accepts S2 tail

                        'b' ->
                            accepts S0 tail

                        _ ->
                            False

                S2 ->
                    case head of
                        'a' ->
                            accepts S0 tail

                        'b' ->
                            accepts S2 tail

                        _ ->
                            False

        Nothing ->
            case state of
                S2 ->
                    True

                _ ->
                    False


decide : String -> Bool
decide =
    accepts S0


a : Bool
a =
    Debug.log "False" <| decide "aaa"


b : Bool
b =
    Debug.log "True" <| decide "aaaabbaaa"


c : Bool
c =
    Debug.log "False" <| decide "babababa"
