import gleam/http.{Get, Post, Request, Response}
import gleam/io
import gleam/jsone
import gleam/result
import gleam/bit_string
import gleam/bit_builder
import gleam/string
import decode

// Required function. This is the entrypoint for all incoming requests
pub fn service(req) {
  let path = http.path_segments(req)

  // Handle URL routing here:
  case req.method, path {
    // Respond to a GET request
    Get, [] -> root_get(req)
    // Respond to a POST request
    Post, [] -> root_post(req)
  }
}

// THE FUNCTIONS BELOW THIS POINT IS FOR ILLUSTRATIONAL AND TESTING PURPOSES
// ONLY. YOU SHOULD ADD/IMPLEMENT YOUR OWN FUNCTION LOGIC HERE BELOW!
//
// A function that is invoked when a POST request is sent to localhost:8000 by
// OpenFaaS
pub fn root_post(req: Request(BitString)) {
  let json_data =
    req.body
    |> test_function_post()
  http.response(200)
  |> http.prepend_resp_header("content-type", "application/json")
  |> http.set_resp_body(json_data)
}

fn test_function_post(data) {
  // Decode the JSON data that we received from the entity that invoked the function
  let decoded_data = decode_data_test_function_post(data)
  // Encode JSON data that we will return to the entity that invoked the function
  encode_data_test_function_post(decoded_data)
}

// Define types 'ValueObject' and 'Values' that are used to decode JSON data of the 
// following form:
// {
//    "value": {
//      "name": "Some name here"
//    }
// } 
type ValuesObject {
  ValuesObject(name: String)
}

type Values {
  Values(value: ValuesObject)
}

fn decode_data_test_function_post(data) {
  let json_object_decoder =
    decode.map(ValuesObject, decode.field("name", decode.string()))
  let json_decoder =
    decode.map(Values, decode.field("value", json_object_decoder))

  // Convert BitString to String
  let Ok(string_data) =
    data
    |> bit_string.to_string()

  // Convert String to Gleam types
  let decoded_data =
    string_data
    |> jsone.decode
    |> result.then(decode.decode_dynamic(_, json_decoder))
  case decoded_data {
    Ok(values) -> values
    _ -> Values(value: ValuesObject(name: "there"))
  }
}

fn encode_data_test_function_post(data) {
  // Create some JSON return data for illustration & testing purposes 
  let Ok(encoded_data) =
    jsone.object([
      #("int_field", jsone.int(42)),
      #(
        "string_field",
        jsone.string(string.concat([
          "Hello ",
          data.value.name,
          ", from Gleam & OpenFaaS!",
        ])),
      ),
    ])
    |> jsone.encode
    |> result.then(decode.decode_dynamic(_, decode.bit_string()))
  encoded_data
}

// A fucntion that is invoked when a GET request is sent to localhost:8000 by
// OpenFaaS
pub fn root_get(req: Request(BitString)) {
  let body = bit_string.from_string("Hello from Gleam & OpenFaaS!")
  http.response(200)
  |> http.set_resp_body(body)
}
