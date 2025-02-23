type t =
  { name : string
  ; status : string
  ; enabled : string
  ; description : string
  ; security_exposure : string
  ; security_predicate : string
  ; security_happy : string
  }
[@@deriving yojson]

let get () =
  let dummy_value =
    { name = "dummy_service"
    ; status = "running"
    ; enabled = "yes"
    ; description = "dummy service"
    ; security_exposure = "none"
    ; security_predicate = "none"
    ; security_happy = "yes"
    }
  in
  [ Ok dummy_value ]
;;
