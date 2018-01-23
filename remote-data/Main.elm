module Main exposing (..)

import Dict exposing (Dict)
import Html exposing (Html, button, div, li, p, span, text, ul)
import Html.Events exposing (onClick)
import Http
import Json.Decode


main =
    Html.program
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }



-- Helpers


filterNothing : Maybe a -> List a -> List a
filterNothing mX xs =
    case mX of
        Just x ->
            x :: xs

        Nothing ->
            xs


filterNothings : List (Maybe a) -> List a
filterNothings =
    List.foldl filterNothing []



-- Http


getItem : String -> Cmd Msg
getItem url =
    Http.send (ItemResponse url) <|
        Http.get url decodePersonDetails


getItemError : String -> Cmd Msg
getItemError url =
    Http.send (ItemResponse url) <|
        Http.get "https://swapi.co/api/foo/" decodePersonDetails


getCollection : Cmd Msg
getCollection =
    Http.send CollectionResponse <|
        Http.get "https://swapi.co/api/people/" decodePersons


getCollectionError : Cmd Msg
getCollectionError =
    Http.send CollectionResponse <|
        Http.get "https://swapi.co/api/foo/" decodePersons



-- Model


init : ( Model, Cmd Msg )
init =
    ( { persons = Empty }, Cmd.none )


type alias Model =
    { persons : Cache Http.Error (Collection (Cache Http.Error Person))
    }


type alias Collection a =
    { entities : Dict String a
    , displayOrder : List String
    }


type CacheEvent a b c
    = Sync
    | Failure a
    | Success b -- change to Insert
    | Patch c


type Cache a b
    = Empty
    | EmptyInvalid a
    | EmptySyncing
    | EmptyInvalidSyncing a
    | Filled b
    | FilledSyncing b
    | FilledInvalid a b
    | FilledInvalidSyncing a b


keyByUrl : Person -> ( String, Person )
keyByUrl person =
    ( person.url, person )


createEntities : List Person -> Dict String (Cache Http.Error Person)
createEntities persons =
    List.map keyByUrl persons
        |> List.map (\( url, p ) -> ( url, Filled p ))
        |> Dict.fromList


updateEntities : List Person -> Dict String (Cache Http.Error Person) -> Dict String (Cache Http.Error Person)
updateEntities updates currentCache =
    let
        getCurrent =
            flip Dict.get currentCache
    in
    List.map keyByUrl updates
        |> List.map (\( url, person ) -> ( url, Success person ))
        |> List.map
            (\( url, person ) ->
                ( url
                , updateCache
                    { emptyToFilled = updateEmptyItem
                    , filledToFilled = updateFilledItem
                    , patch = \patchEvent current -> current
                    }
                    (Maybe.withDefault Empty <| getCurrent url)
                    person
                )
            )
        |> Dict.fromList


type alias PersonCollection =
    Collection (Cache Http.Error Person)


updateFilledItem : Person -> Person -> Person
updateFilledItem current next =
    next


updateEmptyItem : Person -> Person
updateEmptyItem person =
    person


updateFilledCollection : List Person -> PersonCollection -> PersonCollection
updateFilledCollection persons current =
    { entities = updateEntities persons current.entities
    , displayOrder = List.map .url persons
    }


updateEmptyCollection : List Person -> PersonCollection
updateEmptyCollection persons =
    { entities = createEntities persons
    , displayOrder = List.map .url persons
    }


updateItemInEntities : String -> Person -> Dict String (Cache Http.Error Person) -> Dict String (Cache Http.Error Person)
updateItemInEntities url update current =
    Dict.insert
        url
        (updateCache
            { emptyToFilled = \x -> x
            , filledToFilled = \x y -> x
            , patch = \patchEvent current -> current
            }
            (Dict.get url current |> Maybe.withDefault Empty)
            (Success update)
        )
        current


updateEmptyItemInCollection : String -> Person -> Person -> PersonCollection
updateEmptyItemInCollection url update current =
    { entities = updateItemInEntities url update Dict.empty
    , displayOrder = [ update.url ]
    }


updateFilledItemInCollection : String -> Person -> PersonCollection -> PersonCollection
updateFilledItemInCollection url update current =
    { entities = updateItemInEntities url update current.entities
    , displayOrder = current.displayOrder
    }


