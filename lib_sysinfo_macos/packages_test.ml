
open Packages_impl
open! Alcotest

let find_files_test () =
  match find_files "/private/var/db/receipts/" "plist" with
  | Error(e) -> Alcotest.failf "find_files returned error: %s" e
  | Ok(pkgs) -> Alcotest.(check bool) "non-empty list" true (List.length pkgs > 0)

let convert_plist_to_xml_test () =
  let plist_path = "/private/var/db/receipts/org.openvpn.client.pkg.plist" in
  match convert_plist_to_xml plist_path with
  | Ok v -> Alcotest.(check bool) "XML string is not empty" true ( String.length v > 0)
  | Error msg -> Alcotest.failf "convert_plist_to_xml returned error: %s" msg

let pkg_test : Sysinfo.Package.t = {
  name = "test";
  id = Some "org.openvpn.client.pkg";
  version = Some "3.4.2-4547";
  volume = None;
  installer_system = Some "Installer";
  installed_date = Some "1679348148. 0.";
  location = Some "Applications/OpenVPN Connect/tmp/OpenVPN Connect.app";
  package_name = Some "tmp-app.pkg";
}

let plist_parse_test () =
  let xml_plist = convert_plist_to_xml "/private/var/db/receipts/org.openvpn.client.pkg.plist" in
  match xml_plist with
  | Ok str_plist -> 
      let pkg = Sysinfo.Package.create("test") in
      begin
        try 
          let parsed_plist = Plist_xml.from_string str_plist in
          let parsed_pkg =  parse_plist pkg parsed_plist in
          match parsed_pkg with
          | Ok pkg -> Alcotest.(check bool) "parsed package matches expected" true ( pkg_test = pkg)
          | Error msg -> Alcotest.failf "parse_plist returned error: %s" msg
        with 
        | ex -> Alcotest.failf "Exception: %s" (Printexc.to_string ex)
      end
  | Error _ -> Alcotest.failf "not a plist!"
