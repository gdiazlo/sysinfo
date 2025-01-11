type t =
  { name : string
  ; status : string
  ; enabled : string
  ; description : string
  }
[@@deriving yojson]

type systemd_unit =
  { unit : string
  ; load : string
  ; active : string
  ; sub : string
  ; description : string
  }
[@@deriving yojson]

type systemd_unit_list = systemd_unit list
[@@deriving yojson]

let get_systemd_services () =
  let cmd = {|systemctl list-units --output=json|} in
  let ic = Unix.open_process_in cmd in
  let rec loop acc =
    match input_line ic with
    | exception End_of_file -> acc
    | line ->
      let su = systemd_unit_list_of_yojson (Yojson.Safe.from_string line) in
      (match su with
       | Ok su ->
         List.map (fun s ->
         Ok
           { name = s.unit
           ; status = s.sub
           ; enabled = s.active
           ; description = s.description
           }) su
         @ acc
       | Error msg ->
         let _ = Printf.printf "Error: %s\n" msg in
         loop (Error msg :: acc))
  in
  let result = loop [] in
  let _ = Unix.close_process_in ic in
  result
;;

let get () = get_systemd_services ()
