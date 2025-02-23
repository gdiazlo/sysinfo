open Ctypes
open Foreign
open Posix_types

(**
  The getgrouplist() function scans the group database (see
  group(5)) to obtain the list of groups that user belongs to.  Up
  to *ngroups of these groups are returned in the array groups.

  See: https://man7.org/linux/man-pages/man3/getgrouplist.3.html

  Its C definition is:

      int getgrouplist(const char *user, gid_t group, gid_t *groups, int *ngroups);
*)
let getgrouplist =
  foreign "getgrouplist" (string @-> gid_t @-> ptr gid_t @-> ptr int @-> returning int)
;;

(**
  ctypes group struct defined to access the fields of the C group struct
  defined in grp.h

    struct group {
      char   *gr_name;        // group name
      char   *gr_passwd;      // group password
      gid_t   gr_gid;         // group ID
      char  **gr_mem;         // group members
    };

*)
type struct_group

let struct_group : struct_group structure typ = structure "struct_group"
let gr_name = field struct_group "gr_name" string
let gr_passwd = field struct_group "gr_passwd" string
let gr_gid = field struct_group "gr_gid" gid_t
let gr_mem = field struct_group "gr_mem" (ptr (ptr char))
let () = seal struct_group

(**
  The getgrgid() function shall search the group database for an
  entry with a matching gid.

  See: https://man7.org/linux/man-pages/man3/getgrgid.3p.html

  Its C definition is:

      struct group *getgrgid(gid_t gid);
*)
let getgrgid =
  foreign "getgrgid" ~check_errno:true (gid_t @-> returning (ptr_opt struct_group))
;;

(* Get a list the gids of a given user *)
let get_user_groups user =
  let primary_group = Unix.getpwnam user in
  let group = Gid.of_int primary_group.Unix.pw_gid in
  let groups = CArray.make gid_t 500 in
  let ngroups = allocate int 500 in
  (* allocates an integer with value 500 *)
  let result = getgrouplist user group (CArray.start groups) ngroups in
  if result > 0
  then
    List.init result (fun i ->
      let gid = CArray.get groups i in
      Posix_types.Gid.to_int gid)
  else (
    Format.printf "Error returned by getgrouplist(7): %d ngroups = %d\n" result !@ngroups;
    [])
;;

let%expect_test "get_user_groups" =
  let username = "gdiazlo" in
  let pp_int_list =
    Format.pp_print_list
      ~pp_sep:(fun fmt () -> Format.fprintf fmt ", ")
      Format.pp_print_int
  in
  match get_user_groups username with
  | [] -> ()
  | groups ->
    Format.printf "Groups for user %s: %a\n" username pp_int_list groups;
    [%expect
      {| Groups for user gdiazlo: 1000, 4, 24, 27, 30, 46, 100, 995, 993, 114, 128, 983 |}]
;;

let get_members ptr =
  let strlen ptr =
    let rec loop i = if is_null !@(ptr +@ i)  then i else loop (i + 1) in
    loop 0
  in
  let rec ptrlen i = if is_null !@(ptr +@ i) then i else ptrlen (i + 1) in
  let len = ptrlen 0 in
  List.init len (fun i ->
    let str_ptr = !@(ptr +@ i) in
    let str_len = strlen str_ptr in
    string_from_ptr !@str_ptr ~length:str_len)
;;

(* 
let%expect_test "get_group_name" =
  let gid = 4 in
  let pp_string_list =
    Format.pp_print_list
      ~pp_sep:(fun fmt () -> Format.fprintf fmt ", ")
      Format.pp_print_string
  in
  match getgrgid (Gid.of_int gid) with
  | None -> ()
  | Some group ->
    let name = getf !@group gr_name in
    let gid = getf !@group gr_gid |> Gid.to_int in
    let pass = getf !@group gr_passwd in
    let members = getf !@group gr_mem in
    Format.printf
      "Id %d Name %s Pass %s Members %a\n"
      gid
      name
      pass
      pp_string_list
      (get_members members);
    [%expect {| Id 4 Name adm Pass x Members syslog, gdiazlo |}]
;;
*)