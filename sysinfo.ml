open Sysinfo

(**
 Parse argv and select the appropriate function to call from:
 - packages -> list all packages
  - processes -> list all processes
*)
let parse_args () =
  let usage = "Usage: sysinfo [packages|processes]" in
  match Array.length Sys.argv with
  | 2 -> run_cmd Sys.argv.(1)
  | _ -> usage
;;

let run_cmd cmd =
  match cmd with
  | "packages" -> list_packages ()
  | "processes" -> list_processes ()
  | _ -> "Invalid command"
;;

let _ =
  match Packages.list ".*" with
  | Ok pkglist ->
    List.map
      (fun p ->
         match p with
         | Ok pkg -> Package.to_yojson pkg |> Yojson.Safe.pretty_to_string
         | Error _ -> "Error: Invalid package")
      pkglist
    |> List.iter print_endline
  | Error e -> Format.printf "Error: %s\n" e
;;
