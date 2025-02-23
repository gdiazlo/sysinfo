open Ctypes
open Foreign

module HKEY = struct
  let hkey_local_machine = Uintptr.of_int64 0x80000002L
  let hkey_classes_root = Uintptr.of_int64 0x80000001L
  let hkey_current_user = Uintptr.of_int64 0x80000003L
  let hkey_users = Uintptr.of_int64 0x80000005L
  let hkey_current_config = Uintptr.of_int64 0x80000006L
end

module HKEY_PERMS = struct
  let key_read = Unsigned.ULong.of_int64 0x00020019L
end



type hkey = Uintptr
let hkey = uintptr_t
let regsam = ulong
let dword = ulong
let lpdword = ptr ulong
let lstatus = ulong
let lpstr = ptr char
let lpcstr = ptr char
let lpbyte = ptr char
let null_lpcstr = from_voidp char null
let null_lpdword = from_voidp ulong null
let null_lpstr = from_voidp char null
let null_void = from_voidp void null
let new_hkey = allocate hkey Uintptr.zero
let new_lpstr size = CArray.make char size
let new_lpbyte size =
  let carr = CArray.make char size in
  CArray.start carr

let new_lpstr_from_str str =
  let len = String.length str in
  let carr = CArray.make char (len+1) in
  let _ = String.iteri (fun i c -> CArray.set carr i c) str in
  CArray.set carr len '\000';
  CArray.start carr

let new_dword = allocate ulong Unsigned.ULong.zero
let new_dword_from_int i = allocate ulong (Unsigned.ULong.of_int i)

let hkey_software_packages =
  [ new_lpstr_from_str "SOFTWARE\\WOW6432Node\\Microsoft\\Windows\\CurrentVersion\\Uninstall"
  ; new_lpstr_from_str "SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall"
  ]
;;



(**
https://learn.microsoft.com/en-us/windows/win32/api/winreg/nf-winreg-regopenkeyexa

    LSTATUS RegOpenKeyExA(
      [in]           HKEY   hKey,
      [in, optional] LPCSTR lpSubKey,
      [in]           DWORD  ulOptions,
      [in]           REGSAM samDesired,
      [out]          PHKEY  phkResult
    );

*)

(* RegOpenKeyExA binding *)
let reg_open_key_ex =
  foreign
    "RegOpenKeyExA"
    (hkey (* hKey *)
     @-> lpstr (* lpSubKey *)
     @-> dword (* ulOptions *)
     @-> regsam (* samDesired *)
     @-> ptr hkey (* phkResult *)
     @-> returning lstatus)
;;

(* RegEnumKeyExA binding *)
(**
https://learn.microsoft.com/en-us/windows/win32/api/winreg/nf-winreg-regenumkeyexa

    LSTATUS RegEnumKeyExA(
      [in]                HKEY      hKey,
      [in]                DWORD     dwIndex,
      [out]               LPSTR     lpName,
      [in, out]           LPDWORD   lpcchName,
                          LPDWORD   lpReserved,
      [in, out]           LPSTR     lpClass,
      [in, out, optional] LPDWORD   lpcchClass,
      [out, optional]     PFILETIME lpftLastWriteTime
    );

*)
let reg_enum_key_ex =
  foreign
    "RegEnumKeyExA"
    (hkey (* hKey *)
     @-> dword (* dwIndex *)
     @-> lpstr (* lpName *)
     @-> lpdword (* lpcchName *)
     @-> lpdword (* lpReserved *)
     @-> lpstr (* lpClass *)
     @-> lpdword (* lpcchClass *)
     @-> ptr void (* lpftLastWriteTime *)
     @-> returning lstatus)
;;

(**
https://learn.microsoft.com/en-us/windows/win32/api/winreg/nf-winreg-regqueryvalueexa

  LSTATUS RegQueryValueExA(
    [in]                HKEY    hKey,
    [in, optional]      LPCSTR  lpValueName,
                        LPDWORD lpReserved,
    [out, optional]     LPDWORD lpType,
    [out, optional]     LPBYTE  lpData,
    [in, out, optional] LPDWORD lpcbData
  );
*)

