type t =
  { name : string
  ; status : string
  ; enabled : string
  ; description : string
  ; security_exposure : string
  ; security_predicate : string
  ; security_happy : string
  }
[@@deriving yojson]

type systemd_unit =
  { unit : string
  ; load : string
  ; active : string
  ; sub : string
  ; description : string
  }
[@@deriving yojson]

type systemd_unit_list = systemd_unit list [@@deriving yojson]

type systemd_unit_security =
  { unit : string
  ; exposure : string
  ; predicate : string
  ; happy : string
  }
[@@deriving yojson]

type systemd_unit_security_list = systemd_unit_security list [@@deriving yojson]

let get_systemd_security_analysis () =
  let cmd = {|systemd-analyze security --json=short|} in
  let ic = Unix.open_process_in cmd in
  let sus = Hashtbl.create 200 in
  let rec loop acc =
    match input_line ic with
    | exception End_of_file -> acc
    | line ->
      let su = systemd_unit_security_list_of_yojson (Yojson.Safe.from_string line) in
      (match su with
       | Ok su ->
         List.fold_left
           (fun acc x ->
              Hashtbl.add acc x.unit x;
              acc)
           acc
           su
       | Error msg ->
         let _ = Printf.printf "Error: %s\n" msg in
         loop acc)
  in
  let result = loop sus in
  let _ = Unix.close_process_in ic in
  result
;;

let%expect_test "systemctl-analyzer" =
  let sus = get_systemd_security_analysis () in
  let pp_sus fmt sus =
    Hashtbl.iter (fun k v -> Format.fprintf fmt "%s: %s\n" k v.exposure) sus
  in
  let _ = Format.printf "%a\n" pp_sus sus in
  [%expect {|
    systemd-machined.service: 6.2
    user@1000.service: 9.4
    gnome-remote-desktop-configuration.service: 9.2
    vboxautostart-service.service: 9.6
    plymouth-start.service: 9.5
    uuidd.service: 5.8
    accounts-daemon.service: 5.5
    NetworkManager.service: 7.8
    wpa_supplicant.service: 9.6
    systemd-udevd.service: 7.1
    nix-daemon.service: 9.6
    emergency.service: 9.5
    pcscd.service: 9.6
    switcheroo-control.service: 7.6
    systemd-ask-password-console.service: 9.4
    synergy.service: 9.6
    plymouth-reboot.service: 9.5
    plymouth-poweroff.service: 9.5
    virtlockd.service: 9.6
    sssd.service: 8.3
    systemd-bsod.service: 9.5
    ubuntu-advantage.service: 9.6
    tailscaled.service: 9.6
    virtlogd.service: 2.2
    unattended-upgrades.service: 9.6
    cups-browsed.service: 9.3
    containerd.service: 9.6
    rescue.service: 9.5
    fwupd.service: 7.7
    anacron.service: 9.6
    power-profiles-daemon.service: 1.0
    cron.service: 9.6
    ollama.service: 9.2
    systemd-networkd.service: 2.6
    snap.remmina.ssh-agent.service: 9.6
    docker.service: 9.6
    snapd.service: 9.8
    alsa-state.service: 9.6
    udisks2.service: 9.6
    ModemManager.service: 6.3
    systemd-oomd.service: 1.8
    systemd-rfkill.service: 9.4
    ssh.service: 9.6
    sssd-autofs.service: 9.6
    whoopsie.service: 9.6
    cups.service: 9.6
    systemd-ask-password-plymouth.service: 9.5
    gnome-remote-desktop.service: 9.2
    dbus.service: 9.5
    systemd-logind.service: 2.8
    systemd-resolved.service: 2.2
    systemd-journald.service: 4.9
    systemd-fsckd.service: 9.5
    sssd-nss.service: 9.6
    sssd-pac.service: 9.6
    networkd-dispatcher.service: 9.6
    libvirtd.service: 9.6
    rtkit-daemon.service: 7.2
    systemd-hostnamed.service: 1.7
    plymouth-kexec.service: 9.5
    dmesg.service: 9.6
    dm-event.service: 9.5
    systemd-timesyncd.service: 2.1
    systemd-initctl.service: 9.4
    rc-local.service: 9.6
    rsyslog.service: 6.3
    thermald.service: 9.6
    polkit.service: 1.6
    bluetooth.service: 6.0
    vboxdrv.service: 9.6
    sssd-sudo.service: 9.6
    upower.service: 2.4
    systemd-ask-password-wall.service: 9.4
    gdm.service: 9.8
    tpm-udev.service: 9.6
    getty@tty1.service: 9.6
    avahi-daemon.service: 9.6
    vboxweb-service.service: 9.6
    plymouth-halt.service: 9.5
    cloud-init-main.service: 9.5
    lvm2-lvmpolld.service: 9.5
    sssd-ssh.service: 9.6
    sssd-pam.service: 9.6
    vboxballoonctrl-service.service: 9.6
    nvidia-persistenced.service: 9.6
    colord.service: 3.5
    |}]
;;

let get_systemd_services () =
  let sus = get_systemd_security_analysis () in
  let emptySec = { unit = ""; exposure = ""; predicate = ""; happy = "" } in
  let cmd = {|systemctl list-units --output=json|} in
  let ic = Unix.open_process_in cmd in
  let rec loop acc =
    match input_line ic with
    | exception End_of_file -> acc
    | line ->
      let su = systemd_unit_list_of_yojson (Yojson.Safe.from_string line) in
      (match su with
       | Ok su ->
         List.map
           (fun (s : systemd_unit) ->
              let sec =
                try Hashtbl.find sus s.unit with
                | _ -> emptySec
              in
              Ok
                { name = s.unit
                ; status = s.sub
                ; enabled = s.active
                ; description = s.description
                ; security_exposure = sec.exposure
                ; security_predicate = sec.predicate
                ; security_happy = sec.happy
                })
           su
         @ acc
       | Error msg ->
         let _ = Printf.printf "Error: %s\n" msg in
         loop (Error msg :: acc))
  in
  let result = loop [] in
  let _ = Unix.close_process_in ic in
  result
;;

let get () = get_systemd_services ()
