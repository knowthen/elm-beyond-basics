module SimpleDecoding exposing (..)

import Html exposing (..)
import Json.Decode exposing (..)


json : String
json =
    """
{
   "type":"success",
   "value":{
      "id":496,
      "joke":"Chuck Norris doesnt wear a watch, HE decides what time it is.",
      "categories":[
         "nerdy"
      ]
   }
}
"""


decoder : Decoder String
decoder =
    at [ "value", "joke" ] string


jokeResult : Result String String
jokeResult =
    decodeString decoder json


main : Html msg
main =
    case jokeResult of
        Ok joke ->
            text joke

        Err err ->
            text err
