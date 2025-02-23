type t =
  { name : string
  ; version : string
  ; build : string
  ; platform : string
  ; platform_like : string
  ; code_name : string
  }
[@@deriving yojson]

let get () =
  let dummy_value =
    { name = "Windows"
    ; version = "10"
    ; build = "10.0.19045.3570"
    ; platform = "Windows"
    ; platform_like = "Windows"
    ; code_name = "Windows 10"
    }
  in
  Ok dummy_value
;;
