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

(** Returns a list of all pids as read in /proc *)
let get_pids () =
  let pids = Sys.readdir "/proc" in
  let is_pid pid =
    try
      ignore (int_of_string pid);
      true
    with
    | _ -> false
  in
  Array.to_list pids |> List.filter is_pid |> List.map int_of_string
;;

(** read a filename into a string. This fnuction eliminates null chars
and substitute them by spaces. This can be found in /proc/pid/cmdline for example
*)
let read_file filename =
  let ic = open_in filename in
  let buffer = Buffer.create 1024 in
  let rec read_line () =
    try
      let line = input_line ic in
      let parsed_line = String.map (fun c -> if c = '\000' then ' ' else c) line in
      Buffer.add_string buffer parsed_line;
      read_line ()
    with
    | End_of_file -> ()
  in
  read_line ();
  close_in ic;
  Buffer.contents buffer |> String.trim
;;

let split_on_last_char ch s =
  try
    let pos = String.rindex s ch in
    String.sub s (pos + 1) (String.length s - pos - 1) |> String.trim
  with
  | Not_found -> ""
;;

(** Filter a string based on a predicate *)
(*
   let string_filter f str =
  let buf = Buffer.create (String.length str) in
  String.iter (fun c -> if f c then Buffer.add_char buf c) str;
  Buffer.contents buf
;;
*)

let parse_stat pid name cmdline cwd cgroup_path stat =
  let descr_state state =
    match state with
    | "R" -> "Running"
    | "S" -> "Sleeping"
    | "D" -> "Waiting"
    | "Z" -> "Zombie"
    | "T" -> "Stopped"
    | "t" -> "Tracing stop"
    | "W" -> "Waking"
    | "X" -> "Dead"
    | "x" -> "Dead"
    | "K" -> "Wakekill"
    | "P" -> "Parked"
    | "I" -> "Idle"
    | _ -> Format.sprintf "Unknown state: %s" state
  in
  try
    let data = split_on_last_char ')' stat |> String.split_on_char ' ' in
    Ok
      { name
      ; id = pid
      ; cmdline
      ; cwd
      ; state = descr_state (List.nth data 0)
      ; parent = int_of_string (List.nth data 1)
      ; resident_size = int_of_string (List.nth data 21)
      ; uid = int_of_string (List.nth data 5)
      ; gid = int_of_string (List.nth data 6)
      ; cgroup_path
      ; rss =
          (try int_of_string (List.nth data 21) with
           | _ -> -1)
      }
  with
  | e ->
    let msg = Printexc.to_string e in
    Error msg
;;

(** For a given pid, this function reads /proc/$pid/status and creates a
    process record.
See https://man7.org/linux/man-pages/man5/proc_pid_stat.5.html for
more information on the fields
*)
let to_proccess pid =
  let pid_str = string_of_int pid in
  let stat_file = "/proc/" ^ pid_str ^ "/stat" in
  try
    let status_str = read_file stat_file in
    let name = read_file ("/proc/" ^ pid_str ^ "/comm") in
    let cmdline = read_file ("/proc/" ^ pid_str ^ "/cmdline") in
    let cwd =
      try Unix.readlink ("/proc/" ^ pid_str ^ "/cwd") with
      | _ -> "No access"
    in
    let cgroup_path = read_file ("/proc/" ^ pid_str ^ "/cgroup") in
    parse_stat pid name cmdline cwd cgroup_path status_str
  with
  | e ->
    let msg = Printexc.to_string e in
    Error msg
;;

let get () =
  let pids = get_pids () in
  List.map to_proccess pids
;;
