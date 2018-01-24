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


createEntities : List Person -> PersonEntities
createEntities persons =
    List.map keyByUrl persons
        |> List.map (\( url, p ) -> ( url, Cache.Filled p ))
        |> Dict.fromList


updateEntities : List Person -> PersonEntities -> PersonEntities
updateEntities updates currentCache =
    let
        getCurrent =
            flip Dict.get currentCache
    in
    List.map keyByUrl updates
        |> List.map (\( url, person ) -> ( url, Cache.Update person ))
        |> List.map
            (\( url, person ) ->
                ( url
                , Cache.updateCache
                    { updateEmpty = identity
                    , updateFilled = identity2

                    -- rename this?
                    , patchFilled = \patchEvent current -> current
                    }
                    (Maybe.withDefault Cache.Empty <| getCurrent url)
                    person
                )
            )
        |> Dict.fromList


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


updateItemInEntities : String -> Person -> PersonEntities -> PersonEntities
updateItemInEntities url update current =
    Dict.insert
        url
        (Cache.updateCache
            { updateEmpty = \x -> x
            , updateFilled = \x y -> x
            , patchFilled = \patchEvent current -> current
            }
            (Dict.get url current |> Maybe.withDefault Cache.Empty)
            (Cache.Update update)
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


patchItem : String -> Cache.CacheEvent Http.Error Person a -> PersonCollection -> PersonCollection
patchItem url cacheEvent personCollection =
    let
        item =
            Dict.get url personCollection.entities

        updatedItem =
            Maybe.map
                (\cache ->
                    Cache.updateCache
                        { updateEmpty = \x -> x
                        , updateFilled = \x y -> x
                        , patchFilled = \x y -> y
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
        Cache.Patch _ ->
            personCollection

        _ ->
            { personCollection | entities = updatedEntities }



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
                        { updateEmpty = updateEmptyCollection
                        , updateFilled = updateFilledCollection
                        , patchFilled = \patchEvent current -> current
                        }
                        model.persons
                        Cache.Sync
              }
            , getCollection
            )

        CollectionResponse (Err e) ->
            ( { model
                | persons =
                    Cache.updateCache
                        { updateEmpty = updateEmptyCollection
                        , updateFilled = updateFilledCollection
                        , patchFilled = \patchEvent current -> current
                        }
                        model.persons
                        (Cache.Error e)
              }
            , Cmd.none
            )

        CollectionResponse (Ok persons) ->
            ( { model
                | persons =
                    Cache.updateCache
                        { updateEmpty = updateEmptyCollection
                        , updateFilled = updateFilledCollection
                        , patchFilled = \patchEvent current -> current
                        }
                        model.persons
                        (Cache.Update persons)
              }
            , Cmd.none
            )

        CollectionErrorRequest ->
            ( { model
                | persons =
                    Cache.updateCache
                        { updateEmpty = updateEmptyCollection
                        , updateFilled = updateFilledCollection
                        , patchFilled = \patchEvent current -> current
                        }
                        model.persons
                        Cache.Sync
              }
            , getCollectionError
            )

        CollectionErrorResponse (Ok _) ->
            ( model, Cmd.none )

        CollectionErrorResponse (Err error) ->
            ( { model
                | persons =
                    Cache.updateCache
                        { updateEmpty = updateEmptyCollection
                        , updateFilled = updateFilledCollection
                        , patchFilled = \patchEvent current -> current
                        }
                        model.persons
                        (Cache.Error error)
              }
            , Cmd.none
            )

        ItemRequest url ->
            ( { model
                | persons =
                    Cache.updateCache
                        { updateEmpty = updateEmptyCollection
                        , updateFilled = updateFilledCollection
                        , patchFilled = patchItem url
                        }
                        model.persons
                        (Cache.Patch Cache.Sync)
              }
            , getItem url
            )

        ItemResponse url (Ok person) ->
            ( { model
                | persons =
                    Cache.updateCache
                        { updateEmpty = updateEmptyCollection
                        , updateFilled = updateFilledCollection
                        , patchFilled = patchItem url
                        }
                        model.persons
                        (Cache.Patch (Cache.Update person))
              }
            , Cmd.none
            )

        ItemResponse url (Err err) ->
            ( { model
                | persons =
                    Cache.updateCache
                        { updateEmpty = updateEmptyCollection
                        , updateFilled = updateFilledCollection
                        , patchFilled = patchItem url
                        }
                        model.persons
                        (Cache.Patch (Cache.Error err))
              }
            , Cmd.none
            )

        ItemErrorRequest url ->
            ( { model
                | persons =
                    Cache.updateCache
                        { updateEmpty = updateEmptyCollection
                        , updateFilled = updateFilledCollection
                        , patchFilled = patchItem url
                        }
                        model.persons
                        (Cache.Patch Cache.Sync)
              }
            , getItemError url
            )

        ItemErrorResponse url (Ok person) ->
            ( { model
                | persons =
                    Cache.updateCache
                        { updateEmpty = updateEmptyCollection
                        , updateFilled = updateFilledCollection
                        , patchFilled = patchItem url
                        }
                        model.persons
                        (Cache.Patch (Cache.Update person))
              }
            , Cmd.none
            )

        ItemErrorResponse url (Err err) ->
            ( { model
                | persons =
                    Cache.updateCache
                        { updateEmpty = updateEmptyCollection
                        , updateFilled = updateFilledCollection
                        , patchFilled = patchItem url
                        }
                        model.persons
                        (Cache.Patch (Cache.Error err))
              }
            , Cmd.none
            )



-- View


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


collectionView : Cache.Cache Http.Error PersonCollection -> Html Msg
collectionView collectionCache =
    div
        []
        [ p
            []
            [ loadingView collectionCache
            , errorView collectionCache
            , listView collectionCache
            ]
        ]


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
        , div
            []
            [ collectionView model.persons
            ]
        ]
