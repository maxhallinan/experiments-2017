module Cache
    exposing
        ( Cache(..)
        , CacheEvent(..)
        , Transitions
        , patchFilledIdentity
        , updateCache
        , updateEmptyIdentity
        , updateFilledIdentity
        )


type Cache a b
    = Empty
    | EmptyInvalid a
    | EmptySyncing
    | EmptyInvalidSyncing a
    | Filled b
    | FilledSyncing b
    | FilledInvalid a b
    | FilledInvalidSyncing a b


type CacheEvent a b c
    = Sync
    | Error a
    | Update b
    | Patch c


type alias Transitions a b c =
    { updateEmpty : a -> b
    , updateFilled : a -> b -> b
    , patchFilled : c -> b -> b
    }


updateCache : Transitions c b d -> Cache a b -> CacheEvent a c d -> Cache a b
updateCache transitions current event =
    case current of
        Empty ->
            case event of
                Sync ->
                    EmptySyncing

                Error nextError ->
                    EmptyInvalid nextError

                Update nextData ->
                    Filled <| transitions.updateEmpty nextData

                Patch _ ->
                    current

        EmptyInvalid currentError ->
            case event of
                Sync ->
                    EmptyInvalidSyncing currentError

                Error nextError ->
                    EmptyInvalid nextError

                Update nextData ->
                    Filled <| transitions.updateEmpty nextData

                Patch _ ->
                    current

        EmptySyncing ->
            case event of
                Sync ->
                    EmptySyncing

                Error nextError ->
                    EmptyInvalid nextError

                Update nextData ->
                    Filled <| transitions.updateEmpty nextData

                Patch _ ->
                    current

        EmptyInvalidSyncing currentError ->
            case event of
                Sync ->
                    EmptyInvalidSyncing currentError

                Error nextError ->
                    EmptyInvalid nextError

                Update nextData ->
                    Filled <| transitions.updateEmpty nextData

                Patch _ ->
                    current

        Filled currentData ->
            case event of
                Sync ->
                    FilledSyncing currentData

                Error nextError ->
                    FilledInvalid nextError currentData

                Update nextData ->
                    Filled <| transitions.updateFilled nextData currentData

                Patch patch ->
                    Filled <| transitions.patchFilled patch currentData

        FilledInvalid currentError currentData ->
            case event of
                Sync ->
                    FilledInvalidSyncing currentError currentData

                Error nextError ->
                    FilledInvalid nextError currentData

                Update nextData ->
                    Filled <| transitions.updateFilled nextData currentData

                Patch patch ->
                    Filled <| transitions.patchFilled patch currentData

        FilledSyncing currentData ->
            case event of
                Sync ->
                    FilledSyncing currentData

                Error nextError ->
                    FilledInvalid nextError currentData

                Update nextData ->
                    Filled <| transitions.updateFilled nextData currentData

                Patch patch ->
                    Filled <| transitions.patchFilled patch currentData

        FilledInvalidSyncing currentError currentData ->
            case event of
                Sync ->
                    FilledInvalidSyncing currentError currentData

                Error nextError ->
                    FilledInvalid nextError currentData

                Update nextData ->
                    Filled <| transitions.updateFilled nextData currentData

                Patch patch ->
                    Filled <| transitions.patchFilled patch currentData


patchFilledIdentity : a -> b -> b
patchFilledIdentity =
    identity2


updateEmptyIdentity : a -> a
updateEmptyIdentity =
    identity


updateFilledIdentity : a -> b -> b
updateFilledIdentity =
    identity2


identity2 : a -> b -> b
identity2 _ =
    identity
