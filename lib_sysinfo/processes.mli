type t =
  { name : string
  ; id : int
  ; cmdline : string
  ; cwd : string
  ; state : string
  ; parent : int
  ; resident_size : int
  ; uid : int
  ; gid : int
  ; cgroup_path : string
  ; rss : int
  }

val of_yojson : Yojson.Safe.t -> (t, string) result
val to_yojson : t -> Yojson.Safe.t
val get : unit -> (t, string) result list
