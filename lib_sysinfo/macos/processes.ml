
open Ctypes
open Foreign  
  

(**
 filter is used to specify which processes to list:
  - All: all processes
  - Pgrp: processes in the same process group as the current process
  - Tty: processes with the same controlling terminal as the current process
  - Uid: processes with the same real user id as the current process
  - Ruid: processes with the same effective user id as the current process
  - Ppid: processes with the same parent process id as the current process
  - Kdbg: processes with the same kernel debugger as the current process
*)
type filter = All | Pgrp | Tty | Uid | Ruid | Ppid | Kdbg


(** https://github.com/apple/darwin-xnu/blob/2ff845c2e033bd0ff64b5b6aa6063a1f8f65aa32/bsd/sys/proc_info.h#L55 *)
let filter_to_int x = match x with
  | All -> 1
  | Pgrp -> 2
  | Tty -> 3
  | Uid -> 4
  | Ruid -> 5
  | Ppid -> 6
  | Kdbg -> 7


(** 
  The function proc_listpids returns a list of process ids.contents
      
  This is a fforeign function defined in libproc.h

  https://opensource.apple.com/source/xnu/xnu-2422.1.72/libsyscall/wrappers/libproc/libproc.h.auto.html
*)
let proc_listpids = foreign "proc_listpids" (int @-> int @-> ptr void @-> int @-> returning int)


(** 
  The function `list` retrieves a list of process IDs based on a specified filter.

  @param f A filter of type `filter` which specifies the type of processes to list. The filter can be one of the following:
    - All: all processes
    - Pgrp: processes in the same process group as the current process
    - Tty: processes with the same controlling terminal as the current process
    - Uid: processes with the same real user id as the current process
    - Ruid: processes with the same effective user id as the current process
    - Ppid: processes with the same parent process id as the current process
    - Kdbg: processes with the same kernel debugger as the current process

  It calls `proc_listpids` forein function under the hood.

  @return A list of integers representing the process IDs of the processes that match the specified filter.
*)
let list f =
  let filter = filter_to_int f in
  let bytesSize = proc_listpids filter 0 null 0 in
  let count = bytesSize / (sizeof PosixTypes.pid_t) in
  let pids =  allocate_n PosixTypes.pid_t ~count: count in
  let buf = to_voidp pids in
  let s = proc_listpids 1 0 buf bytesSize in
  let count = s / (sizeof PosixTypes.pid_t) in
  List.init count (fun i -> let p = !@(pids +@ i) in PosixTypes.Pid.to_int p)
(** doing pointer arithmetic in OCAML, what could possibly go wrong ☺ *)

