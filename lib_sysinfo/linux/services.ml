type t = string [@@deriving yojson]

let get () = [ Ok "service_a"; Error "service_b" ]
