# Preseed debian

pour installer automatiquement debian:

Copier /preseed.cfg dans la racine 

remplacer /syslinux.cfg dans la racine

# contenu de syslinux.cfg

DEFAULT install
TIMEOUT 10  # Timeout de 1 seconde

LABEL install
  MENU LABEL ^Install with preseed
  KERNEL /install.amd/vmlinuz
  APPEND initrd=/install.amd/initrd.gz auto=true priority=critical preseed/file=/cdrom/preseed.cfg bootdebug=2 quiet


