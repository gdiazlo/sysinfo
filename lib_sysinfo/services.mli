type t =
  { name : string
  ; status : string
  ; enabled : string
  ; description : string
  ; security_exposure : string
  ; security_predicate : string
  ; security_happy : string
  }

val of_yojson : Yojson.Safe.t -> (t, string) result
val to_yojson : t -> Yojson.Safe.t
val get : unit -> (t, string) result list
