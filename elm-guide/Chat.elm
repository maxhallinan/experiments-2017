module Chat exposing (..)

import Html exposing (Html, button, div, h1, input, li, p, text, ul)
import Html.Attributes exposing (value)
import Html.Events exposing (..)
import WebSocket


main =
    Html.program
        { init = init
        , subscriptions = subscriptions
        , update = update
        , view = view
        }



-- MODEL


type alias Model =
    { draft : String
    , messages : List String
    }


init =
    ( Model "" [], Cmd.none )



-- UPDATE


type Msg
    = Draft String
    | NewMessage String
    | Send


update : Msg -> Model -> ( Model, Cmd msg )
update msg { draft, messages } =
    case msg of
        Draft newDraft ->
            ( Model newDraft messages, Cmd.none )

        NewMessage newMessage ->
            ( Model draft (newMessage :: messages), Cmd.none )

        Send ->
            ( Model "" messages, WebSocket.send "ws://echo.websocket.org" draft )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    WebSocket.listen "ws://echo.websocket.org" NewMessage



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ h1 [] [ text "Chat logs" ]
        , ul [] (List.map (\message -> li [] [ text message ]) model.messages)
        , input [ onInput Draft, value model.draft ] []
        , button [ onClick Send ] [ text "Send message" ]
        ]
