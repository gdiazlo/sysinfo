open Ctypes
open Foreign

let c_convert_plist_to_xml =
  foreign "convertPlistAtPathToXMLCString" (string @-> ptr char @-> returning string_opt)
;;

let convert filepath =
  let error_buffer = CArray.make char ~initial:'\x00' 1024 in
  match c_convert_plist_to_xml filepath (CArray.start error_buffer) with
  | Some str -> Ok str
  | None ->
    let error_str =
      Ctypes.(
        string_from_ptr (CArray.start error_buffer) ~length:(CArray.length error_buffer))
    in
    if error_str = "" then Error "Unknown error" else Error error_str
;;
