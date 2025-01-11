(**
  Linux services are obtained from systemd.

  The systemd API is based on D-Bus as described in the following link:
  https://www.freedesktop.org/software/systemd/man/latest/org.freedesktop.systemd1.html#

  To access D-BUS API, there is a ocaml library called OBUS
*)

let kDestination = "org.freedesktop.systemd1"
let kInterface = "org.freedesktop.systemd1.Manager"
let kMethod = "ListUnits"

type unit =
  { id : string
  ; description : string
  ; load_state : string
  ; active_state : string
  ; sub_state : string
  ; followed : string
  ; path : string
  ; job_id : int
  ; job_type : string
  ; job_path : string
  }
