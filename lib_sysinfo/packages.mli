type t =
  { vendor : string
  ; name : string
  ; version : string
  ; format : string
  ; arch : string
  ; description : string
  ; location : string
  }

val of_yojson : Yojson.Safe.t -> (t, string) result
val to_yojson : t -> Yojson.Safe.t
val get : unit -> (t, string) result list
