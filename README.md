# SysInfo

SysInfo is an OCaml library designed to provide access to system-level information.

# Motivation

Learn Ocaml systems programming, portability and macOS internals.

# Current status

TODO

- [ ] Operating system
- [ ] Firmware
- [ ] CPU
- [ ] Memory
- [ ] Kernel
- [ ] System services
- [ ] Processes
- [ ] Packages
- [ ] Network services
- [ ] Users
- [ ] Groups
- [ ] Filesystems
- [ ] Namespaces
- [ ] Files

Nice to have:

- [ ] MacOs endpoint security

# Structure of the code

This structureis analogous to the the [eio](https://github.com/ocaml-multicore/eio#structure-of-the-code) library one.

- sysinfo provides portable types and high level APIs to be consumed
- sysinfo_macos provides a macOS backend
- sysinfo_linux provides a linux backend

There is no auto selection of the backend.
