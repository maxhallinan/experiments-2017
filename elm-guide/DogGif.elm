module DogGif exposing (..)

import Html exposing (Html, button, div, img, input, p, text)
import Html.Attributes exposing (alt, placeholder, src)
import Html.Events exposing (onClick, onInput)
import Http
import Json.Decode as Decode


main =
    Html.program
        { init = init
        , subscriptions = subscriptions
        , update = update
        , view = view
        }



-- MODEL


type alias Model =
    { gifUrl : String
    , keyword : String
    }


init =
    ( Model "" "", Cmd.none )



-- UPDATE


type Msg
    = UpdateKeyword String
    | RefreshGif
    | NewGif (Result Http.Error String)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UpdateKeyword keyword ->
            ( { model | keyword = keyword }, Cmd.none )

        RefreshGif ->
            ( model, getRandomGif model.keyword )

        NewGif (Ok newUrl) ->
            ( { model | gifUrl = newUrl }, Cmd.none )

        NewGif (Err _) ->
            ( model, Cmd.none )


getRandomGif : String -> Cmd Msg
getRandomGif topic =
    let
        url =
            "https://api.giphy.com/v1/gifs/random?api_key=dc6zaTOxFJmzC&tag=" ++ topic

        request =
            Http.get url decodeGifUrl
    in
        Http.send NewGif request


decodeGifUrl : Decode.Decoder String
decodeGifUrl =
    Decode.at [ "data", "image_url" ] Decode.string



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Model -> Html Msg
view model =
    div
        []
        [ p
            []
            [ img
                [ alt model.keyword, src model.gifUrl ]
                []
            ]
        , input
            [ onInput UpdateKeyword, placeholder "Enter a keyword" ]
            []
        , p
            []
            [ text ("The current keyword is " ++ model.keyword) ]
        , button
            [ onClick RefreshGif ]
            [ text "Get new gif" ]
        ]
