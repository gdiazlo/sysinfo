open Yojson

type t =
  { name : string
  ; id : string option
  ; version : string option
  ; volume : string option
  ; installer_system : string option
  ; installed_date : string option
  ; location : string option
  ; package_name : string option
  }

let create name =
  { name
  ; id = None
  ; version = None
  ; volume = None
  ; installer_system = None
  ; installed_date = None
  ; location = None
  ; package_name = None
  }
;;

let to_yojson t =
  `Assoc
    [ "name", `String t.name
    ; ( "id"
      , match t.id with
        | Some id -> `String id
        | None -> `Null )
    ; ( "version"
      , match t.version with
        | Some version -> `String version
        | None -> `Null )
    ; ( "volume"
      , match t.volume with
        | Some volume -> `String volume
        | None -> `Null )
    ; ( "installer_system"
      , match t.installer_system with
        | Some system -> `String system
        | None -> `Null )
    ; ( "installed_date"
      , match t.installed_date with
        | Some date -> `String date
        | None -> `Null )
    ; ( "location"
      , match t.location with
        | Some location -> `String location
        | None -> `Null )
    ; ( "package_name"
      , match t.package_name with
        | Some package_name -> `String package_name
        | None -> `Null )
    ]
;;

let to_json_string t = to_yojson t |> to_string
