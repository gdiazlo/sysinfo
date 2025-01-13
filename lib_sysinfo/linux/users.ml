open Stdio

type t =
  { name : string
  ; full_name : string
  ; shell : string
  ; home : string
  ; uid : int
  ; gid : int
  ; groups : string list
  }
[@@deriving yojson]

let string_contains str1 str2 =
  let len1 = String.length str1 in
  let len2 = String.length str2 in
  if len2 > len1
  then false
  else (
    let rec loop i =
      if i > len1 - len2
      then false
      else if String.sub str1 i len2 = str2
      then true
      else loop (i + 1)
    in
    loop 0)
;;

(**
  Get the groups of local users in the system.

  See https://github.com/osquery/osquery/issues/8337
  as why not use libc standard functions to get the list of users.
  *)
let get_groups_for_user name =
  let file = "/etc/group" in
  let lines = In_channel.read_lines file in
  List.fold_left
    (fun acc line ->
       if string_contains line name
       then (
         let parts = String.split_on_char ':' line in
         let group_name = List.nth parts 0 in
         group_name :: acc)
       else acc)
    []
    lines
;;

(**
  Get the list of local users in the system.

  See https://github.com/osquery/osquery/issues/8337
  as why not use libc standard functions to get the list of users.
  *)
let get () =
  let file = "/etc/passwd" in
  let lines = In_channel.read_lines file in
  List.map
    (fun line ->
       let parts = String.split_on_char ':' line in
       let name = List.nth parts 0 in
       let _ = List.nth parts 1 in
       let uid = List.nth parts 2 in
       let gid = List.nth parts 3 in
       let full_name = List.nth parts 4 in
       let home = List.nth parts 5 in
       let shell = List.nth parts 6 in
       Ok
         { name
         ; full_name
         ; shell
         ; home
         ; uid = int_of_string uid
         ; gid = int_of_string gid
         ; groups = get_groups_for_user name
         })
    lines
;;
