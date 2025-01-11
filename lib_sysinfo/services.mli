type t =
  { name : string
  ; status : string
  ; enabled : string
  ; description : string
  }

val of_yojson : Yojson.Safe.t -> (t, string) result
val to_yojson : t -> Yojson.Safe.t
val get : unit -> (t, string) result list
