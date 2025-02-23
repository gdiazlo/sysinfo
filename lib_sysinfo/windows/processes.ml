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
[@@deriving yojson]

let get () =
  let dummy_value =
    { name = "dummy_process"
    ; id = 1
    ; cmdline = "dummy_cmdline"
    ; cwd = "dummy_cwd"
    ; state = "running"
    ; parent = 1
    ; resident_size = 1024
    ; uid = 1000
    ; gid = 1000
    ; cgroup_path = "dummy_cgroup_path"
    ; rss = 1024
    }
  in
  [ Ok dummy_value ]
;;
