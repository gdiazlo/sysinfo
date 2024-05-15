
open Sysinfo_macos
open Sysinfo

let _ =
  match Packages.list ".*" with
  | Ok(pkglist) ->
    List.map (fun p -> 
      match p with
      | Ok(pkg) -> Package.to_yojson pkg |> Yojson.Safe.pretty_to_string
      | Error(_) -> "Error: Invalid package"
    ) pkglist |> List.iter print_endline
  | Error(e) -> Format.printf "Error: %s\n" e


