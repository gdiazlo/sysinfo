type t =
  { name : string
  ; full_name : string
  ; shell : string
  ; home : string
  ; uid : int
  ; gid : int
  ; groups : string list
  }
[@@deriving yojson]

let get () =
  let dummy_value =
    { name = "dummy_user"
    ; full_name = "Dummy User"
    ; shell = "/bin/bash"
    ; home = "/home/dummy_user"
    ; uid = 1000
    ; gid = 1000
    ; groups = [ "dummy_group" ]
    }
  in
  [ Ok dummy_value ]
;;
