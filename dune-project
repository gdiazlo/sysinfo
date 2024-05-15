(lang dune 3.9)
(name packages)
(license "Apache-2.0")
(authors "Gabriel Díaz")
(maintainers "gdiaz@qswarm.com")
(documentation "https://github.com/gdiazlo/sysinfo")
(package 
 (name sysinfo)
 (allow_empty)
 (synopsis "Show system information as reported by the OS")
 (depends 
  (alcotest :with-test)
  eio)
)
(package 
 (name sysinfo_macos)
 (allow_empty)
 (synopsis "macos system information bits")
 (depends 
  (alcotest :with-test)
  ctypes
  ctypes-foreign
  eio
  eio_posix)
)
(package 
 (name sysinfo_linux)
 (allow_empty)
 (synopsis "linux system information bits")
 (depends 
  (alcotest :with-test)
  eio
  eio_linux)
)