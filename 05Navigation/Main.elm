module Main exposing (..)

import Html exposing (..)
import Html.Events exposing (..)
import Navigation exposing (..)


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


init : Location -> ( Model, Cmd Msg )
init location =
    let
        page =
            hashToPage location.hash
    in
        ( initModel page, Cmd.none )



-- update


type Msg
    = Navigate Page
    | ChangePage Page


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Navigate page ->
            ( model, newUrl <| pageToHash page )

        ChangePage page ->
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


pageToHash : Page -> String
pageToHash page =
    case page of
        LeaderBoard ->
            "#"

        AddRunner ->
            "#add"

        Login ->
            "#login"

        NotFound ->
            "#notfound"


hashToPage : String -> Page
hashToPage hash =
    case hash of
        "" ->
            LeaderBoard

        "#add" ->
            AddRunner

        "#login" ->
            Login

        _ ->
            NotFound


locationToMsg : Location -> Msg
locationToMsg location =
    location.hash
        |> hashToPage
        |> ChangePage


main : Program Never Model Msg
main =
    Navigation.program locationToMsg
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }
