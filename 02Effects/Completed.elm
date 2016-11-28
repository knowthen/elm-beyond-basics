module Completed exposing (..)

import Html exposing (..)
import Html.Events exposing (..)
import Http


-- model


type alias Model =
    String


initModel : Model
initModel =
    "Finding a joke..."


init : ( Model, Cmd Msg )
init =
    ( initModel, randomJoke )


randomJoke : Cmd Msg
randomJoke =
    let
        url =
            "http://api.icndb.com/jokes/random"

        request =
            Http.getString url

        cmd =
            Http.send Joke request
    in
        cmd



-- update


type Msg
    = Joke (Result Http.Error String)
    | NewJoke


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Joke (Ok joke) ->
            ( joke, Cmd.none )

        Joke (Err err) ->
            ( (toString err), Cmd.none )

        NewJoke ->
            ( "fetching joke ...", randomJoke )



-- view


view : Model -> Html Msg
view model =
    div []
        [ button [ onClick NewJoke ] [ text "Fetch a Joke" ]
        , br [] []
        , text model
        ]



-- subscription


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }
