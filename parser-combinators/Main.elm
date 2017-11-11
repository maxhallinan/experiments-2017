module Kalk exposing (..)

import Combine exposing (..)
import Combine.Num exposing (int)


-- addop : Parser s (Int -> Int -> Int)
-- addop =
--     choice
--         [ (+) <$ string "+"
--         , (-) <$ string "-"
--         ]


op : Parser s (Int -> Int -> Int)
op =
    choice
        [ (*) <$ string "*"
        , (//) <$ string "/"
        , (+) <$ string "+"
        , (-) <$ string "-"
        ]


expr : Parser s Int
expr =
    let
        go () =
            chainl op factor
    in
        lazy go



-- term : Parser s Int
-- term =
--     let
--         go () =
--             chainl mulop factor
--     in
--         lazy go


factor : Parser s Int
factor =
    whitespace *> (parens expr <|> int) <* whitespace


calc : String -> Result String Int
calc s =
    case parse (expr <* end) s of
        Ok ( _, _, n ) ->
            Ok n

        Err ( _, stream, ms ) ->
            Err ("parse err: " ++ toString ms ++ ", " ++ toString stream)


res =
    let
        f =
            calc "5 - (10 / 2) + 5"
    in
        case f of
            Ok n ->
                Debug.log "n" (toString n)

            Err e ->
                Debug.log "e" e
