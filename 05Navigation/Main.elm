module Main exposing (..)

import Html exposing (..)
import Html.Events exposing (..)
import Navigation exposing (..)
import String


-- model


type Page
    = LeaderBoard
    | AddRunner
    | Login
    | NotFound


type alias Model =
    { page : Page
    }


initModel : Page -> Model
initModel page =
    { page = page
    }


init : Page -> ( Model, Cmd Msg )
init page =
    ( initModel page, Cmd.none )



-- update


type Msg
    = Navigate Page


toHash : Page -> String
toHash page =
    case page of
        LeaderBoard ->
            "#"

        AddRunner ->
            "#add"

        Login ->
            "#login"

        NotFound ->
            "#notfound"


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Navigate page ->
            ( model, newUrl (toHash page) )


urlUpdate : Page -> Model -> ( Model, Cmd Msg )
urlUpdate page model =
    ( { model | page = page }, Cmd.none )



-- view


menu : Model -> Html Msg
menu model =
    header []
        [ a [ onClick (Navigate LeaderBoard) ]
            [ text "LeaderBoard" ]
        , text " | "
        , a [ onClick (Navigate AddRunner) ]
            [ text "Add Runner" ]
        , text " | "
        , a [ onClick (Navigate Login) ]
            [ text "Login" ]
        ]


viewPage : String -> Html Msg
viewPage pageDescription =
    div []
        [ h3 [] [ text pageDescription ]
        , p [] [ text <| "TODO: make " ++ pageDescription ]
        ]


view : Model -> Html Msg
view model =
    let
        page =
            case model.page of
                LeaderBoard ->
                    viewPage "LeaderBoard Page"

                AddRunner ->
                    viewPage "Add Runner Page"

                Login ->
                    viewPage "Login Page"

                NotFound ->
                    viewPage "Page Not Found"
    in
        div []
            [ menu model
            , hr [] []
            , page
            ]



-- subscription


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


locationParser : Location -> Page
locationParser location =
    let
        _ =
            Debug.log "location: " location

        hash =
            (String.dropLeft 1 location.hash)
    in
        case hash of
            "" ->
                LeaderBoard

            "add" ->
                AddRunner

            "login" ->
                Login

            _ ->
                NotFound


main : Program Never
main =
    -- App.program
    --     { init = init
    --     , update = update
    --     , view = view
    --     , subscriptions = subscriptions
    --     }
    Navigation.program (makeParser locationParser)
        -- TODO: make locationParser
        { init =
            init
            -- TODO: change init into a function
        , update = update
        , view = view
        , subscriptions = subscriptions
        , urlUpdate =
            urlUpdate
            -- TODO: create a urlUpdate function
        }
