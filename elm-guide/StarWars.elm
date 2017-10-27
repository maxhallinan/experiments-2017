module StarWars exposing (..)

import Html exposing (Html, div, h1, li, p, text, ul)
import Http
import Json.Decode as D
import Json.Decode.Pipeline as DPipe


{-
   To make an HTTP request, you need these things:
   - A `Msg Result a`
   - A `Decoder a`
   - A url string

   - Http.get takes a request url and a Decoder
   - Http.send takes a Request and a Msg
-}
{-
   {
     "count": 87,
     "next": "https://swapi.co/api/people/?page=2",
     "previous": null,
     "results": [
       {
         "name": "Luke Skywalker",
         "height": "172",
         "mass": "77",
         "hair_color": "blond",
         "skin_color": "fair",
         "eye_color": "blue",
         "birth_year": "19BBY",
         "gender": "male",
         "homeworld": "https://swapi.co/api/planets/1/",
         "films": [
           "https://swapi.co/api/films/2/",
           "https://swapi.co/api/films/6/",
           "https://swapi.co/api/films/3/",
           "https://swapi.co/api/films/1/",
           "https://swapi.co/api/films/7/"
         ],
         "species": [
           "https://swapi.co/api/species/1/"
         ],
         "vehicles": [
           "https://swapi.co/api/vehicles/14/",
           "https://swapi.co/api/vehicles/30/"
         ],
         "starships": [
           "https://swapi.co/api/starships/12/",
           "https://swapi.co/api/starships/22/"
         ],
         "created": "2014-12-09T13:50:51.644000Z",
         "edited": "2014-12-20T21:17:56.891000Z",
         "url": "https://swapi.co/api/people/1/"
       }
     ]
   }
-}


main =
    Html.program
        { init = init
        , subscriptions = subscriptions
        , update = update
        , view = view
        }



-- MODEL


type alias Person =
    { birth_year : String
    , created : String
    , edited : String
    , films : List String
    , gender : String
    , hair_color : String
    , height : String
    , homeworld : String
    , eye_color : String
    , mass : String
    , name : String
    , species : List String
    , starships : List String
    , url : String
    , vehicles : List String
    }


dPerson =
    DPipe.decode Person
        |> DPipe.required "birth_year" D.string
        |> DPipe.required "created" D.string
        |> DPipe.required "edited" D.string
        |> DPipe.required "films" (D.list D.string)
        |> DPipe.required "gender" D.string
        |> DPipe.required "hair_color" D.string
        |> DPipe.required "height" D.string
        |> DPipe.required "homeworld" D.string
        |> DPipe.required "eye_color" D.string
        |> DPipe.required "mass" D.string
        |> DPipe.required "name" D.string
        |> DPipe.required "species" (D.list D.string)
        |> DPipe.required "starships" (D.list D.string)
        |> DPipe.required "url" D.string
        |> DPipe.required "vehicles" (D.list D.string)


type alias People =
    { count : Int
    , results : List Person
    }


dCount : D.Decoder Int
dCount =
    D.field "count" D.int


dResults : D.Decoder (List Person)
dResults =
    D.field "results" (D.list dPerson)


dPeople : D.Decoder People
dPeople =
    D.map2 People dCount dResults


getPeople =
    Http.get "https://swapi.co/api/people" dPeople


type alias Model =
    { people : People
    }


init : ( Model, Cmd Msg )
init =
    ( Model (People 0 []), Http.send RefreshPeople getPeople )



-- SUBSCRIPTIONS


subscriptions : model -> Sub Msg
subscriptions model =
    Sub.none



-- UPDATE


type Msg
    = RefreshPeople (Result Http.Error People)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        RefreshPeople (Ok people) ->
            ( Model people, Cmd.none )

        RefreshPeople (Err _) ->
            ( model, Cmd.none )



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ h1 [] [ text "Star Wars Character Names" ]
        , p [] [ text (toString model.people.count) ]
        ]