let reg_query_value_ex_a =
  foreign
    "RegQueryValueExA"
    (hkey (* hKey *)
     @-> lpcstr (* lpValueName *)
     @-> lpdword (* lpReserved *)
     @-> ptr dword (* lpType *)
     @-> lpbyte (* lpData *)
     @-> lpdword (* lpcbData *)
     @-> returning lstatus)
;;


(**
https://learn.microsoft.com/en-us/windows/win32/api/winreg/nf-winreg-regclosekey

LSTATUS RegCloseKey(
  [in] HKEY hKey
);

*)

let reg_close_key =
  foreign
    "RegCloseKey"
    (hkey (* hKey *)
     @-> returning lstatus)
;;


let%expect_test "RegOpenKeyExA" =
  let path = List.hd hkey_software_packages in
  let ptr_hkey = allocate hkey Uintptr.zero in
  let r =
    reg_open_key_ex
      HKEY.hkey_local_machine
      path
      Unsigned.ULong.zero
      HKEY_PERMS.key_read
      ptr_hkey
  in
  Printf.printf "r: %s\n" (Unsigned.ULong.to_string r);
  [%expect {| r: 0 |}]
;;

let%expect_test "RegEnumKeyExA" =
  let path = List.hd hkey_software_packages in
  let ptr_hkey = allocate hkey Uintptr.zero in
  let r =
    reg_open_key_ex
      HKEY.hkey_local_machine
      path
      Unsigned.ULong.zero
      HKEY_PERMS.key_read
      ptr_hkey
  in
  if r = Unsigned.ULong.zero
  then (
    let hkey = HKEY.hkey_local_machine in
    let dwIndex = Unsigned.ULong.zero in
    let lpName = new_lpstr 256 in
    let ptr_lpName = CArray.start lpName in
    let lpcchName = Unsigned.ULong.of_int 256 in
    let ptr_lpcchName = allocate ulong lpcchName in
    let r =
      reg_enum_key_ex
        hkey
        dwIndex
        ptr_lpName
        ptr_lpcchName
        null_lpdword
        null_lpstr
        null_lpdword
        null_void
    in
    Printf.printf "r: %s\n" (Unsigned.ULong.to_string r);
    [%expect {| r: 0 |}])
;;


let%expect_test "RegQueryValueExA" =
let path = List.hd hkey_software_packages in
let ptr_hkey = allocate hkey Uintptr.zero in
let read_data a_ptr = 
  let arr = CArray.from_ptr a_ptr 512 in
  String.init 512 (fun i -> CArray.get arr i) in
let open_key () =
  let r = reg_open_key_ex HKEY.hkey_local_machine path Unsigned.ULong.zero HKEY_PERMS.key_read ptr_hkey in
  if r <> Unsigned.ULong.zero then
    raise (Failure "RegOpenKeyExA failed")
  else
  ptr_hkey
in
let get_info ptr_hkey props =
  let dwIndex = Unsigned.ULong.zero in
  let subKeyName =
    let carr = CArray.make char 256 in
    CArray.start carr in
  let subKeyNameSize = allocate ulong (Unsigned.ULong.of_int 256) in
  let a_hkey = !@ptr_hkey in
  let info = ref [] in
  let enum_keys () = reg_enum_key_ex a_hkey dwIndex subKeyName subKeyNameSize null_lpdword null_lpstr null_lpdword null_void in
  let count = ref 0 in
  while enum_keys () = Unsigned.ULong.zero do
    incr count;
    let hSubKey = allocate hkey Uintptr.zero in
    if reg_open_key_ex a_hkey subKeyName Unsigned.ULong.zero HKEY_PERMS.key_read hSubKey = Unsigned.ULong.zero then (
      let datasize = new_dword_from_int 512 in
      let typ = new_dword in
      let data = new_lpbyte 512 in
      let entry = List.map (fun p ->
        let key = (new_lpstr_from_str p) in
        let r = reg_query_value_ex_a a_hkey key null_lpdword typ data datasize in
        if r = Unsigned.ULong.zero
        then read_data data
        else ""
      ) props in
      info := !info @ entry;
    )
  done;
  Printf.printf "count: %d\n" !count;
  [%expect {| count: 5 |}];
  !info in
  let k = open_key () in
  let info = get_info k ["DisplayName"; "DisplayVersion"; "InstallDate"] in
  (* print list ref *)
  List.iter (Printf.printf "%s\n") info;
  [%expect {| emtpy |}];
;;