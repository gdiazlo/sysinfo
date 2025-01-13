type t =
  { name : string
  ; version : string
  ; build : string
  ; platform : string
  ; platform_like : string
  ; code_name : string
  }

val of_yojson : Yojson.Safe.t -> (t, string) result
val to_yojson : t -> Yojson.Safe.t
val get : unit -> (t, string) result