patchItem : String -> CacheEvent Http.Error Person a -> PersonCollection -> PersonCollection
patchItem url cacheEvent personCollection =
    let
        item =
            Dict.get url personCollection.entities

        updatedItem =
            Maybe.map
                (\cache ->
                    updateCache
                        { emptyToFilled = \x -> x
                        , filledToFilled = \x y -> x
                        , patch = \x y -> y
                        }
                        cache
                        cacheEvent
                )
                item

        updatedEntities =
            Maybe.map (\item -> Dict.insert url item personCollection.entities) updatedItem
                |> Maybe.withDefault personCollection.entities
    in
    case cacheEvent of
        Patch _ ->
            personCollection

        _ ->
            { personCollection | entities = updatedEntities }


type alias Transitions a b c =
    { emptyToFilled : a -> b
    , filledToFilled : a -> b -> b
    , patch : c -> b -> b
    }


updateCache : Transitions c b d -> Cache a b -> CacheEvent a c d -> Cache a b
updateCache transitions current event =
    case current of
        Empty ->
            case event of
                Sync ->
                    EmptySyncing

                Failure nextError ->
                    EmptyInvalid nextError

                Success nextData ->
                    Filled <| transitions.emptyToFilled nextData

                Patch _ ->
                    current

        EmptyInvalid currentError ->
            case event of
                Sync ->
                    EmptyInvalidSyncing currentError

                Failure nextError ->
                    EmptyInvalid nextError

                Success nextData ->
                    Filled <| transitions.emptyToFilled nextData

                Patch _ ->
                    current

        EmptySyncing ->
            case event of
                Sync ->
                    EmptySyncing

                Failure nextError ->
                    EmptyInvalid nextError

                Success nextData ->
                    Filled <| transitions.emptyToFilled nextData

                Patch _ ->
                    current

        EmptyInvalidSyncing currentError ->
            case event of
                Sync ->
                    EmptyInvalidSyncing currentError

                Failure nextError ->
                    EmptyInvalid nextError

                Success nextData ->
                    Filled <| transitions.emptyToFilled nextData

                Patch _ ->
                    current

        Filled currentData ->
            case event of
                Sync ->
                    FilledSyncing currentData

                Failure nextError ->
                    FilledInvalid nextError currentData

                Success nextData ->
                    Filled <| transitions.filledToFilled nextData currentData

                Patch patchEvent ->
                    Filled <| transitions.patch patchEvent currentData

        FilledInvalid currentError currentData ->
            case event of
                Sync ->
                    FilledInvalidSyncing currentError currentData

                Failure nextError ->
                    FilledInvalid nextError currentData

                Success nextData ->
                    Filled <| transitions.filledToFilled nextData currentData

                Patch patchEvent ->
                    Filled <| transitions.patch patchEvent currentData

        FilledSyncing currentData ->
            case event of
                Sync ->
                    FilledSyncing currentData

                Failure nextError ->
                    FilledInvalid nextError currentData

                Success nextData ->
                    Filled <| transitions.filledToFilled nextData currentData

                Patch patchEvent ->
                    Filled <| transitions.patch patchEvent currentData

        FilledInvalidSyncing currentError currentData ->
            case event of
                Sync ->
                    FilledInvalidSyncing currentError currentData

                Failure nextError ->
                    FilledInvalid nextError currentData

                Success nextData ->
                    Filled <| transitions.filledToFilled nextData currentData

                Patch patchEvent ->
                    Filled <| transitions.patch patchEvent currentData


type alias Person =
    { name : String
    , url : String
    , hairColor : Maybe String
    }


decodeHairColor : Json.Decode.Decoder (Maybe String)
decodeHairColor =
    Json.Decode.field "hair_color" Json.Decode.string
        |> Json.Decode.map Just


decodeName : Json.Decode.Decoder String
decodeName =
    Json.Decode.field "name" Json.Decode.string


decodeUrl : Json.Decode.Decoder String
decodeUrl =
    Json.Decode.field "url" Json.Decode.string


decodePerson : Json.Decode.Decoder Person
decodePerson =
    Json.Decode.map3
        Person
        decodeName
        decodeUrl
        (Json.Decode.succeed Nothing)


decodePersonDetails : Json.Decode.Decoder Person
decodePersonDetails =
    Json.Decode.map3
        Person
        decodeName
        decodeUrl
        decodeHairColor


decodePersons : Json.Decode.Decoder (List Person)
decodePersons =
    Json.Decode.field "results" (Json.Decode.list decodePerson)


decodeError : Json.Decode.Decoder String
decodeError =
    Json.Decode.field "detail" Json.Decode.string



