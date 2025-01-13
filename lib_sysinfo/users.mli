type t =
  { name : string
  ; full_name : string
  ; shell : string
  ; home : string
  ; uid : int
  ; gid : int
  ; groups : string list
  }

val of_yojson : Yojson.Safe.t -> (t, string) result
val to_yojson : t -> Yojson.Safe.t
val get : unit -> (t, string) result list
