type t =
  { vendor : string
  ; name : string
  ; version : string
  ; format : string
  ; arch : string
  ; description : string
  ; location : string
  }
[@@deriving yojson]

let get () =
  let dummy_value =
    { vendor = "dummy_vendor"
    ; name = "dummy_name"
    ; version = "dummy_version"
    ; format = "dummy_format"
    ; arch = "dummy_arch"
    ; description = "dummy_description"
    ; location = "dummy_location"
    }
  in
  [ Ok dummy_value ]
;;