-- Subscriptions


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- Update


type Msg
    = CollectionErrorRequest
    | CollectionErrorResponse (Result Http.Error (List Person))
    | CollectionRequest
    | CollectionResponse (Result Http.Error (List Person))
    | ItemRequest String
    | ItemResponse String (Result Http.Error Person)
    | ItemErrorRequest String
    | ItemErrorResponse String (Result Http.Error Person)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        CollectionRequest ->
            ( { model
                | persons =
                    updateCache
                        { emptyToFilled = updateEmptyCollection
                        , filledToFilled = updateFilledCollection
                        , patch = \patchEvent current -> current
                        }
                        model.persons
                        Sync
              }
            , getCollection
            )

        CollectionResponse (Err e) ->
            ( { model
                | persons =
                    updateCache
                        { emptyToFilled = updateEmptyCollection
                        , filledToFilled = updateFilledCollection
                        , patch = \patchEvent current -> current
                        }
                        model.persons
                        (Failure e)
              }
            , Cmd.none
            )

        CollectionResponse (Ok persons) ->
            ( { model
                | persons =
                    updateCache
                        { emptyToFilled = updateEmptyCollection
                        , filledToFilled = updateFilledCollection
                        , patch = \patchEvent current -> current
                        }
                        model.persons
                        (Success persons)
              }
            , Cmd.none
            )

        CollectionErrorRequest ->
            ( model, getCollectionError )

        CollectionErrorResponse (Ok _) ->
            ( model, getCollectionError )

        CollectionErrorResponse (Err error) ->
            ( { model
                | persons =
                    updateCache
                        { emptyToFilled = updateEmptyCollection
                        , filledToFilled = updateFilledCollection
                        , patch = \patchEvent current -> current
                        }
                        model.persons
                        (Failure error)
              }
            , Cmd.none
            )

        ItemRequest url ->
            ( { model
                | persons =
                    updateCache
                        { emptyToFilled = updateEmptyCollection
                        , filledToFilled = updateFilledCollection
                        , patch = patchItem url
                        }
                        model.persons
                        (Patch Sync)
              }
            , getItem url
            )

        ItemResponse url (Ok person) ->
            ( { model
                | persons =
                    updateCache
                        { emptyToFilled = updateEmptyCollection
                        , filledToFilled = updateFilledCollection
                        , patch = patchItem url
                        }
                        model.persons
                        (Patch (Success person))
              }
            , Cmd.none
            )

        ItemResponse url (Err err) ->
            ( { model
                | persons =
                    updateCache
                        { emptyToFilled = updateEmptyCollection
                        , filledToFilled = updateFilledCollection
                        , patch = patchItem url
                        }
                        model.persons
                        (Patch (Failure err))
              }
            , Cmd.none
            )

        ItemErrorRequest url ->
            ( { model
                | persons =
                    updateCache
                        { emptyToFilled = updateEmptyCollection
                        , filledToFilled = updateFilledCollection
                        , patch = patchItem url
                        }
                        model.persons
                        (Patch Sync)
              }
            , getItemError url
            )

        ItemErrorResponse url (Ok person) ->
            ( { model
                | persons =
                    updateCache
                        { emptyToFilled = updateEmptyCollection
                        , filledToFilled = updateFilledCollection
                        , patch = patchItem url
                        }
                        model.persons
                        (Patch (Success person))
              }
            , Cmd.none
            )

        ItemErrorResponse url (Err err) ->
            ( { model
                | persons =
                    updateCache
                        { emptyToFilled = updateEmptyCollection
                        , filledToFilled = updateFilledCollection
                        , patch = patchItem url
                        }
                        model.persons
                        (Patch (Failure err))
              }
            , Cmd.none
            )


btn : (String -> Msg) -> String -> Person -> Html Msg
btn msgCtr label { name, url } =
    button
        [ onClick (msgCtr url)
        ]
        [ text label
        ]


buttonView : (String -> Msg) -> String -> Cache Http.Error Person -> Html Msg
buttonView msgCtr label person =
    case person of
        Empty ->
            text ""

        EmptyInvalid _ ->
            text ""

        EmptyInvalidSyncing _ ->
            text ""

        EmptySyncing ->
            text ""

        Filled p ->
            btn msgCtr label p

        FilledInvalid _ p ->
            btn msgCtr label p

        FilledInvalidSyncing _ p ->
            btn msgCtr label p

        FilledSyncing p ->
            btn msgCtr label p


