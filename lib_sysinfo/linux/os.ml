type t =
  { name : string
  ; version : string
  ; build : string
  ; platform : string
  ; platform_like : string
  ; code_name : string
  }
[@@deriving yojson]

(**
 parses /etc/os-release file and returns a t record
*)
let get_os_release () =
  let clean_quotes s =
    let len = String.length s in
    if len > 1 && s.[0] = '"' && s.[len - 1] = '"' then String.sub s 1 (len - 2) else s
  in
  let ic = open_in "/etc/os-release" in
  let rec loop acc =
    match input_line ic with
    | exception End_of_file -> acc
    | line ->
      let kv = String.split_on_char '=' line in
      (match kv with
       | k :: v :: _ ->
         let k = String.trim k in
         let v = String.trim v in
         (match k with
          | "NAME" -> loop { acc with name = clean_quotes v }
          | "VERSION" -> loop { acc with version = clean_quotes v }
          | "BUILD_ID" -> loop { acc with build = clean_quotes v }
          | "ID" -> loop { acc with platform = clean_quotes v }
          | "ID_LIKE" -> loop { acc with platform_like = clean_quotes v }
          | "VERSION_CODENAME" -> loop { acc with code_name = clean_quotes v }
          | _ -> loop acc)
       | _ -> loop acc)
  in
  let result =
    loop
      { name = ""
      ; version = ""
      ; build = ""
      ; platform = ""
      ; platform_like = ""
      ; code_name = ""
      }
  in
  let _ = close_in ic in
  Ok result
;;

let%expect_test "get" =
  let os = get_os_release () in
  let pp_os fmt os =
    match os with
    | Error e -> Format.fprintf fmt "Error: %s\n" e
    | Ok os ->
      Format.fprintf fmt "name: %s\n" os.name;
      Format.fprintf fmt "version: %s\n" os.version;
      Format.fprintf fmt "build: %s\n" os.build;
      Format.fprintf fmt "platform: %s\n" os.platform;
      Format.fprintf fmt "platform_like: %s\n" os.platform_like;
      Format.fprintf fmt "code_name: %s\n" os.code_name
  in
  Format.printf "%a\n" pp_os os;
  [%expect
    {|
    name: Ubuntu
    version: 24.10 (Oracular Oriole)
    build:
    platform: ubuntu
    platform_like: debian
    code_name: oracular
    |}]
;;

let get () = get_os_release ()
