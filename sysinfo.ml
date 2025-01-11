open Sysinfo

let run_cmd cmd =
  match cmd with
  | "packages" ->
    let pl = Packages.get () in
    let _ = Printf.printf "Packages: %d\n" (List.length pl) in
    pl
    |> List.filter_map Result.to_option
    |> List.iter (fun r ->
      r |> Packages.to_yojson |> Yojson.Safe.pretty_to_string |> print_endline)
  | "processes" ->
    Processes.get ()
    |> List.filter_map Result.to_option
    |> List.iter (fun r ->
      r |> Processes.to_yojson |> Yojson.Safe.pretty_to_string |> print_endline)
  | "services" ->
    Services.get ()
    |> List.filter_map Result.to_option
    |> List.iter (fun r ->
      r |> Services.to_yojson |> Yojson.Safe.pretty_to_string |> print_endline)
  | _ ->
    print_endline "Invalid command";
    ()
;;

(**
 Parse argv and select the appropriate function to call from:
 - packages -> list all packages
  - processes -> list all processes
*)
let parse_args () =
  let usage = "Usage: sysinfo [packages|processes]" in
  match Array.length Sys.argv with
  | 2 -> run_cmd Sys.argv.(1)
  | _ ->
    print_endline usage;
    ()
;;

let () = parse_args ()
