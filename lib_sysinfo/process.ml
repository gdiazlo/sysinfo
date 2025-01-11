open Yojson.Safe

type t = { id : int }

let create id = { id }
let to_yojson t = `Assoc [ "id", `Int t.id ]
let to_json_string t = to_yojson t |> to_string
