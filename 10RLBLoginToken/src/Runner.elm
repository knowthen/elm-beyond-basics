module Runner exposing (..)

import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (..)
import String


-- model


type alias Model =
    { id : String
    , name : String
    , nameError : Maybe String
    , location : String
    , locationError : Maybe String
    , age : String
    , ageError : Maybe String
    , bib : String
    , bibError : Maybe String
    , error : Maybe String
    }


initModel : Model
initModel =
    { id = ""
    , name = ""
    , nameError = Nothing
    , location = ""
    , locationError = Nothing
    , age = ""
    , ageError = Nothing
    , bib = ""
    , bibError = Nothing
    , error = Nothing
    }


init : ( Model, Cmd Msg )
init =
    ( initModel, Cmd.none )



-- update


type Msg
    = NameInput String
    | LocationInput String
    | AgeInput String
    | BibInput String
    | Save


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NameInput name ->
            ( { model
                | name = name
                , nameError = Nothing
              }
            , Cmd.none
            )

        LocationInput location ->
            ( { model
                | location = location
                , locationError = Nothing
              }
            , Cmd.none
            )

        AgeInput age ->
            ageInput model age

        BibInput bib ->
            bibInput model bib

        Save ->
            ( model, Cmd.none )


ageInput : Model -> String -> ( Model, Cmd Msg )
ageInput model age =
    let
        ageInt =
            age
                |> String.toInt
                |> Result.withDefault 0

        ageError =
            if ageInt <= 0 then
                Just "Must Enter a Positive Number"
            else
                Nothing
    in
        ( { model | age = age, ageError = ageError }, Cmd.none )


bibInput : Model -> String -> ( Model, Cmd Msg )
bibInput model bib =
    let
        bibInt =
            bib
                |> String.toInt
                |> Result.withDefault 0

        bibError =
            if bibInt <= 0 then
                Just "Must Enter a Positive Number"
            else
                Nothing
    in
        ( { model | bib = bib, bibError = bibError }, Cmd.none )



-- view


view : Model -> Html Msg
view model =
    div [ class "main" ]
        [ errorPanel model.error
        , viewForm model
        ]


errorPanel : Maybe String -> Html a
errorPanel error =
    case error of
        Nothing ->
            text ""

        Just msg ->
            div [ class "error" ]
                [ text msg
                ]


viewForm : Model -> Html Msg
viewForm model =
    Html.form [ class "add-runner", onSubmit Save ]
        [ fieldset []
            [ legend [] [ text "Add / Edit Runner" ]
            , div []
                [ label [] [ text "Name" ]
                , input
                    [ type_ "text"
                    , value model.name
                    , onInput NameInput
                    ]
                    []
                , span [] [ text <| Maybe.withDefault "" model.nameError ]
                ]
            , div []
                [ label [] [ text "Location" ]
                , input
                    [ type_ "text"
                    , value model.location
                    , onInput LocationInput
                    ]
                    []
                , span [] [ text <| Maybe.withDefault "" model.locationError ]
                ]
            , div []
                [ label [] [ text "Age" ]
                , input
                    [ type_ "text"
                    , value model.age
                    , onInput AgeInput
                    ]
                    []
                , span [] [ text <| Maybe.withDefault "" model.ageError ]
                ]
            , div []
                [ label [] [ text "Bib #" ]
                , input
                    [ type_ "text"
                    , value model.bib
                    , onInput BibInput
                    ]
                    []
                , span [] [ text <| Maybe.withDefault "" model.bibError ]
                ]
            , div []
                [ label [] []
                , button [ type_ "submit" ] [ text "Save" ]
                ]
            ]
        ]



-- subscriptions


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
