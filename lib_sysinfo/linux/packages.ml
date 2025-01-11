type t = {
  vendor: string;
  name : string;
  version: string;
  format: string;
  arch: string;
  description: string;
  location: string;
} [@@deriving yojson]

let get () = [ Ok {
  vendor = "vendor";
  name = "name";
  version = "version";
  format = "format";
  arch = "arch";
  description = "description";
  location = "location";
}]
