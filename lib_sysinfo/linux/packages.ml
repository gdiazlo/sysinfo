type t =
  { vendor : string
  ; name : string
  ; version : string
  ; format : string
  ; arch : string
  ; description : string
  ; location : string
  }
[@@deriving yojson]

let is_executable file =
  try
    let mode = Unix.stat file in
    mode.Unix.st_perm land 0o100 <> 0 (* Check if the execute permission is set *)
  with
  | Unix.Unix_error (_, _, _) ->
    false (* Return false if an error occurs (e.g., file does not exist) *)
;;

let get_dpkg_packages () =
  let cmd =
    {|dpkg-query -W -f='{"vendor": "${Maintainer}", "name": "${Package}", "version": "${Version}", "arch": "${Architecture}", "location": "dpkg-query", "format": "deb", "description": ""}\n' |}
  in
  let ic = Unix.open_process_in cmd in
  let rec loop acc =
    match input_line ic with
    | exception End_of_file -> acc
    | line ->
      let pkg = of_yojson (Yojson.Safe.from_string line) in
      (match pkg with
       | Ok pkg -> loop (Ok pkg :: acc)
       | Error msg ->
         loop (Error msg :: acc))
  in
  let result = loop [] in
  let _ = Unix.close_process_in ic in
  result
;;

let get_rpm_packages () =
  let cmd =
    {|rpm -qa --qf='\{"vendor": "%{VENDOR}", "name": "%{NAME}", "version": "%{VERSION}", "arch": "%{ARCH}", "location": "rpm", "format": "rpm", "description": "%{SUMMARY}"\}\n'|}
  in
  let ic = Unix.open_process_in cmd in
  let rec loop acc =
    match input_line ic with
    | exception End_of_file -> acc
    | line ->
      let pkg = of_yojson (Yojson.Safe.from_string line) in
      (match pkg with
       | Ok pkg -> loop (Ok pkg :: acc)
       | Error msg ->
         loop (Error msg :: acc))
  in
  let result = loop [] in
  let _ = Unix.close_process_in ic in
  result
;;

let get () =
  if is_executable "/usr/bin/dpkg-query"
  then get_dpkg_packages ()
  else if is_executable "/usr/bin/rpm"
  then get_rpm_packages ()
  else [ Error "No package manager found" ]
;;
