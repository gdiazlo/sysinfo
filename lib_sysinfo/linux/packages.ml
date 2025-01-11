type t = {
  vendor: string;
  name : string;
  version: string;
  format: string;
  arch: string;
  description: string;
  location: string;
} [@@deriving yojson]



let get_dpkg_packages () =
  let cmd = {|dpkg-query -W -f='{"vendor": "${Maintainer}", "name": "${Package}", "version": "${Version}", "arch": "${Architecture}", "location": "dpkg-query", "format": "deb", "description": ""}\n' |} in
  let ic = Unix.open_process_in cmd in
  let rec loop acc =
    match input_line ic with
    | exception End_of_file -> acc
    | line ->
      let _ = Printf.printf "Line: %s\n" line in
      let pkg = of_yojson (Yojson.Safe.from_string line) in
      match pkg with
      | Ok pkg -> loop (Ok pkg :: acc)
      | Error msg -> Printf.printf "Error: %s\n" msg;
        loop ( (Error msg) :: acc)

  in
  let result = loop [] in
  let _ = Unix.close_process_in ic in
  result

let get () =
  get_dpkg_packages ()
