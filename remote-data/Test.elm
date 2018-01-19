module Main exposing (..)


type alias Model =
    { xs : RemoteData Error X
    }


type RemoteData a b
    = NotAsked
    | Loading
    | Failure a
    | Success (List b)


view : Model -> Html a
view { xs } =
    case xs of
        NotAsked ->
            -- ...
            True

        Loading ->
            -- ...
            True

        Failure error ->
            -- ...
            True

        Success data ->
            -- ...
            True


type Cache a b c
    = Empty (Health a) (Sync b)
    | Filled (Health a) (Sync b) c


type Health a
    = Valid
    | Invalid a


type Sync a
    = Complete


type alias Model =
    { foos : Cache Error Source (List Foo)
    }


type Error
    = General String
    | Specific ( Int, String )


type Source
    = Collection
    | Item Int


view : Model -> Html a
view { xs } =
    case xs of
        NotAsked ->
            emptyView

        Loading ->
            loadingView

        Failure error ->
            errorView error

        Success data ->
            successView data
