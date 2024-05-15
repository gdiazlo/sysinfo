open Ctypes
open Foreign

type 'a opaque = unit ptr
let opaque = ptr void
(*** https://discuss.ocaml.org/t/how-to-bind-opaque-types-with-ctypes-in-a-type-safe-way/3712/3 *)

type es_message_t
let es_message_t : es_message_t opaque typ = opaque

type es_client_t
let es_client_t  : es_client_t  structure typ = structure "es_client_t"
type es_client_t_ptr = es_client_t structure ptr
let es_client_t_ptr : es_client_t_ptr typ = ptr es_client_t

let es_handler_block_t = es_client_t_ptr @-> es_message_t @-> returning void

let es_new_client = foreign "es_new_client" (ptr es_client_t_ptr @-> funptr es_handler_block_t @-> returning int )

module Es = struct

  let create () =
    let handler _ _ = Format.printf "got event \n" in
    let client_ptr = allocate_n ~count:1 es_client_t_ptr in
    let res = es_new_client client_ptr handler in
    res
end
