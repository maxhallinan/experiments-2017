module Main exposing (..)

import Cache exposing (Cache)
import Data.Collection exposing (Collection, Entities)
import Data.Person exposing (Person)
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


identity2 : a -> b -> b
identity2 _ =
    identity


keyByUrl : { a | url : String } -> ( String, { a | url : String } )
keyByUrl x =
    ( x.url, x )



-- Http


getItem : String -> Cmd Msg
getItem url =
    Http.send (ItemResponse url) <|
        Http.get url Data.Person.decodePerson


getItemError : String -> Cmd Msg
getItemError url =
    Http.send (ItemResponse url) <|
        Http.get "https://swapi.co/api/foo/" Data.Person.decodePerson


getCollection : Cmd Msg
getCollection =
    Http.send CollectionResponse <|
        Http.get "https://swapi.co/api/people/" Data.Person.decodePersonCollection


getCollectionError : Cmd Msg
getCollectionError =
    Http.send CollectionResponse <|
        Http.get "https://swapi.co/api/foo/" Data.Person.decodePersonCollection



-- Model


init : ( Model, Cmd Msg )
init =
    ( { persons = Cache.Empty }, Cmd.none )


type alias Model =
    { persons : Cache Http.Error PersonCollection
    }


type alias PersonCollection =
    Collection PersonCache


type alias PersonCache =
    Cache Http.Error Person


type alias PersonEntities =
    Entities PersonCache


updateEmptyPersonCollection : List Person -> PersonCollection
updateEmptyPersonCollection persons =
    { entities = createEntities persons
    , displayOrder = toDisplayOrder persons
    }


updateFilledPersonCollection : List Person -> PersonCollection -> PersonCollection
updateFilledPersonCollection persons current =
    { entities = updateEntities persons current.entities
    , displayOrder = toDisplayOrder persons
    }


patchFilledPersonCollection : String -> Cache.CacheEvent Http.Error Person a -> PersonCollection -> PersonCollection
patchFilledPersonCollection url cacheEvent personCollection =
    let
        entities =
            personCollection.entities
    in
    { personCollection
        | entities =
            Dict.get url entities
                |> Maybe.map (updatePersonCache url cacheEvent)
                |> Maybe.map (flippedDictInsert url entities)
                |> Maybe.withDefault entities
    }


flippedDictInsert : String -> Dict String a -> a -> Dict String a
flippedDictInsert key =
    flip (Dict.insert key)


updatePersonCache : String -> Cache.CacheEvent Http.Error Person a -> PersonCache -> PersonCache
updatePersonCache url cacheEvent currentCache =
    Cache.updateCache
        { updateEmpty = identity
        , updateFilled = identity2
        , patchFilled = identity2
        }
        cacheEvent
        currentCache


toDisplayOrder : List Person -> List String
toDisplayOrder =
    List.map .url


createEntities : List { a | url : String } -> Dict String (Cache b { a | url : String })
createEntities =
    toUrlDict >> toFilledCache


toUrlDict : List { a | url : String } -> Dict String { a | url : String }
toUrlDict =
    List.map keyByUrl
        >> Dict.fromList


toFilledCache : Dict String a -> Dict String (Cache b a)
toFilledCache =
    Dict.map (\k v -> Cache.Filled v)


updateEntities : List Person -> PersonEntities -> PersonEntities
updateEntities updates currentEntities =
    let
        getCurrentPersonCache =
            flip Dict.get currentEntities
                >> Maybe.withDefault Cache.Empty
    in
    toUrlDict updates
        |> Dict.map
            (\url personUpdate ->
                Cache.updateCache
                    { updateEmpty = identity
                    , updateFilled = identity2
                    , patchFilled = identity2
                    }
                    (Cache.Update personUpdate)
                    (getCurrentPersonCache url)
            )
        |> replaceCurrentWithUpdate currentEntities


replaceCurrentWithUpdate : Dict String a -> Dict String a -> Dict String a
replaceCurrentWithUpdate x y =
    Dict.merge mergeOnlyInLeft mergeInBoth mergeOnlyInRight x y Dict.empty


mergeOnlyInLeft : String -> a -> Dict String a -> Dict String a
mergeOnlyInLeft =
    Dict.insert


mergeOnlyInRight : String -> a -> Dict String a -> Dict String a
mergeOnlyInRight =
    Dict.insert


