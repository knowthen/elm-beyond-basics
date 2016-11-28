port module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Navigation
import LeaderBoard


-- model


type alias Model =
    { page : Page
    , leaderBoard : LeaderBoard.Model
    }


type Page
    = NotFound
    | LeaderBoardPage


init : Navigation.Location -> ( Model, Cmd Msg )
init location =
    let
        page =
            hashToPage location.hash

        ( leaderboardInitModel, leaderboardCmd ) =
            LeaderBoard.init

        initModel =
            { page = page
            , leaderBoard = leaderboardInitModel
            }

        cmds =
            Cmd.batch
                [ Cmd.map LeaderBoardMsg leaderboardCmd
                ]
    in
        ( initModel, cmds )



-- update


type Msg
    = Navigate Page
    | ChangePage Page
    | LeaderBoardMsg LeaderBoard.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Navigate page ->
            ( { model | page = page }, Navigation.newUrl <| pageToHash page )

        ChangePage page ->
            ( { model | page = page }, Cmd.none )

        LeaderBoardMsg msg ->
            let
                ( leaderBoardModel, cmd ) =
                    LeaderBoard.update msg model.leaderBoard
            in
                ( { model | leaderBoard = leaderBoardModel }
                , Cmd.map LeaderBoardMsg cmd
                )



-- view


view : Model -> Html Msg
view model =
    let
        page =
            case model.page of
                LeaderBoardPage ->
                    Html.map LeaderBoardMsg
                        (LeaderBoard.view model.leaderBoard)

                NotFound ->
                    div [ class "main" ]
                        [ h1 []
                            [ text "Page Not Found!" ]
                        ]
    in
        div []
            [ pageHeader model
            , page
            ]


pageHeader : Model -> Html Msg
pageHeader model =
    header []
        [ a [ onClick (Navigate LeaderBoardPage) ] [ text "Race Results" ]
        , ul []
            [ li []
                [ a [ href "#" ] [ text "Link" ]
                ]
            ]
        , ul []
            [ li []
                [ a [ href "#" ] [ text "Login" ]
                ]
            ]
        ]



-- subscriptions


subscriptions : Model -> Sub Msg
subscriptions model =
    let
        leaderBoardSub =
            LeaderBoard.subscriptions model.leaderBoard
    in
        Sub.batch
            [ Sub.map LeaderBoardMsg leaderBoardSub
            ]


hashToPage : String -> Page
hashToPage hash =
    case hash of
        "#/" ->
            LeaderBoardPage

        "" ->
            LeaderBoardPage

        _ ->
            NotFound


pageToHash : Page -> String
pageToHash page =
    case page of
        LeaderBoardPage ->
            "#/"

        NotFound ->
            "#notfound"


locationToMsg : Navigation.Location -> Msg
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
