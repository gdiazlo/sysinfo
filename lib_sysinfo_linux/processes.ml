(**

*)

let list_pids () =
  let proc = Unix.opendir "/proc" in
  let pids = Unix.readdir proc in
  let rec aux acc =
    match pids with
    | "." -> acc
    | ".." -> acc
    | pid ->
      let pid = int_of_string pid in
      aux (pid :: acc)
  in
  aux []
;;
