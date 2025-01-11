let find_files path extension =
  let matcher = Str.regexp (".*\\." ^ extension ^ "$") in
  let walk path =
    try
      Sys.readdir path
      |> Array.fold_left
           (fun acc name ->
              let filepath = Filename.concat path name in
              if Sys.is_directory filepath
              then acc
              else if Str.string_match matcher name 0
              then filepath :: acc
              else acc)
           []
      |> fun acc -> Ok acc
    with
    | Sys_error msg -> Error msg
  in
  walk path
;;

let convert_plist_to_xml filepath = C_plist_xml.convert filepath

let rec string_of_plist_t = function
  | `Array lst -> List.fold_left (fun str v -> str ^ " " ^ string_of_plist_t v) "" lst
  | `Bool b -> string_of_bool b
  | `Data s -> s
  | `Date (f, opt) ->
    string_of_float f
    ^ " "
    ^ Option.value ~default:"None" (Option.map string_of_float opt)
  | `Dict _ -> "Not implemented"
  | `Float f -> string_of_float f
  | `Int i -> string_of_int i
  | `String s -> s
;;

let parse_plist pkg plist =
  match plist with
  | `Dict lst ->
    let p =
      List.fold_left
        (fun (pkg : Sysinfo.Package.t) (k, v) ->
           match k with
           | "InstallDate" -> { pkg with installed_date = Some (string_of_plist_t v) }
           | "InstallPrefixPath" -> { pkg with location = Some (string_of_plist_t v) }
           | "InstallProcessName" ->
             { pkg with installer_system = Some (string_of_plist_t v) }
           | "PackageFileName" -> { pkg with package_name = Some (string_of_plist_t v) }
           | "PackageIdentifier" -> { pkg with id = Some (string_of_plist_t v) }
           | "PackageVersion" -> { pkg with version = Some (string_of_plist_t v) }
           | _ -> pkg)
        pkg
        lst
    in
    Ok p
  | _ -> Error "Invalid plist format!"
;;

let list _ = Error "Not implemented"