loadingView : Cache Http.Error Person -> Html Msg
loadingView person =
    case person of
        Empty ->
            text ""

        EmptyInvalid _ ->
            text ""

        EmptyInvalidSyncing _ ->
            p
                []
                [ text "Loading"
                ]

        EmptySyncing ->
            p
                []
                [ text "Loading"
                ]

        Filled _ ->
            text ""

        FilledInvalid _ _ ->
            text ""

        FilledInvalidSyncing _ _ ->
            p
                []
                [ text "Loading"
                ]

        FilledSyncing _ ->
            p
                []
                [ text "Loading"
                ]


errorView : Cache Http.Error Person -> Html Msg
errorView person =
    case person of
        Empty ->
            text ""

        EmptyInvalid _ ->
            p
                []
                [ text "Error"
                ]

        EmptyInvalidSyncing _ ->
            p
                []
                [ text "Error"
                ]

        EmptySyncing ->
            text ""

        Filled _ ->
            text ""

        FilledInvalid _ _ ->
            p
                []
                [ text "Error"
                ]

        FilledInvalidSyncing _ _ ->
            p
                []
                [ text "Error"
                ]

        FilledSyncing _ ->
            text ""


hairColorTextView : Maybe String -> Html Msg
hairColorTextView hairColor =
    case hairColor of
        Just h ->
            p
                []
                [ text h ]

        Nothing ->
            text ""


hairColorView : Cache Http.Error Person -> Html Msg
hairColorView person =
    case person of
        Empty ->
            text ""

        EmptyInvalid _ ->
            text ""

        EmptyInvalidSyncing _ ->
            text ""

        EmptySyncing ->
            text ""

        Filled { hairColor } ->
            hairColorTextView hairColor

        FilledInvalid _ { hairColor } ->
            hairColorTextView hairColor

        FilledInvalidSyncing _ { hairColor } ->
            hairColorTextView hairColor

        FilledSyncing { hairColor } ->
            hairColorTextView hairColor


nameView : Cache Http.Error Person -> Html Msg
nameView person =
    case person of
        Empty ->
            text ""

        EmptyInvalid _ ->
            text ""

        EmptyInvalidSyncing _ ->
            text ""

        EmptySyncing ->
            text ""

        Filled { name } ->
            text name

        FilledInvalid _ { name } ->
            text name

        FilledInvalidSyncing _ { name } ->
            text name

        FilledSyncing { name } ->
            text name


itemView : Cache Http.Error Person -> Html Msg
itemView person =
    li
        []
        [ p
            []
            [ nameView person
            , hairColorView person
            , errorView person
            , loadingView person
            ]
        , buttonView ItemRequest "Get details" person
        , buttonView ItemErrorRequest "Get error" person
        ]


listView : Collection (Cache Http.Error Person) -> Html Msg
listView { entities, displayOrder } =
    let
        getPersons =
            flip Dict.get entities
    in
    List.map getPersons displayOrder
        |> filterNothings
        |> List.map itemView
        |> ul []


collectionView : Cache Http.Error (Collection (Cache Http.Error Person)) -> Html Msg
collectionView collectionCache =
    case collectionCache of
        Empty ->
            text ""

        EmptyInvalid _ ->
            div
                []
                [ p
                    []
                    [ text "Error"
                    ]
                ]

        EmptyInvalidSyncing error ->
            div
                []
                [ p
                    []
                    [ text "Error"
                    ]
                , p
                    []
                    [ text "Loading"
                    ]
                ]

        EmptySyncing ->
            div
                []
                [ p
                    []
                    [ text "Loading"
                    ]
                ]

        Filled collection ->
            div
                []
                [ listView collection
                ]

        FilledInvalid error collection ->
            div
                []
                [ p
                    []
                    [ text "Error"
                    ]
                , listView collection
                ]

        FilledInvalidSyncing error collection ->
            div
                []
                [ p
                    []
                    [ text "Error"
                    ]
                , p
                    []
                    [ text "Loading"
                    ]
                , listView collection
                ]

        FilledSyncing collection ->
            div
                []
                [ p
                    []
                    [ text "Loading"
                    ]
                , listView collection
                ]


view : Model -> Html Msg
view model =
    div
        []
        [ button
            [ onClick CollectionRequest
            ]
            [ text "Get collection"
            ]
        , button
            [ onClick CollectionErrorRequest
            ]
            [ text "Get collection error"
            ]
        , div
            []
            [ collectionView model.persons
            ]
        ]