mergeInBoth : String -> a -> b -> Dict String b -> Dict String b
mergeInBoth key left right result =
    Dict.insert key right result



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
                    Cache.updateCache
                        { updateEmpty = updateEmptyPersonCollection
                        , updateFilled = updateFilledPersonCollection
                        , patchFilled = identity2
                        }
                        Cache.Sync
                        model.persons
              }
            , getCollection
            )

        CollectionResponse (Err error) ->
            ( { model
                | persons =
                    Cache.updateCache
                        { updateEmpty = updateEmptyPersonCollection
                        , updateFilled = updateFilledPersonCollection
                        , patchFilled = identity2
                        }
                        (Cache.Error error)
                        model.persons
              }
            , Cmd.none
            )

        CollectionResponse (Ok persons) ->
            ( { model
                | persons =
                    Cache.updateCache
                        { updateEmpty = updateEmptyPersonCollection
                        , updateFilled = updateFilledPersonCollection
                        , patchFilled = identity2
                        }
                        (Cache.Update persons)
                        model.persons
              }
            , Cmd.none
            )

        CollectionErrorRequest ->
            ( { model
                | persons =
                    Cache.updateCache
                        { updateEmpty = updateEmptyPersonCollection
                        , updateFilled = updateFilledPersonCollection
                        , patchFilled = identity2
                        }
                        Cache.Sync
                        model.persons
              }
            , getCollectionError
            )

        CollectionErrorResponse (Ok persons) ->
            ( { model
                | persons =
                    Cache.updateCache
                        { updateEmpty = updateEmptyPersonCollection
                        , updateFilled = updateFilledPersonCollection
                        , patchFilled = identity2
                        }
                        (Cache.Update persons)
                        model.persons
              }
            , Cmd.none
            )

        CollectionErrorResponse (Err error) ->
            ( { model
                | persons =
                    Cache.updateCache
                        { updateEmpty = updateEmptyPersonCollection
                        , updateFilled = updateFilledPersonCollection
                        , patchFilled = identity2
                        }
                        (Cache.Error error)
                        model.persons
              }
            , Cmd.none
            )

        ItemRequest url ->
            ( { model
                | persons =
                    Cache.updateCache
                        { updateEmpty = updateEmptyPersonCollection
                        , updateFilled = identity2
                        , patchFilled = patchFilledPersonCollection url
                        }
                        (Cache.Patch Cache.Sync)
                        model.persons
              }
            , getItem url
            )

        ItemResponse url (Ok person) ->
            ( { model
                | persons =
                    Cache.updateCache
                        { updateEmpty = updateEmptyPersonCollection
                        , updateFilled = identity2
                        , patchFilled = patchFilledPersonCollection url
                        }
                        (Cache.Patch (Cache.Update person))
                        model.persons
              }
            , Cmd.none
            )

        ItemResponse url (Err error) ->
            ( { model
                | persons =
                    Cache.updateCache
                        { updateEmpty = updateEmptyPersonCollection
                        , updateFilled = identity2
                        , patchFilled = patchFilledPersonCollection url
                        }
                        (Cache.Patch (Cache.Error error))
                        model.persons
              }
            , Cmd.none
            )

        ItemErrorRequest url ->
            ( { model
                | persons =
                    Cache.updateCache
                        { updateEmpty = updateEmptyPersonCollection
                        , updateFilled = identity2
                        , patchFilled = patchFilledPersonCollection url
                        }
                        (Cache.Patch Cache.Sync)
                        model.persons
              }
            , getItemError url
            )

        ItemErrorResponse url (Ok person) ->
            ( { model
                | persons =
                    Cache.updateCache
                        { updateEmpty = updateEmptyPersonCollection
                        , updateFilled = identity2
                        , patchFilled = patchFilledPersonCollection url
                        }
                        (Cache.Patch (Cache.Update person))
                        model.persons
              }
            , Cmd.none
            )

        ItemErrorResponse url (Err error) ->
            ( { model
                | persons =
                    Cache.updateCache
                        { updateEmpty = updateEmptyPersonCollection
                        , updateFilled = identity2
                        , patchFilled = patchFilledPersonCollection url
                        }
                        (Cache.Patch (Cache.Error error))
                        model.persons
              }
            , Cmd.none
            )



-- View


view : Model -> Html Msg
view model =
    div
        []
        [ button
            [ onClick CollectionRequest
            ]
            [ text "Get data"
            ]
        , button
            [ onClick CollectionErrorRequest
            ]
            [ text "Get error"
            ]
        , loadingView model.persons
        , errorView model.persons
        , listView model.persons
        ]


type Visibility a
    = Show a
    | Hide


visibilityToHtml : (a -> Html b) -> Visibility a -> Html b
visibilityToHtml toHtml visibility =
    case visibility of
        Show x ->
            toHtml x

        Hide ->
            text ""


buttonVisibility : PersonCache -> Visibility Person
buttonVisibility cache =
    case cache of
        Cache.Empty ->
            Hide

        Cache.EmptyInvalid _ ->
            Hide

        Cache.EmptyInvalidSyncing _ ->
            Hide

        Cache.EmptySyncing ->
            Hide

        Cache.Filled p ->
            Show p

        Cache.FilledInvalid _ p ->
            Show p

        Cache.FilledInvalidSyncing _ p ->
            Show p

        Cache.FilledSyncing p ->
            Show p


