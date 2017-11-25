module Main exposing (..)


type alias FormField =
    { value : String
    }


type FormData a
    = FormData FormField


type Valid
    = Valid


type Invalid
    = Invalid


valid : FormField -> FormData Valid
valid =
    FormData


invalid : FormField -> FormData Invalid
invalid =
    FormData


validate : FormField -> Result (FormData Invalid) (FormData Valid)
validate formField =
    if String.isEmpty formField.value then
        Ok <| valid formField
    else
        Err <| invalid formData



-- log : FormData Valid -> String
-- log formData =
--       Debug.log "valid" value


main =
    log <| validate <| FormField ""
