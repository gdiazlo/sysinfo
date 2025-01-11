open Sysinfo_macos.Packages.Test

let () =
  let open Alcotest in
  run
    "Packages"
    [ "filesystem", [ test_case "find files" `Quick find_files_test ]
    ; ( "plist"
      , [ test_case "convert a plist to xml string" `Quick convert_plist_to_xml_test
        ; test_case "parse a plist" `Quick plist_parse_test
        ] )
    ]
;;