buttonHtml : (String -> Msg) -> String -> Person -> Html Msg
buttonHtml msgCtr label { name, url } =
    button
        [ onClick (msgCtr url)
        ]
        [ text label
        ]


buttonView : (String -> Msg) -> String -> PersonCache -> Html Msg
buttonView msgCtor label =
    buttonVisibility >> visibilityToHtml (buttonHtml msgCtor label)


loadingVisibility : Cache Http.Error a -> Visibility ()
loadingVisibility cache =
    case cache of
        Cache.Empty ->
            Hide

        Cache.EmptyInvalid _ ->
            Hide

        Cache.EmptyInvalidSyncing _ ->
            Show ()

        Cache.EmptySyncing ->
            Show ()

        Cache.Filled _ ->
            Hide

        Cache.FilledInvalid _ _ ->
            Hide

        Cache.FilledInvalidSyncing _ _ ->
            Show ()

        Cache.FilledSyncing _ ->
            Show ()


loadingHtml : Html Msg
loadingHtml =
    p
        []
        [ text "Loading"
        ]


loadingView : Cache Http.Error a -> Html Msg
loadingView =
    loadingVisibility >> visibilityToHtml (\() -> loadingHtml)


errorVisibility : Cache Http.Error a -> Visibility String
errorVisibility cache =
    case cache of
        Cache.Empty ->
            Hide

        Cache.EmptyInvalid _ ->
            Show "Error"

        Cache.EmptyInvalidSyncing _ ->
            Show "Error"

        Cache.EmptySyncing ->
            Hide

        Cache.Filled _ ->
            Hide

        Cache.FilledInvalid _ _ ->
            Show "Error"

        Cache.FilledInvalidSyncing _ _ ->
            Show "Error"

        Cache.FilledSyncing _ ->
            Hide


errorHtml : String -> Html Msg
errorHtml err =
    p
        []
        [ text err ]


errorView : Cache Http.Error a -> Html Msg
errorView =
    errorVisibility >> visibilityToHtml errorHtml


hairColorVisibility : PersonCache -> Visibility (Maybe String)
hairColorVisibility person =
    case person of
        Cache.Empty ->
            Hide

        Cache.EmptyInvalid _ ->
            Hide

        Cache.EmptyInvalidSyncing _ ->
            Hide

        Cache.EmptySyncing ->
            Hide

        Cache.Filled { hairColor } ->
            Show hairColor

        Cache.FilledInvalid _ { hairColor } ->
            Show hairColor

        Cache.FilledInvalidSyncing _ { hairColor } ->
            Show hairColor

        Cache.FilledSyncing { hairColor } ->
            Show hairColor


hairColorHtml : Maybe String -> Html Msg
hairColorHtml hairColor =
    case hairColor of
        Just h ->
            p
                []
                [ text h ]

        Nothing ->
            text ""


hairColorView : PersonCache -> Html Msg
hairColorView =
    hairColorVisibility >> visibilityToHtml hairColorHtml


nameVisibility : PersonCache -> Visibility String
nameVisibility person =
    case person of
        Cache.Empty ->
            Hide

        Cache.EmptyInvalid _ ->
            Hide

        Cache.EmptyInvalidSyncing _ ->
            Hide

        Cache.EmptySyncing ->
            Hide

        Cache.Filled { name } ->
            Show name

        Cache.FilledInvalid _ { name } ->
            Show name

        Cache.FilledInvalidSyncing _ { name } ->
            Show name

        Cache.FilledSyncing { name } ->
            Show name


nameHtml : String -> Html Msg
nameHtml name =
    p
        []
        [ text name ]


nameView : PersonCache -> Html Msg
nameView =
    nameVisibility >> visibilityToHtml nameHtml


itemView : PersonCache -> Html Msg
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


listVisibility : Cache Http.Error PersonCollection -> Visibility PersonCollection
listVisibility cache =
    case cache of
        Cache.Empty ->
            Hide

        Cache.EmptyInvalid _ ->
            Hide

        Cache.EmptyInvalidSyncing error ->
            Hide

        Cache.EmptySyncing ->
            Hide

        Cache.Filled collection ->
            Show collection

        Cache.FilledInvalid _ collection ->
            Show collection

        Cache.FilledInvalidSyncing error collection ->
            Show collection

        Cache.FilledSyncing collection ->
            Show collection


listHtml : Collection PersonCache -> Html Msg
listHtml { entities, displayOrder } =
    let
        getPersons =
            flip Dict.get entities
    in
    List.map getPersons displayOrder
        |> filterNothings
        |> List.map itemView
        |> ul []


listView : Cache.Cache Http.Error PersonCollection -> Html Msg
listView =
    listVisibility >> visibilityToHtml listHtml
