port module Main exposing (..)

import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (..)


-- model


type alias Customer =
    { id : String
    , name : String
    }


type alias Model =
    { name : String
    , customers : List Customer
    , error : Maybe String
    , nextId : Int
    }


initModel : Model
initModel =
    { name = ""
    , customers = []
    , error = Nothing
    , nextId = 1
    }


init : ( Model, Cmd Msg )
init =
    ( initModel, Cmd.none )



-- update


type Msg
    = NameInput String
    | SaveCustomer
    | CustomerSaved String
    | CustomerAdded Customer
    | DeleteCustomer Customer
    | CustomerDeleted String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NameInput name ->
            ( { model | name = name }, Cmd.none )

        SaveCustomer ->
            ( model, addCustomer model.name )

        CustomerSaved key ->
            ( { model | name = "" }, Cmd.none )

        CustomerAdded customer ->
            let
                newCustomers =
                    customer :: model.customers
            in
                ( { model | customers = newCustomers }, Cmd.none )

        DeleteCustomer customer ->
            ( model, deleteCustomer customer )

        CustomerDeleted id ->
            let
                newCustomers =
                    List.filter (\customer -> customer.id /= id)
                        model.customers
            in
                ( { model | customers = newCustomers }, Cmd.none )



-- view


viewCustomer : Customer -> Html Msg
viewCustomer customer =
    li []
        [ i [ class "remove", onClick (DeleteCustomer customer) ] []
        , text customer.name
        ]


viewCustomers : List Customer -> Html Msg
viewCustomers customers =
    customers
        |> List.sortBy .id
        |> List.map viewCustomer
        |> ul []


viewCustomerForm : Model -> Html Msg
viewCustomerForm model =
    Html.form [ onSubmit SaveCustomer ]
        [ input [ type_ "text", onInput NameInput, value model.name ] []
        , text <| Maybe.withDefault "" model.error
        , button [ type_ "submit" ] [ text "Save" ]
        ]


view : Model -> Html Msg
view model =
    div []
        [ h1 [] [ text "Customer List" ]
        , viewCustomerForm model
        , viewCustomers model.customers
        ]



-- subscription


subscriptions : Model -> Sub Msg
subscriptions model =
    -- Sub.none
    Sub.batch
        [ customerSaved CustomerSaved
        , newCustomer CustomerAdded
        , customerDeleted CustomerDeleted
        ]


port addCustomer : String -> Cmd msg


port customerSaved : (String -> msg) -> Sub msg


port newCustomer : (Customer -> msg) -> Sub msg


port deleteCustomer : Customer -> Cmd msg


port customerDeleted : (String -> msg) -> Sub msg


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }
