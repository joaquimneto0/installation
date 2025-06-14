#!/bin/bash

# daloRADIUS - RADIUS Web Platform
# Copyright (C) 2007 - Liran Tal <liran@lirantal.com> All Rights Reserved.
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
#
#
# Authors:        Filippo Lauria <filippo.lauria@iit.cnr.it>
#


# Set default values for variables
ENABLE_COLORS=true
DB_HOST=localhost
DB_PORT=3306
DALORADIUS_USERS_PORT=80
DALORADIUS_OPERATORS_PORT=8000
DALORADIUS_ROOT_DIRECTORY=/var/www/daloradius
DALORADIUS_CONF_FILE="${DALORADIUS_ROOT_DIRECTORY}/app/common/includes/daloradius.conf.php"
DALORADIUS_SERVER_ADMIN=admin@daloradius.local
FREERADIUS_SQL_MOD_PATH="/etc/freeradius/3.0/mods-available/sql"

# Function to print an OK message in green
print_green() {
    echo -e "${GREEN}$1${NC}"
}

# Function to print a KO message in red
print_red() {
    echo -e "${RED}$1${NC}"
}

# Function to print a warning message in yellow
print_yellow() {
    echo -e "${YELLOW}$1${NC}"
}

# Function to print an info message in blue
print_blue() {
    echo -e "${BLUE}$1${NC}"
}

print_spinner() {
    PID=$1
    
    i=1
    sp="/-\|"
    echo -n ' '
    while [ -d /proc/$PID ]; do
        printf "\b${sp:i++%${#sp}:1}"
        sleep 0.1
    done
    printf "\b"
}

mariadb_init_conf() {
    echo -n "[+] Initializing MariaDB configuration... "
    MARIADB_CLIENT_FILENAME="$(mktemp -qu).conf"
    if ! cat << EOF > "${MARIADB_CLIENT_FILENAME}"
[client]
database=${DB_SCHEMA}
host=${DB_HOST}
port=${DB_PORT}
user=${DB_USER}
password=${DB_PASS}
EOF
    then
        print_red "KO"
        echo "[!] Failed to initialize MariaDB configuration. Aborting." >&2
        exit 1
    fi
    print_green "OK"
}


mariadb_clean_conf() {
    echo -n "[+] Cleaning up MariaDB configuration... "
    if [ -e "${MARIADB_CLIENT_FILENAME}" ]; then
        rm -rf "${MARIADB_CLIENT_FILENAME}"
    fi
    print_green "OK"
}

# Function to generate a random string of specified length
generate_random_string() {
    local length="$1"
    cat /dev/random | tr -dc 'A-Za-z0-9' | head -c"$length"
}

# Function to ensure the script is run as root
system_ensure_root() {
  if [ "$(id -u)" -ne 0 ]; then
    if command -v sudo >/dev/null 2>&1; then
      print_red "[!] This script needs to be run as root. Elevating script to root with sudo."
      interpreter="$(head -1 "$0" | cut -c 3-)"
      if [ -x "$interpreter" ]; then
        sudo "$interpreter" "$0" "$@"
      else
        sudo "$0" "$@"
      fi
      exit $?
    else
      print_red "[!] This script needs to be run as root."
      exit 1
    fi
  fi
}

restore_package_list() {
    echo "[+] Restaurando lista de pacotes para ambiente compatível..."
    cat <<EOF | sudo dpkg --set-selections
accountsservice					install
acl						install
adduser						install
adwaita-icon-theme				install
aisleriot					install
alsa-topology-conf				install
alsa-ucm-conf					install
alsa-utils					install
anacron						install
apache2						install
apache2-bin					install
apache2-data					install
apache2-utils					install
apg						install
apparmor					install
appstream					install
apt						install
apt-config-icons				install
apt-listchanges					install
apt-utils					install
aspell						install
aspell-en					install
aspell-pt-br					install
at-spi2-common					install
at-spi2-core					install
avahi-daemon					install
baobab						install
base-files					install
base-passwd					install
bash						install
bash-completion					install
bc						install
bind9-dnsutils					install
bind9-host					install
bind9-libs:amd64				install
binutils					install
binutils-common:amd64				install
binutils-x86-64-linux-gnu			install
bluez						install
bluez-obexd					install
bogofilter					install
bogofilter-bdb					install
bogofilter-common				install
bolt						install
brasero-common					install
bsdextrautils					install
bsdutils					install
bubblewrap					install
build-essential					install
busybox						install
bzip2						install
ca-certificates					install
cdrdao						install
cgroupfs-mount					install
cheese						install
cheese-common					install
chrome-gnome-shell				install
coinor-libcbc3:amd64				install
coinor-libcgl1:amd64				install
coinor-libclp1:amd64				install
coinor-libcoinmp1v5:amd64			install
coinor-libcoinutils3v5:amd64			install
coinor-libosi1v5:amd64				install
colord						install
colord-data					install
console-setup					install
console-setup-linux				install
containerd					install
coreutils					install
cpio						install
cpp						install
cpp-12						install
cracklib-runtime				install
criu						install
cron						install
cron-daemon-common				install
cups						install
cups-browsed					install
cups-client					install
cups-common					install
cups-core-drivers				install
cups-daemon					install
cups-filters					install
cups-filters-core-drivers			install
cups-ipp-utils					install
cups-pk-helper					install
cups-ppdc					install
cups-server-common				install
dash						install
dbus						install
dbus-bin					install
dbus-daemon					install
dbus-session-bus-common				install
dbus-system-bus-common				install
dbus-user-session				install
dconf-cli					install
dconf-gsettings-backend:amd64			install
dconf-service					install
debconf						install
debconf-i18n					install
debian-archive-keyring				install
debian-faq					install
debianutils					install
desktop-base					install
desktop-file-utils				install
dictionaries-common				install
diffutils					install
dirmngr						install
discover					install
discover-data					install
distro-info-data				install
dmidecode					install
dmsetup						install
dns-root-data					install
dnsmasq-base					install
doc-debian					install
docbook-xml					install
dosfstools					install
dpkg						install
dpkg-dev					install
e2fsprogs					install
eject						install
emacsen-common					install
enchant-2					install
eog						install
espeak-ng-data:amd64				install
ethtool						install
evince						install
evince-common					install
evolution					install
evolution-common				install
evolution-data-server				install
evolution-data-server-common			install
evolution-plugin-bogofilter			install
evolution-plugin-pstimport			install
evolution-plugins				install
exfatprogs					install
fakeroot					install
fdisk						install
file						install
file-roller					install
findutils					install
firefox-esr					install
firefox-esr-l10n-pt-br				install
firmware-linux-free				install
five-or-more					install
folks-common					install
fontconfig					install
fontconfig-config				install
fonts-cantarell					install
fonts-dejavu					install
fonts-dejavu-core				install
fonts-dejavu-extra				install
fonts-droid-fallback				install
fonts-liberation2				install
fonts-noto-color-emoji				install
fonts-noto-mono					install
fonts-opensymbol				install
fonts-quicksand					install
fonts-symbola					install
fonts-urw-base35				install
four-in-a-row					install
freeradius					install
freeradius-common				install
freeradius-config				install
freeradius-mysql				install
freeradius-utils				install
freetds-common					install
fuse3						install
fwupd						install
fwupd-amd64-signed				install
g++						install
g++-12						install
galera-4					install
gawk						install
gcc						install
gcc-12						install
gcc-12-base:amd64				install
gcr						install
gdisk						install
gdm3						install
geoclue-2.0					install
geocode-glib-common				install
gettext-base					install
ghostscript					install
gir1.2-accountsservice-1.0:amd64		install
gir1.2-adw-1:amd64				install
gir1.2-atk-1.0:amd64				install
gir1.2-atspi-2.0:amd64				install
gir1.2-clutter-1.0:amd64			install
gir1.2-cogl-1.0:amd64				install
gir1.2-coglpango-1.0:amd64			install
gir1.2-evince-3.0:amd64				install
gir1.2-freedesktop:amd64			install
gir1.2-gck-1:amd64				install
gir1.2-gcr-3:amd64				install
gir1.2-gdesktopenums-3.0:amd64			install
gir1.2-gdkpixbuf-2.0:amd64			install
gir1.2-gdm-1.0					install
gir1.2-geoclue-2.0:amd64			install
gir1.2-geocodeglib-2.0:amd64			install
gir1.2-glib-2.0:amd64				install
gir1.2-gmenu-3.0:amd64				install
gir1.2-gnomebluetooth-3.0:amd64			install
gir1.2-gnomedesktop-3.0:amd64			install
gir1.2-gnomedesktop-4.0:amd64			install
gir1.2-goa-1.0:amd64				install
gir1.2-graphene-1.0:amd64			install
gir1.2-grilo-0.3:amd64				install
gir1.2-gst-plugins-bad-1.0:amd64		install
gir1.2-gst-plugins-base-1.0:amd64		install
gir1.2-gstreamer-1.0:amd64			install
gir1.2-gtk-3.0:amd64				install
gir1.2-gtk-4.0:amd64				install
gir1.2-gtkclutter-1.0:amd64			install
gir1.2-gtksource-4:amd64			install
gir1.2-gweather-4.0:amd64			install
gir1.2-handy-1:amd64				install
gir1.2-harfbuzz-0.0:amd64			install
gir1.2-ibus-1.0:amd64				install
gir1.2-javascriptcoregtk-4.0:amd64		install
gir1.2-javascriptcoregtk-4.1:amd64		install
gir1.2-json-1.0:amd64				install
gir1.2-malcontent-0:amd64			install
gir1.2-mediaart-2.0:amd64			install
gir1.2-mutter-11:amd64				install
gir1.2-nm-1.0:amd64				install
gir1.2-nma-1.0:amd64				install
gir1.2-notify-0.7:amd64				install
gir1.2-packagekitglib-1.0			install
gir1.2-pango-1.0:amd64				install
gir1.2-peas-1.0:amd64				install
gir1.2-polkit-1.0				install
gir1.2-rb-3.0:amd64				install
gir1.2-rest-1.0:amd64				install
gir1.2-rsvg-2.0:amd64				install
gir1.2-secret-1:amd64				install
gir1.2-shumate-1.0:amd64			install
gir1.2-soup-2.4:amd64				install
gir1.2-soup-3.0:amd64				install
gir1.2-totem-1.0:amd64				install
gir1.2-totemplparser-1.0:amd64			install
gir1.2-tracker-3.0:amd64			install
gir1.2-upowerglib-1.0:amd64			install
gir1.2-webkit2-4.0:amd64			install
gir1.2-webkit2-4.1:amd64			install
gir1.2-wnck-3.0:amd64				install
git						install
git-man						install
gjs						install
gkbd-capplet					install
glib-networking:amd64				install
glib-networking-common				install
glib-networking-services			install
gnome						install
gnome-2048					install
gnome-accessibility-themes			install
gnome-backgrounds				install
gnome-bluetooth-3-common			install
gnome-bluetooth-sendto				install
gnome-browser-connector				install
gnome-calculator				install
gnome-calendar					install
gnome-characters				install
gnome-chess					install
gnome-clocks					install
gnome-color-manager				install
gnome-contacts					install
gnome-control-center				install
gnome-control-center-data			install
gnome-core					install
gnome-desktop3-data				install
gnome-disk-utility				install
gnome-font-viewer				install
gnome-games					install
gnome-icon-theme				install
gnome-initial-setup				install
gnome-keyring					install
gnome-keyring-pkcs11:amd64			install
gnome-klotski					install
gnome-logs					install
gnome-mahjongg					install
gnome-maps					install
gnome-menus					install
gnome-mines					install
gnome-music					install
gnome-nibbles					install
gnome-online-accounts				install
gnome-remote-desktop				install
gnome-robots					install
gnome-session					install
gnome-session-bin				install
gnome-session-common				install
gnome-settings-daemon				install
gnome-settings-daemon-common			install
gnome-shell					install
gnome-shell-common				install
gnome-shell-extension-prefs			install
gnome-shell-extensions				install
gnome-software					install
gnome-software-common				install
gnome-sound-recorder				install
gnome-sudoku					install
gnome-sushi					install
gnome-system-monitor				install
gnome-taquin					install
gnome-terminal					install
gnome-terminal-data				install
gnome-tetravex					install
gnome-text-editor				install
gnome-themes-extra:amd64			install
gnome-themes-extra-data				install
gnome-tweaks					install
gnome-user-docs					install
gnome-user-share				install
gnome-video-effects				install
gnome-weather					install
gnupg						install
gnupg-l10n					install
gnupg-utils					install
gpg						install
gpg-agent					install
gpg-wks-client					install
gpg-wks-server					install
gpgconf						install
gpgsm						install
gpgv						install
grep						install
grilo-plugins-0.3:amd64				install
groff-base					install
grub-common					install
grub-pc						install
grub-pc-bin					install
grub2-common					install
gsettings-desktop-schemas			install
gsfonts						install
gstreamer1.0-clutter-3.0:amd64			install
gstreamer1.0-gl:amd64				install
gstreamer1.0-gtk3:amd64				install
gstreamer1.0-libav:amd64			install
gstreamer1.0-packagekit				install
gstreamer1.0-pipewire:amd64			install
gstreamer1.0-plugins-bad:amd64			install
gstreamer1.0-plugins-base:amd64			install
gstreamer1.0-plugins-good:amd64			install
gstreamer1.0-plugins-ugly:amd64			install
gstreamer1.0-x:amd64				install
gtk-update-icon-cache				install
gtk2-engines-pixbuf:amd64			install
guile-3.0-libs:amd64				install
gvfs:amd64					install
gvfs-backends					install
gvfs-common					install
gvfs-daemons					install
gvfs-fuse					install
gvfs-libs:amd64					install
gzip						install
hicolor-icon-theme				install
hitori						install
hoichess					install
hostname					install
hunspell-en-us					install
hunspell-pt-br					install
hyphen-en-us					install
i965-va-driver:amd64				install
iagno						install
ibrazilian					install
ibus						install
ibus-data					install
ibus-gtk:amd64					install
ibus-gtk3:amd64					install
ibus-gtk4:amd64					install
ifupdown					install
iio-sensor-proxy				install
im-config					install
imagemagick-6-common				install
inetutils-telnet				install
init						install
init-system-helpers				install
initramfs-tools					install
initramfs-tools-core				install
installation-report				install
intel-media-va-driver:amd64			install
intel-microcode					install
ipp-usb						install
iproute2					install
iptables					install
iputils-ping					install
isc-dhcp-client					install
isc-dhcp-common					install
iso-codes					install
ispell						install
iucode-tool					install
iw						install
javascript-common				install
jq						install
kbd						install
keyboard-configuration				install
klibc-utils					install
kmod						install
krb5-locales					install
laptop-detect					install
less						install
liba52-0.7.4:amd64				install
libaa1:amd64					install
libaacs0:amd64					install
libabsl20220623:amd64				install
libabw-0.1-1:amd64				install
libaccountsservice0:amd64			install
libacl1:amd64					install
libadwaita-1-0:amd64				install
libalgorithm-diff-perl				install
libalgorithm-diff-xs-perl:amd64			install
libalgorithm-merge-perl				install
libao-common					install
libao4:amd64					install
libaom3:amd64					install
libapache2-mod-dnssd				install
libapache2-mod-php				install
libapache2-mod-php8.2				install
libapparmor1:amd64				install
libappstream4:amd64				install
libapr1:amd64					install
libaprutil1:amd64				install
libaprutil1-dbd-sqlite3:amd64			install
libaprutil1-ldap:amd64				install
libapt-pkg6.0:amd64				install
libarchive13:amd64				install
libargon2-1:amd64				install
libasan8:amd64					install
libasound2:amd64				install
libasound2-data					install
libaspell15:amd64				install
libass9:amd64					install
libassuan0:amd64				install
libasyncns0:amd64				install
libatasmart4:amd64				install
libatk-adaptor:amd64				install
libatk-bridge2.0-0:amd64			install
libatk1.0-0:amd64				install
libatkmm-1.6-1v5:amd64				install
libatomic1:amd64				install
libatopology2:amd64				install
libatspi2.0-0:amd64				install
libattr1:amd64					install
libaudio2:amd64					install
libaudit-common					install
libaudit1:amd64					install
libauthen-sasl-perl				install
libavahi-client3:amd64				install
libavahi-common-data:amd64			install
libavahi-common3:amd64				install
libavahi-core7:amd64				install
libavahi-glib1:amd64				install
libavc1394-0:amd64				install
libavcodec59:amd64				install
libavfilter8:amd64				install
libavformat59:amd64				install
libavif15:amd64					install
libavutil57:amd64				install
libayatana-appindicator3-1			install
libayatana-ido3-0.4-0:amd64			install
libayatana-indicator3-7:amd64			install
libbdplus0:amd64				install
libbinutils:amd64				install
libblas3:amd64					install
libblkid1:amd64					install
libblockdev-crypto2:amd64			install
libblockdev-fs2:amd64				install
libblockdev-loop2:amd64				install
libblockdev-part-err2:amd64			install
libblockdev-part2:amd64				install
libblockdev-swap2:amd64				install
libblockdev-utils2:amd64			install
libblockdev2:amd64				install
libbluetooth3:amd64				install
libbluray2:amd64				install
libboost-filesystem1.74.0:amd64			install
libboost-iostreams1.74.0:amd64			install
libboost-locale1.74.0:amd64			install
libboost-thread1.74.0:amd64			install
libbox2d2:amd64					install
libbpf1:amd64					install
libbrasero-media3-1:amd64			install
libbrlapi0.8:amd64				install
libbrotli1:amd64				install
libbs2b0:amd64					install
libbsd0:amd64					install
libburn4:amd64					install
libbz2-1.0:amd64				install
libc-bin					install
libc-dev-bin					install
libc-devtools					install
libc-l10n					install
libc6:amd64					install
libc6-dev:amd64					install
libcaca0:amd64					install
libcairo-gobject-perl				install
libcairo-gobject2:amd64				install
libcairo-perl					install
libcairo-script-interpreter2:amd64		install
libcairo2:amd64					install
libcairomm-1.0-1v5:amd64			install
libcamel-1.2-64:amd64				install
libcanberra-gtk3-0:amd64			install
libcanberra-gtk3-module:amd64			install
libcanberra-pulse:amd64				install
libcanberra0:amd64				install
libcap-ng0:amd64				install
libcap2:amd64					install
libcap2-bin					install
libcbor0.8:amd64				install
libcc1-0:amd64					install
libcdio-cdda2:amd64				install
libcdio-paranoia2:amd64				install
libcdio19:amd64					install
libcdparanoia0:amd64				install
libcdr-0.1-1:amd64				install
libcheese-gtk25:amd64				install
libcheese8:amd64				install
libchromaprint1:amd64				install
libcjson1:amd64					install
libclone-perl:amd64				install
libcloudproviders0:amd64			install
libclucene-contribs1v5:amd64			install
libclucene-core1v5:amd64			install
libclutter-1.0-0:amd64				install
libclutter-1.0-common				install
libclutter-gst-3.0-0:amd64			install
libclutter-gtk-1.0-0:amd64			install
libcmark0.30.2:amd64				install
libcodec2-1.0:amd64				install
libcogl-common					install
libcogl-pango20:amd64				install
libcogl-path20:amd64				install
libcogl20:amd64					install
libcolamd2:amd64				install
libcolord-gtk4-1:amd64				install
libcolord2:amd64				install
libcolorhug2:amd64				install
libcom-err2:amd64				install
libcommon-sense-perl:amd64			install
libconfig-inifiles-perl				install
libcrack2:amd64					install
libcrypt-dev:amd64				install
libcrypt1:amd64					install
libcryptsetup12:amd64				install
libct4:amd64					install
libctf-nobfd0:amd64				install
libctf0:amd64					install
libcue2:amd64					install
libcups2:amd64					install
libcupsfilters1:amd64				install
libcurl3-gnutls:amd64				install
libcurl4:amd64					install
libdaemon0:amd64				install
libdata-dump-perl				install
libdatrie1:amd64				install
libdav1d6:amd64					install
libdb5.3:amd64					install
libdbi-perl:amd64				install
libdbus-1-3:amd64				install
libdbusmenu-glib4:amd64				install
libdbusmenu-gtk3-4:amd64			install
libdc1394-25:amd64				install
libdca0:amd64					install
libdconf1:amd64					install
libde265-0:amd64				install
libdebconfclient0:amd64				install
libdecor-0-0:amd64				install
libdecor-0-plugin-1-cairo:amd64			install
libdee-1.0-4:amd64				install
libdeflate0:amd64				install
libdevmapper1.02.1:amd64			install
libdirectfb-1.7-7:amd64				install
libdiscover2					install
libdjvulibre-text				install
libdjvulibre21:amd64				install
libdmapsharing-3.0-2:amd64			install
libdotconf0:amd64				install
libdpkg-perl					install
libdrm-amdgpu1:amd64				install
libdrm-common					install
libdrm-intel1:amd64				install
libdrm-nouveau2:amd64				install
libdrm-radeon1:amd64				install
libdrm2:amd64					install
libduktape207:amd64				install
libdv4:amd64					install
libdvdnav4:amd64				install
libdvdread8:amd64				install
libdw1:amd64					install
libe-book-0.1-1:amd64				install
libebackend-1.2-11:amd64			install
libebook-1.2-21:amd64				install
libebook-contacts-1.2-4:amd64			install
libecal-2.0-2:amd64				install
libedata-book-1.2-27:amd64			install
libedata-cal-2.0-2:amd64			install
libedataserver-1.2-27:amd64			install
libedataserverui-1.2-4:amd64			install
libedataserverui4-1.0-0:amd64			install
libedit2:amd64					install
libeditorconfig0:amd64				install
libefiboot1:amd64				install
libefivar1:amd64				install
libegl-mesa0:amd64				install
libegl1:amd64					install
libelf1:amd64					install
libenchant-2-2:amd64				install
libencode-locale-perl				install
libeot0:amd64					install
libepoxy0:amd64					install
libept1.6.0:amd64				install
libepubgen-0.1-1:amd64				install
liberror-perl					install
libespeak-ng1:amd64				install
libestr0:amd64					install
libetonyek-0.1-1:amd64				install
libevdev2:amd64					install
libevdocument3-4:amd64				install
libevent-2.1-7:amd64				install
libevolution					install
libevview3-3:amd64				install
libexempi8:amd64				install
libexif12:amd64					install
libexiv2-27:amd64				install
libexpat1:amd64					install
libexpat1-dev:amd64				install
libext2fs2:amd64				install
libexttextcat-2.0-0:amd64			install
libexttextcat-data				install
libextutils-depends-perl			install
libfaad2:amd64					install
libfakeroot:amd64				install
libfastjson4:amd64				install
libfdisk1:amd64					install
libffi8:amd64					install
libfftw3-double3:amd64				install
libfftw3-single3:amd64				install
libfido2-1:amd64				install
libfile-basedir-perl				install
libfile-desktopentry-perl			install
libfile-fcntllock-perl				install
libfile-listing-perl				install
libfile-mimeinfo-perl				install
libflac12:amd64					install
libflashrom1:amd64				install
libflatpak0:amd64				install
libflite1:amd64					install
libfluidsynth3:amd64				install
libfolks-eds26:amd64				install
libfolks26:amd64				install
libfont-afm-perl				install
libfontconfig1:amd64				install
libfontembed1:amd64				install
libfontenc1:amd64				install
libfreeaptx0:amd64				install
libfreehand-0.1-1				install
libfreeradius3					install
libfreerdp-server2-2:amd64			install
libfreerdp2-2:amd64				install
libfreetype6:amd64				install
libfribidi0:amd64				install
libfstrm0:amd64					install
libftdi1-2:amd64				install
libfuse2:amd64					install
libfuse3-3:amd64				install
libfwupd2:amd64					install
libgail-3-0:amd64				install
libgail-common:amd64				install
libgail18:amd64					install
libgav1-1:amd64					install
libgbm1:amd64					install
libgc1:amd64					install
libgcab-1.0-0:amd64				install
libgcc-12-dev:amd64				install
libgcc-s1:amd64					install
libgck-1-0:amd64				install
libgcr-base-3-1:amd64				install
libgcr-ui-3-1:amd64				install
libgcrypt20:amd64				install
libgd3:amd64					install
libgdata-common					install
libgdata22:amd64				install
libgdbm-compat4:amd64				install
libgdbm6:amd64					install
libgdk-pixbuf-2.0-0:amd64			install
libgdk-pixbuf2.0-bin				install
libgdk-pixbuf2.0-common				install
libgdm1						install
libgee-0.8-2:amd64				install
libgeoclue-2-0:amd64				install
libgeocode-glib-2-0:amd64			install
libges-1.0-0					install
libgexiv2-2:amd64				install
libgfortran5:amd64				install
libgif7:amd64					install
libgirepository-1.0-1:amd64			install
libgjs0g:amd64					install
libgl1:amd64					install
libgl1-mesa-dri:amd64				install
libglapi-mesa:amd64				install
libgles2:amd64					install
libglib-object-introspection-perl		install
libglib-perl:amd64				install
libglib2.0-0:amd64				install
libglib2.0-bin					install
libglib2.0-data					install
libglibmm-2.4-1v5:amd64				install
libglu1-mesa:amd64				install
libglvnd0:amd64					install
libglx-mesa0:amd64				install
libglx0:amd64					install
libgme0:amd64					install
libgmp10:amd64					install
libgnome-autoar-0-0:amd64			install
libgnome-autoar-gtk-0-0:amd64			install
libgnome-bg-4-2:amd64				install
libgnome-bluetooth-3.0-13:amd64			install
libgnome-bluetooth-ui-3.0-13:amd64		install
libgnome-desktop-3-20:amd64			install
libgnome-desktop-4-2:amd64			install
libgnome-games-support-1-3:amd64		install
libgnome-games-support-common			install
libgnome-menu-3-0:amd64				install
libgnome-rr-4-2:amd64				install
libgnomekbd-common				install
libgnomekbd8:amd64				install
libgnutls30:amd64				install
libgoa-1.0-0b:amd64				install
libgoa-1.0-common				install
libgoa-backend-1.0-1:amd64			install
libgom-1.0-0:amd64				install
libgomp1:amd64					install
libgpg-error0:amd64				install
libgpgme11:amd64				install
libgpgmepp6:amd64				install
libgphoto2-6:amd64				install
libgphoto2-l10n					install
libgphoto2-port12:amd64				install
libgpm2:amd64					install
libgpod-common					install
libgpod4:amd64					install
libgprofng0:amd64				install
libgraphene-1.0-0:amd64				install
libgraphite2-3:amd64				install
libgrilo-0.3-0:amd64				install
libgs-common					install
libgs10:amd64					install
libgs10-common					install
libgsf-1-114:amd64				install
libgsf-1-common					install
libgsf-bin					install
libgsl27:amd64					install
libgslcblas0:amd64				install
libgsm1:amd64					install
libgsound0:amd64				install
libgspell-1-2:amd64				install
libgspell-1-common				install
libgssapi-krb5-2:amd64				install
libgssdp-1.6-0:amd64				install
libgstreamer-gl1.0-0:amd64			install
libgstreamer-plugins-bad1.0-0:amd64		install
libgstreamer-plugins-base1.0-0:amd64		install
libgstreamer1.0-0:amd64				install
libgtk-3-0:amd64				install
libgtk-3-bin					install
libgtk-3-common					install
libgtk-4-1:amd64				install
libgtk-4-bin					install
libgtk-4-common					install
libgtk2.0-0:amd64				install
libgtk2.0-bin					install
libgtk2.0-common				install
libgtk3-perl					install
libgtkmm-3.0-1v5:amd64				install
libgtksourceview-4-0:amd64			install
libgtksourceview-4-common			install
libgtksourceview-5-0:amd64			install
libgtksourceview-5-common			install
libgtop-2.0-11:amd64				install
libgtop2-common					install
libgudev-1.0-0:amd64				install
libgupnp-1.6-0:amd64				install
libgupnp-av-1.0-3				install
libgupnp-dlna-2.0-4				install
libgupnp-igd-1.0-4:amd64			install
libgusb2:amd64					install
libgweather-4-0:amd64				install
libgweather-4-common				install
libgxps2:amd64					install
libhandy-1-0:amd64				install
libharfbuzz-icu0:amd64				install
libharfbuzz0b:amd64				install
libheif1:amd64					install
libhogweed6:amd64				install
libhtml-form-perl				install
libhtml-format-perl				install
libhtml-parser-perl:amd64			install
libhtml-tagset-perl				install
libhtml-tree-perl				install
libhttp-cookies-perl				install
libhttp-daemon-perl				install
libhttp-date-perl				install
libhttp-message-perl				install
libhttp-negotiate-perl				install
libhunspell-1.7-0:amd64				install
libhwy1:amd64					install
libhyphen0:amd64				install
libibus-1.0-5:amd64				install
libical3:amd64					install
libice6:amd64					install
libicu72:amd64					install
libidn12:amd64					install
libidn2-0:amd64					install
libiec61883-0:amd64				install
libieee1284-3:amd64				install
libigdgmm12:amd64				install
libijs-0.35:amd64				install
libimath-3-1-29:amd64				install
libimobiledevice6:amd64				install
libinput-bin					install
libinput10:amd64				install
libinstpatch-1.0-2:amd64			install
libintl-perl					install
libintl-xs-perl					install
libio-html-perl					install
libio-socket-ssl-perl				install
libio-stringy-perl				install
libip4tc2:amd64					install
libip6tc2:amd64					install
libipc-system-simple-perl			install
libiptcdata0					install
libisl23:amd64					install
libisofs6:amd64					install
libitm1:amd64					install
libjack-jackd2-0:amd64				install
libjansson4:amd64				install
libjavascriptcoregtk-4.0-18:amd64		install
libjavascriptcoregtk-4.1-0:amd64		install
libjavascriptcoregtk-6.0-1:amd64		install
libjaylink0:amd64				install
libjbig0:amd64					install
libjbig2dec0:amd64				install
libjcat1:amd64					install
libjemalloc2:amd64				install
libjim0.81:amd64				install
libjpeg62-turbo:amd64				install
libjq1:amd64					install
libjs-jquery					install
libjs-sphinxdoc					install
libjs-underscore				install
libjson-c5:amd64				install
libjson-glib-1.0-0:amd64			install
libjson-glib-1.0-common				install
libjson-perl					install
libjson-xs-perl					install
libjte2:amd64					install
libjxl0.7:amd64					install
libjxr-tools					install
libjxr0:amd64					install
libk5crypto3:amd64				install
libkate1:amd64					install
libkeyutils1:amd64				install
libklibc:amd64					install
libkmod2:amd64					install
libkpathsea6:amd64				install
libkrb5-3:amd64					install
libkrb5support0:amd64				install
libksba8:amd64					install
liblangtag-common				install
liblangtag1:amd64				install
liblapack3:amd64				install
liblc3-0:amd64					install
liblcms2-2:amd64				install
libldacbt-abr2:amd64				install
libldacbt-enc2:amd64				install
libldap-2.5-0:amd64				install
libldap-common					install
libldb2:amd64					install
liblerc4:amd64					install
liblilv-0-0:amd64				install
liblirc-client0:amd64				install
libllvm14:amd64					install
libllvm15:amd64					install
liblmdb0:amd64					install
liblocale-gettext-perl				install
liblockfile-bin					install
liblognorm5:amd64				install
liblouis-data					install
liblouis20:amd64				install
liblouisutdml-bin				install
liblouisutdml-data				install
liblouisutdml9:amd64				install
liblqr-1-0:amd64				install
liblrdf0:amd64					install
liblsan0:amd64					install
libltc11:amd64					install
libltdl7:amd64					install
liblua5.3-0:amd64				install
liblwp-mediatypes-perl				install
liblwp-protocol-https-perl			install
liblz4-1:amd64					install
liblzma5:amd64					install
liblzo2-2:amd64					install
libmagic-mgc					install
libmagic1:amd64					install
libmagickcore-6.q16-6:amd64			install
libmagickcore-6.q16-6-extra:amd64		install
libmagickwand-6.q16-6:amd64			install
libmailtools-perl				install
libmalcontent-0-0:amd64				install
libmalcontent-ui-1-1:amd64			install
libmanette-0.2-0:amd64				install
libmariadb3:amd64				install
libmaxminddb0:amd64				install
libmbedcrypto7:amd64				install
libmbim-glib4:amd64				install
libmbim-proxy					install
libmbim-utils					install
libmd0:amd64					install
libmediaart-2.0-0:amd64				install
libmfx1:amd64					install
libmhash2:amd64					install
libminiupnpc17:amd64				install
libmjpegutils-2.1-0:amd64			install
libmm-glib0:amd64				install
libmnl0:amd64					install
libmodplug1:amd64				install
libmodule-find-perl				install
libmount1:amd64					install
libmozjs-102-0:amd64				install
libmp3lame0:amd64				install
libmpc3:amd64					install
libmpcdec6:amd64				install
libmpeg2-4:amd64				install
libmpeg2encpp-2.1-0:amd64			install
libmpfr6:amd64					install
libmpg123-0:amd64				install
libmplex2-2.1-0:amd64				install
libmspack0:amd64				install
libmspub-0.1-1:amd64				install
libmtdev1:amd64					install
libmtp-common					install
libmtp-runtime					install
libmtp9:amd64					install
libmutter-11-0:amd64				install
libmwaw-0.3-3:amd64				install
libmysofa1:amd64				install
libmythes-1.2-0:amd64				install
libnatpmp1:amd64				install
libnautilus-extension4:amd64			install
libncurses6:amd64				install
libncursesw6:amd64				install
libndp0:amd64					install
libneon27:amd64					install
libnet-dbus-perl				install
libnet-http-perl				install
libnet-smtp-ssl-perl				install
libnet-ssleay-perl:amd64			install
libnet1:amd64					install
libnetfilter-conntrack3:amd64			install
libnettle8:amd64				install
libnewt0.52:amd64				install
libnfnetlink0:amd64				install
libnfs13:amd64					install
libnftables1:amd64				install
libnftnl11:amd64				install
libnghttp2-14:amd64				install
libnice10:amd64					install
libnl-3-200:amd64				install
libnl-genl-3-200:amd64				install
libnl-route-3-200:amd64				install
libnm0:amd64					install
libnma-common					install
libnma-gtk4-0:amd64				install
libnma0:amd64					install
libnorm1:amd64					install
libnotify4:amd64				install
libnpth0:amd64					install
libnsl-dev:amd64				install
libnsl2:amd64					install
libnspr4:amd64					install
libnss-mdns:amd64				install
libnss-myhostname:amd64				install
libnss-systemd:amd64				install
libnss3:amd64					install
libntfs-3g89:amd64				install
libnuma1:amd64					install
libnumbertext-1.0-0:amd64			install
libnumbertext-data				install
liboauth0:amd64					install
libodfgen-0.1-1:amd64				install
libogg0:amd64					install
libonig5:amd64					install
libopenal-data					install
libopenal1:amd64				install
libopencore-amrnb0:amd64			install
libopencore-amrwb0:amd64			install
libopenexr-3-1-30:amd64				install
libopengl0:amd64				install
libopenh264-7:amd64				install
libopenjp2-7:amd64				install
libopenmpt0:amd64				install
libopenni2-0:amd64				install
libopus0:amd64					install
liborc-0.4-0:amd64				install
liborcus-0.17-0:amd64				install
liborcus-parser-0.17-0:amd64			install
libosinfo-1.0-0:amd64				install
libosinfo-l10n					install
libostree-1-1:amd64				install
libp11-kit0:amd64				install
libpackagekit-glib2-18:amd64			install
libpagemaker-0.0-0:amd64			install
libpam-gnome-keyring:amd64			install
libpam-modules:amd64				install
libpam-modules-bin				install
libpam-runtime					install
libpam-systemd:amd64				install
libpam0g:amd64					install
libpango-1.0-0:amd64				install
libpangocairo-1.0-0:amd64			install
libpangoft2-1.0-0:amd64				install
libpangomm-1.4-1v5:amd64			install
libpangoxft-1.0-0:amd64				install
libpaper-utils					install
libpaper1:amd64					install
libparted-fs-resize0:amd64			install
libparted2:amd64				install
libpcap0.8:amd64				install
libpcaudio0:amd64				install
libpci3:amd64					install
libpciaccess0:amd64				install
libpcre2-8-0:amd64				install
libpcre3:amd64					install
libpcsclite1:amd64				install
libpeas-1.0-0:amd64				install
libpeas-common					install
libperl4-corelibs-perl				install
libperl5.36:amd64				install
libpgm-5.3-0:amd64				install
libphonenumber8:amd64				install
libpipeline1:amd64				install
libpipewire-0.3-0:amd64				install
libpipewire-0.3-common				install
libpipewire-0.3-modules:amd64			install
libpixman-1-0:amd64				install
libplacebo208:amd64				install
libplist3:amd64					install
libplymouth5:amd64				install
libpng16-16:amd64				install
libpocketsphinx3:amd64				install
libpolkit-agent-1-0:amd64			install
libpolkit-gobject-1-0:amd64			install
libpoppler-cpp0v5:amd64				install
libpoppler-glib8:amd64				install
libpoppler126:amd64				install
libpopt0:amd64					install
libportal-gtk3-1:amd64				install
libportal-gtk4-1:amd64				install
libportal1:amd64				install
libpostproc56:amd64				install
libpq5:amd64					install
libproc-processtable-perl:amd64			install
libproc2-0:amd64				install
libprotobuf-c1:amd64				install
libprotobuf32:amd64				install
libproxy1-plugin-gsettings:amd64		install
libproxy1-plugin-networkmanager:amd64		install
libproxy1-plugin-webkit:amd64			install
libproxy1v5:amd64				install
libpsl5:amd64					install
libpst4:amd64					install
libpulse-mainloop-glib0:amd64			install
libpulse0:amd64					install
libpwquality-common				install
libpwquality1:amd64				install
libpython3-dev:amd64				install
libpython3-stdlib:amd64				install
libpython3.11:amd64				install
libpython3.11-dev:amd64				install
libpython3.11-minimal:amd64			install
libpython3.11-stdlib:amd64			install
libqmi-glib5:amd64				install
libqmi-proxy					install
libqmi-utils					install
libqpdf29:amd64					install
libqqwing2v5:amd64				install
libqrencode4:amd64				install
libqrtr-glib0:amd64				install
libquadmath0:amd64				install
libqxp-0.0-0					install
librabbitmq4:amd64				install
libraptor2-0:amd64				install
librasqal3:amd64				install
librav1e0:amd64					install
libraw1394-11:amd64				install
libraw20:amd64					install
librdf0:amd64					install
libreadline8:amd64				install
libregexp-ipv6-perl				install
libreoffice-base-core				install
libreoffice-calc				install
libreoffice-common				install
libreoffice-core				install
libreoffice-draw				install
libreoffice-gnome				install
libreoffice-gtk3				install
libreoffice-help-common				install
libreoffice-help-en-us				install
libreoffice-impress				install
libreoffice-l10n-pt-br				install
libreoffice-math				install
libreoffice-style-colibre			install
libreoffice-style-elementary			install
libreoffice-writer				install
librest-1.0-0:amd64				install
librevenge-0.0-0:amd64				install
librhythmbox-core10:amd64			install
librist4:amd64					install
librsvg2-2:amd64				install
librsvg2-common:amd64				install
librtmp1:amd64					install
librubberband2:amd64				install
librygel-core-2.8-0:amd64			install
librygel-db-2.8-0:amd64				install
librygel-renderer-2.8-0:amd64			install
librygel-renderer-gst-2.8-0:amd64		install
librygel-server-2.8-0:amd64			install
libsamplerate0:amd64				install
libsane-common					install
libsane1:amd64					install
libsasl2-2:amd64				install
libsasl2-modules:amd64				install
libsasl2-modules-db:amd64			install
libsbc1:amd64					install
libsdl2-2.0-0:amd64				install
libseccomp2:amd64				install
libsecret-1-0:amd64				install
libsecret-common				install
libselinux1:amd64				install
libsemanage-common				install
libsemanage2:amd64				install
libsensors-config				install
libsensors5:amd64				install
libsepol2:amd64					install
libserd-0-0:amd64				install
libsgutils2-1.46-2:amd64			install
libshine3:amd64					install
libshout3:amd64					install
libshumate-1.0-1:amd64				install
libshumate-common				install
libsidplay1v5:amd64				install
libsigc++-2.0-0v5:amd64				install
libsigsegv2:amd64				install
libslang2:amd64					install
libsm6:amd64					install
libsmartcols1:amd64				install
libsmbclient:amd64				install
libsmbios-c2					install
libsnapd-glib-2-1:amd64				install
libsnappy1v5:amd64				install
libsndfile1:amd64				install
libsndio7.0:amd64				install
libsnmp-base					install
libsnmp40:amd64					install
libsodium23:amd64				install
libsonic0:amd64					install
libsord-0-0:amd64				install
libsort-naturally-perl				install
libsoundtouch1:amd64				install
libsoup-3.0-0:amd64				install
libsoup-3.0-common				install
libsoup-gnome2.4-1:amd64			install
libsoup2.4-1:amd64				install
libsoup2.4-common				install
libsoxr0:amd64					install
libspa-0.2-bluetooth:amd64			install
libspa-0.2-modules:amd64			install
libspandsp2:amd64				install
libspectre1:amd64				install
libspeechd2:amd64				install
libspeex1:amd64					install
libsphinxbase3:amd64				install
libsqlite3-0:amd64				install
libsratom-0-0:amd64				install
libsrt1.5-gnutls:amd64				install
libsrtp2-1:amd64				install
libss2:amd64					install
libssh-gcrypt-4:amd64				install
libssh2-1:amd64					install
libssl3:amd64					install
libstaroffice-0.0-0:amd64			install
libstartup-notification0:amd64			install
libstdc++-12-dev:amd64				install
libstdc++6:amd64				install
libstemmer0d:amd64				install
libsuitesparseconfig5:amd64			install
libsvtav1enc1:amd64				install
libswresample4:amd64				install
libswscale6:amd64				install
libsynctex2:amd64				install
libsystemd-shared:amd64				install
libsystemd0:amd64				install
libtag1v5:amd64					install
libtag1v5-vanilla:amd64				install
libtalloc2:amd64				install
libtasn1-6:amd64				install
libtdb1:amd64					install
libteamdctl0:amd64				install
libterm-readkey-perl				install
libtevent0:amd64				install
libtext-charwidth-perl:amd64			install
libtext-iconv-perl:amd64			install
libtext-wrapi18n-perl				install
libthai-data					install
libthai0:amd64					install
libtheora0:amd64				install
libtie-ixhash-perl				install
libtiff6:amd64					install
libtimedate-perl				install
libtinfo6:amd64					install
libtirpc-common					install
libtirpc-dev:amd64				install
libtirpc3:amd64					install
libtotem-plparser-common			install
libtotem-plparser18:amd64			install
libtotem0:amd64					install
libtracker-sparql-3.0-0:amd64			install
libtry-tiny-perl				install
libtsan2:amd64					install
libtss2-esys-3.0.2-0:amd64			install
libtss2-mu0:amd64				install
libtss2-rc0:amd64				install
libtss2-sys1:amd64				install
libtss2-tcti-cmd0:amd64				install
libtss2-tcti-device0:amd64			install
libtss2-tcti-mssim0:amd64			install
libtss2-tcti-swtpm0:amd64			install
libtss2-tctildr0:amd64				install
libtwolame0:amd64				install
libtypes-serialiser-perl			install
libubsan1:amd64					install
libuchardet0:amd64				install
libudev1:amd64					install
libudfread0:amd64				install
libudisks2-0:amd64				install
libunistring2:amd64				install
libunity-protocol-private0:amd64		install
libunity-scopes-json-def-desktop		install
libunity9:amd64					install
libuno-cppu3					install
libuno-cppuhelpergcc3-3				install
libuno-purpenvhelpergcc3-3			install
libuno-sal3					install
libuno-salhelpergcc3-3				install
libunwind8:amd64				install
libupower-glib3:amd64				install
liburi-perl					install
liburing2:amd64					install
libusb-1.0-0:amd64				install
libusbmuxd6:amd64				install
libuuid1:amd64					install
libuv1:amd64					install
libv4l-0:amd64					install
libv4lconvert0:amd64				install
libva-drm2:amd64				install
libva-x11-2:amd64				install
libva2:amd64					install
libvdpau-va-gl1:amd64				install
libvdpau1:amd64					install
libvidstab1.1:amd64				install
libvisio-0.1-1:amd64				install
libvisual-0.4-0:amd64				install
libvo-aacenc0:amd64				install
libvo-amrwbenc0:amd64				install
libvolume-key1:amd64				install
libvorbis0a:amd64				install
libvorbisenc2:amd64				install
libvorbisfile3:amd64				install
libvpx7:amd64					install
libvte-2.91-0:amd64				install
libvte-2.91-common				install
libvulkan1:amd64				install
libwacom-common					install
libwacom9:amd64					install
libwavpack1:amd64				install
libwayland-client0:amd64			install
libwayland-cursor0:amd64			install
libwayland-egl1:amd64				install
libwayland-server0:amd64			install
libwbclient0:amd64				install
libwebkit2gtk-4.0-37:amd64			install
libwebkit2gtk-4.1-0:amd64			install
libwebkitgtk-6.0-4:amd64			install
libwebp7:amd64					install
libwebpdemux2:amd64				install
libwebpmux3:amd64				install
libwebrtc-audio-processing1:amd64		install
libwildmidi2:amd64				install
libwinpr2-2:amd64				install
libwireplumber-0.4-0:amd64			install
libwmflite-0.2-7:amd64				install
libwnck-3-0:amd64				install
libwnck-3-common				install
libwoff1:amd64					install
libwpd-0.10-10:amd64				install
libwpg-0.3-3:amd64				install
libwps-0.4-4:amd64				install
libwrap0:amd64					install
libwww-perl					install
libwww-robotrules-perl				install
libx11-6:amd64					install
libx11-data					install
libx11-protocol-perl				install
libx11-xcb1:amd64				install
libx264-164:amd64				install
libx265-199:amd64				install
libxapian30:amd64				install
libxatracker2:amd64				install
libxau6:amd64					install
libxaw7:amd64					install
libxcb-damage0:amd64				install
libxcb-dri2-0:amd64				install
libxcb-dri3-0:amd64				install
libxcb-glx0:amd64				install
libxcb-icccm4:amd64				install
libxcb-image0:amd64				install
libxcb-keysyms1:amd64				install
libxcb-present0:amd64				install
libxcb-randr0:amd64				install
libxcb-render-util0:amd64			install
libxcb-render0:amd64				install
libxcb-res0:amd64				install
libxcb-shape0:amd64				install
libxcb-shm0:amd64				install
libxcb-sync1:amd64				install
libxcb-util1:amd64				install
libxcb-xfixes0:amd64				install
libxcb-xkb1:amd64				install
libxcb-xv0:amd64				install
libxcb1:amd64					install
libxcomposite1:amd64				install
libxcursor1:amd64				install
libxcvt0:amd64					install
libxdamage1:amd64				install
libxdmcp6:amd64					install
libxext6:amd64					install
libxfixes3:amd64				install
libxfont2:amd64					install
libxft2:amd64					install
libxi6:amd64					install
libxinerama1:amd64				install
libxkbcommon-x11-0:amd64			install
libxkbcommon0:amd64				install
libxkbfile1:amd64				install
libxkbregistry0:amd64				install
libxklavier16:amd64				install
libxml-parser-perl				install
libxml-twig-perl				install
libxml-xpathengine-perl				install
libxml2:amd64					install
libxmlb2:amd64					install
libxmlsec1:amd64				install
libxmlsec1-nss:amd64				install
libxmlsec1-openssl:amd64			install
libxmu6:amd64					install
libxmuu1:amd64					install
libxpm4:amd64					install
libxrandr2:amd64				install
libxrender1:amd64				install
libxres1:amd64					install
libxshmfence1:amd64				install
libxslt1.1:amd64				install
libxss1:amd64					install
libxt6:amd64					install
libxtables12:amd64				install
libxtst6:amd64					install
libxv1:amd64					install
libxvidcore4:amd64				install
libxvmc1:amd64					install
libxxf86dga1:amd64				install
libxxf86vm1:amd64				install
libxxhash0:amd64				install
libyajl2:amd64					install
libyaml-0-2:amd64				install
libyelp0:amd64					install
libytnef0:amd64					install
libyuv0:amd64					install
libz3-4:amd64					install
libzbar0:amd64					install
libzimg2:amd64					install
libzip4:amd64					install
libzmf-0.0-0:amd64				install
libzmq5:amd64					install
libzstd1:amd64					install
libzvbi-common					install
libzvbi0:amd64					install
libzxing2:amd64					install
lightsoff					install
linux-base					install
linux-image-6.1.0-10-amd64			install
linux-image-6.1.0-37-amd64			install
linux-image-amd64				install
linux-libc-dev:amd64				install
locales						install
login						install
logrotate					install
logsave						install
low-memory-monitor				install
lp-solve					install
lsb-release					install
lsof						install
lynx						install
lynx-common					install
mailcap						install
make						install
malcontent					install
malcontent-gui					install
man-db						install
manpages					install
manpages-dev					install
manpages-pt-br					install
mariadb-client					install
mariadb-client-core				install
mariadb-common					install
mariadb-server					install
mariadb-server-core				install
mawk						install
media-player-info				install
media-types					install
mesa-va-drivers:amd64				install
mesa-vdpau-drivers:amd64			install
mesa-vulkan-drivers:amd64			install
mime-support					install
mobile-broadband-provider-info			install
modemmanager					install
mount						install
mutter-common					install
mysql-common					install
mythes-en-us					install
nano						install
nautilus					install
nautilus-data					install
nautilus-extension-gnome-terminal:amd64		install
ncurses-base					install
ncurses-bin					install
ncurses-term					install
needrestart					install
netbase						install
netcat-traditional				install
network-manager					install
network-manager-gnome				install
nftables					install
node-clipboard					install
node-normalize.css				install
node-prismjs					install
ntfs-3g						install
ocl-icd-libopencl1:amd64			install
open-vm-tools					install
open-vm-tools-desktop				install
openssh-client					install
openssh-server					install
openssh-sftp-server				install
openssl						install
orca						install
os-prober					install
osinfo-db					install
p11-kit						install
p11-kit-modules:amd64				install
p7zip						install
p7zip-full					install
packagekit					install
packagekit-tools				install
parted						install
passwd						install
patch						install
pci.ids						install
pciutils					install
perl						install
perl-base					install
perl-modules-5.36				install
perl-openssl-defaults:amd64			install
perl-tk						install
php						install
php-common					install
php-curl					install
php-db						install
php-gd						install
php-mail					install
php-mail-mime					install
php-mbstring					install
php-mysql					install
php-pear					install
php-xml						install
php-zip						install
php8.2						install
php8.2-cli					install
php8.2-common					install
php8.2-curl					install
php8.2-gd					install
php8.2-mbstring					install
php8.2-mysql					install
php8.2-opcache					install
php8.2-readline					install
php8.2-xml					install
php8.2-zip					install
pinentry-curses					install
pinentry-gnome3					install
pipewire:amd64					install
pipewire-alsa:amd64				install
pipewire-audio					install
pipewire-bin					install
pipewire-pulse					install
pkexec						install
plymouth					install
plymouth-label					install
pocketsphinx-en-us				install
polkitd						install
poppler-data					install
poppler-utils					install
postgresql-15					install
postgresql-client-15				install
postgresql-client-common			install
postgresql-common				install
power-profiles-daemon				install
ppp						install
procps						install
psmisc						install
publicsuffix					install
python-apt-common				install
python3						install
python3-apt					install
python3-blinker					install
python3-brlapi:amd64				install
python3-cairo:amd64				install
python3-certifi					install
python3-cffi-backend:amd64			install
python3-chardet					install
python3-charset-normalizer			install
python3-cryptography				install
python3-cups:amd64				install
python3-cupshelpers				install
python3-dateutil				install
python3-dbus					install
python3-debconf					install
python3-debian					install
python3-debianbts				install
python3-dev					install
python3-distro					install
python3-distro-info				install
python3-distutils				install
python3-gi					install
python3-gi-cairo				install
python3-httplib2				install
python3-ibus-1.0				install
python3-idna					install
python3-jwt					install
python3-lazr.restfulclient			install
python3-lazr.uri				install
python3-lib2to3					install
python3-louis					install
python3-mako					install
python3-markupsafe				install
python3-minimal					install
python3-oauthlib				install
python3-pip					install
python3-pip-whl					install
python3-pkg-resources				install
python3-protobuf				install
python3-pyatspi					install
python3-pycurl					install
python3-pyparsing				install
python3-pysimplesoap				install
python3-reportbug				install
python3-requests				install
python3-setuptools				install
python3-setuptools-whl				install
python3-six					install
python3-smbc					install
python3-software-properties			install
python3-speechd					install
python3-uno					install
python3-urllib3					install
python3-wadllib					install
python3-wheel					install
python3-xdg					install
python3.11					install
python3.11-dev					install
python3.11-minimal				install
python3.11-venv					install
quadrapassel					install
readline-common					install
realmd						install
reportbug					install
rhythmbox					install
rhythmbox-data					install
rhythmbox-plugin-cdrecorder			install
rhythmbox-plugins				install
rpcsvc-proto					install
rsync						install
rsyslog						install
rtkit						install
runc						install
runit-helper					install
rygel						install
rygel-playbin					install
rygel-tracker					install
samba-libs:amd64				install
sane-airscan					install
sane-utils					install
seahorse					install
sed						install
sensible-utils					install
sgml-base					install
sgml-data					install
shared-mime-info				install
shotwell					install
shotwell-common					install
simple-scan					install
socat						install
software-properties-common			install
software-properties-gtk				install
sound-icons					install
sound-theme-freedesktop				install
speech-dispatcher				install
speech-dispatcher-audio-plugins:amd64		install
speech-dispatcher-espeak-ng			install
ssl-cert					install
sudo						install
swell-foop					install
switcheroo-control				install
synaptic					install
sysstat						install
system-config-printer-common			install
system-config-printer-udev			install
systemd						install
systemd-sysv					install
systemd-timesyncd				install
sysvinit-utils					install
tali						install
tar						install
task-brazilian-portuguese			install
task-brazilian-portuguese-desktop		install
task-desktop					install
task-gnome-desktop				install
task-ssh-server					install
tasksel						install
tasksel-data					install
timgm6mb-soundfont				install
tini						install
totem						install
totem-common					install
totem-plugins					install
tpm-udev					install
traceroute					install
tracker						install
tracker-extract					install
tracker-miner-fs				install
transmission-common				install
transmission-gtk				install
tzdata						install
ucf						install
udev						install
udisks2						install
uno-libs-private				install
unzip						install
update-inetd					install
upower						install
ure						install
usb-modeswitch					install
usb-modeswitch-data				install
usb.ids						install
usbmuxd						install
usr-is-merged					install
util-linux					install
util-linux-extra				install
util-linux-locales				install
va-driver-all:amd64				install
vdpau-driver-all:amd64				install
vim-common					install
vim-tiny					install
wamerican					install
wbrazilian					install
webp-pixbuf-loader:amd64			install
wget						install
whiptail					install
wireless-regdb					install
wireplumber					install
wpasupplicant					install
x11-apps					install
x11-common					install
x11-session-utils				install
x11-utils					install
x11-xkb-utils					install
x11-xserver-utils				install
xauth						install
xbitmaps					install
xbrlapi						install
xcvt						install
xdg-dbus-proxy					install
xdg-desktop-portal				install
xdg-desktop-portal-gnome			install
xdg-desktop-portal-gtk				install
xdg-user-dirs					install
xdg-user-dirs-gtk				install
xdg-utils					install
xfonts-100dpi					install
xfonts-75dpi					install
xfonts-base					install
xfonts-encodings				install
xfonts-scalable					install
xfonts-utils					install
xinit						install
xkb-data					install
xkbset						install
xml-core					install
xorg						install
xorg-docs-core					install
xserver-common					install
xserver-xephyr					install
xserver-xorg					install
xserver-xorg-core				install
xserver-xorg-input-all				install
xserver-xorg-input-libinput			install
xserver-xorg-input-wacom			install
xserver-xorg-legacy				install
xserver-xorg-video-all				install
xserver-xorg-video-amdgpu			install
xserver-xorg-video-ati				install
xserver-xorg-video-fbdev			install
xserver-xorg-video-intel			install
xserver-xorg-video-nouveau			install
xserver-xorg-video-qxl				install
xserver-xorg-video-radeon			install
xserver-xorg-video-vesa				install
xserver-xorg-video-vmware			install
xwayland					install
xz-utils					install
yelp						install
yelp-xsl					install
zenity						install
zenity-common					install
zerofree					install
zlib1g:amd64					install
zlib1g-dev:amd64				install
zstd						install
zutty						install
EOF

    sudo apt-get update
    DEBIAN_FRONTEND=noninteractive apt-get -y dselect-upgrade
    sudo apt-get -y dselect-upgrade
}

# Function to install necessary system packages and perform system update
system_update() {
    echo -n "[+] Updating system package lists... "

    apt update >/dev/null 2>&1 & print_spinner $!
    if [ $? -ne 0 ]; then
        echo "KO"
            echo "[!] Failed to update package lists. Aborting." >&2
            exit 1
    fi
    print_green "OK"

    echo -n "[+] Upgrading system packages... "
    apt dist-upgrade -y >/dev/null 2>&1 & print_spinner $!
    if [ $? -ne 0 ]; then
        print_red "KO"
        echo "[!] Failed to upgrade system packages. Aborting." >&2
        exit 1
    fi
    print_green "OK"
}

# Function to install MariaDB
mariadb_install() {
    echo -n "[+] Installing MariaDB... "
    apt --no-install-recommends install mariadb-server mariadb-client -y >/dev/null 2>&1 & print_spinner $!
    if [ $? -ne 0 ]; then
        print_red "KO"
        echo "[!] Failed to install MariaDB. Aborting." >&2
        exit 1
    fi
    print_green "OK"
}

# Function to secure MariaDB installation
mariadb_secure() {
    echo -n "[+] Securing MariaDB... "
    if ! mariadb -u root <<SQL >/dev/null 2>&1
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.01', '::1');
ALTER USER root@'localhost' IDENTIFIED BY '';
DELETE FROM mysql.user WHERE User='';
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
FLUSH PRIVILEGES;
SQL
    then
        print_red "KO"
        echo "[!] Failed to secure MariaDB. Aborting." >&2
        exit 1
    fi
    print_green "OK"
}


# Function to initialize MariaDB database and user
mariadb_db_init() {
    echo -n "[+] Initializing MariaDB database and user... "
    if ! mariadb -u root <<SQL >/dev/null 2>&1
CREATE DATABASE ${DB_SCHEMA};
GRANT ALL ON ${DB_SCHEMA}.* TO '${DB_USER}'@'${DB_HOST}' IDENTIFIED BY '${DB_PASS}';
FLUSH PRIVILEGES;
SQL
    then
        print_red "KO"
        echo "[!] Failed to init MariaDB. Aborting." >&2
        exit 1
    fi
    print_green "OK"
}

# Function to install freeRADIUS
freeradius_install() {
    echo -n "[+] Installing freeRADIUS... "
    apt --no-install-recommends install freeradius freeradius-common freeradius-mysql -y >/dev/null 2>&1 & print_spinner $!
    if [ $? -ne 0 ]; then
        print_red "KO"
        echo "[!] Failed to install freeRADIUS. Aborting." >&2
        exit 1
    fi
    print_green "OK"
}

# Function to set up freeRADIUS SQL module
freeradius_setup_sql_mod() {
    echo -n "[+] Setting up freeRADIUS SQL module... "
    if ! sed -Ei '/^[\t\s#]*tls\s+\{/, /[\t\s#]*\}/ s/^/#/' "${FREERADIUS_SQL_MOD_PATH}" >/dev/null 2>&1 || \
       ! sed -Ei 's/^[\t\s#]*dialect\s+=\s+.*$/\tdialect = "mysql"/g' "${FREERADIUS_SQL_MOD_PATH}" >/dev/null 2>&1 || \
       ! sed -Ei 's/^[\t\s#]*driver\s+=\s+"rlm_sql_null"/\tdriver = "rlm_sql_\${dialect}"/g' "${FREERADIUS_SQL_MOD_PATH}" >/dev/null 2>&1 || \
       ! sed -Ei "s/^[\t\s#]*server\s+=\s+\"localhost\"/\tserver = \"${DB_HOST}\"/g" "${FREERADIUS_SQL_MOD_PATH}" >/dev/null 2>&1 || \
       ! sed -Ei "s/^[\t\s#]*port\s+=\s+[0-9]+/\tport = ${DB_PORT}/g" "${FREERADIUS_SQL_MOD_PATH}" >/dev/null 2>&1 || \
       ! sed -Ei "s/^[\t\s#]*login\s+=\s+\"radius\"/\tlogin = \"${DB_USER}\"/g" "${FREERADIUS_SQL_MOD_PATH}" >/dev/null 2>&1 || \
       ! sed -Ei "s/^[\t\s#]*password\s+=\s+\"radpass\"/\tpassword = \"${DB_PASS}\"/g" "${FREERADIUS_SQL_MOD_PATH}" >/dev/null 2>&1 || \
       ! sed -Ei "s/^[\t\s#]*radius_db\s+=\s+\"radius\"/\tradius_db = \"${DB_SCHEMA}\"/g" "${FREERADIUS_SQL_MOD_PATH}" >/dev/null 2>&1 || \
       ! sed -Ei 's/^[\t\s#]*read_clients\s+=\s+.*$/\tread_clients = yes/g' "${FREERADIUS_SQL_MOD_PATH}" >/dev/null 2>&1 || \
       ! sed -Ei 's/^[\t\s#]*client_table\s+=\s+.*$/\tclient_table = "nas"/g' "${FREERADIUS_SQL_MOD_PATH}" >/dev/null 2>&1 || \
       ! ln -s "${FREERADIUS_SQL_MOD_PATH}" /etc/freeradius/3.0/mods-enabled/ >/dev/null 2>&1; then
        print_red "KO"
        echo "[!] Failed to set up freeRADIUS SQL module. Aborting." >&2
        exit 1
    fi
    print_green "OK"
}

# Function to restart freeRADIUS service
freeradius_enable_restart() {
    echo -n "[+] Enabling and restarting freeRADIUS... "
    if ! systemctl enable freeradius.service  >/dev/null 2>&1 || ! systemctl restart freeradius.service >/dev/null 2>&1; then
        print_red "KO"
        echo "[!] Failed to enable and restart freeRADIUS. Aborting." >&2
        exit 1
    fi
    print_green "OK"
}

# Function to install daloRADIUS and required packages
daloradius_install_dep() {
    echo -n "[+] Installing daloRADIUS dependencies... "
    apt --no-install-recommends install apache2 php libapache2-mod-php php-mysql php-zip php-mbstring php-common php-curl \
                                        php-gd php-db php-mail php-mail-mime freeradius-utils git rsyslog -y >/dev/null 2>&1 & \
    print_spinner $!

    if [ $? -ne 0 ]; then
        print_red "KO"
        print_red "[!] Failed to install daloRADIUS dependencies. Aborting." >&2
        exit 1
    fi
    print_green "OK"
}

# Function to install daloRADIUS
daloradius_installation() {
    SCRIPT_PATH=$(realpath $0)
    SCRIPT_DIR=$(dirname ${SCRIPT_PATH})
    
    if [ "${SCRIPT_DIR}" = "${DALORADIUS_ROOT_DIRECTORY}/setup" ]; then
        # local installation
        echo -n "[+] Setting up daloRADIUS... "
        
        if [ ! -f "${DALORADIUS_CONF_FILE}.sample" ]; then
            print_red "KO"
            print_red "[!] daloRADIUS code seems to be corrupted. Aborting." >&2
            exit 1
        fi

    else
        # remote installation
        echo -n "[+] Downloading and setting up daloRADIUS... "
        if [ -d "${DALORADIUS_ROOT_DIRECTORY}" ]; then
            print_red "KO"
            print_red "[!] Directory ${DALORADIUS_ROOT_DIRECTORY} already exists. Aborting." >&2
            exit 1
        fi

        git clone https://github.com/lirantal/daloradius.git "${DALORADIUS_ROOT_DIRECTORY}" >/dev/null 2>&1 & print_spinner $!
        if [ $? -ne 0 ]; then
            print_red "KO"
            print_red "[!] Failed to clone daloRADIUS repository. Aborting." >&2
            exit 1
        fi

    fi

    print_green "OK"
}

# Function to create required directories for daloRADIUS
daloradius_setup_required_dirs() {
    echo -n "[+] Creating required directories for daloRADIUS... "

    if ! mkdir -p /var/log/apache2/daloradius/{operators,users} >/dev/null 2>&1; then
        print_red "KO"
        print_red "[!] Failed to create operators and users directories. Aborting." >&2
        exit 1
    fi

    if ! mkdir -p ${DALORADIUS_ROOT_DIRECTORY}/var/{log,backup} >/dev/null 2>&1; then
        print_red "KO"
        print_red "[!] Failed to create log and backup directories. Aborting." >&2
        exit 1
    fi

    if ! chown -R www-data:www-data ${DALORADIUS_ROOT_DIRECTORY}/var >/dev/null 2>&1; then
        print_red "KO"
        print_red "[!] Failed to change ownership of var directory. Aborting." >&2
        exit 1
    fi

    if ! chmod -R 775 ${DALORADIUS_ROOT_DIRECTORY}/var >/dev/null 2>&1; then
        print_red "KO"
        print_red "[!] Failed to change permissions of var directory. Aborting." >&2
        exit 1
    fi

    print_green "OK"
}

# Function to set up daloRADIUS
daloradius_setup_required_files() {
    echo -n "[+] Setting up daloRADIUS... "
    DALORADIUS_CONF_FILE="${DALORADIUS_ROOT_DIRECTORY}/app/common/includes/daloradius.conf.php"

    if ! cp "${DALORADIUS_CONF_FILE}.sample" "${DALORADIUS_CONF_FILE}" >/dev/null 2>&1; then
        print_red "KO"
        print_red "[!] Failed to copy sample configuration file. Aborting." >&2
        exit 1
    fi

    ( sed -Ei "s/^.*CONFIG_DB_HOST'\].*$/\$configValues['CONFIG_DB_HOST'] = '${DB_HOST}';/" "${DALORADIUS_CONF_FILE}" >/dev/null 2>&1 && \
      sed -Ei "s/^.*CONFIG_DB_PORT'\].*$/\$configValues['CONFIG_DB_PORT'] = '${DB_PORT}';/" "${DALORADIUS_CONF_FILE}" >/dev/null 2>&1 && \
      sed -Ei "s/^.*CONFIG_DB_USER'\].*$/\$configValues['CONFIG_DB_USER'] = '${DB_USER}';/" "${DALORADIUS_CONF_FILE}" >/dev/null 2>&1 && \
      sed -Ei "s/^.*CONFIG_DB_PASS'\].*$/\$configValues['CONFIG_DB_PASS'] = '${DB_PASS}';/" "${DALORADIUS_CONF_FILE}" >/dev/null 2>&1 && \
      sed -Ei "s/^.*CONFIG_DB_NAME'\].*$/\$configValues['CONFIG_DB_NAME'] = '${DB_SCHEMA}';/" "${DALORADIUS_CONF_FILE}" >/dev/null 2>&1 ) & \
    print_spinner $!

    if [ $? -ne 0 ]; then
        print_red "KO"
        print_red "[!] Failed to setup daloRADIUS configuration file. Aborting." >&2
        exit 1
    fi

    if ! chown www-data:www-data "${DALORADIUS_CONF_FILE}" >/dev/null 2>&1; then
        print_red "KO"
        print_red "[!] Failed to change ownership of configuration file. Aborting." >&2
        exit 1
    fi

    if ! chmod 664 "${DALORADIUS_CONF_FILE}" >/dev/null 2>&1; then
        print_red "KO"
        print_red "[!] Failed to change permissions of configuration file. Aborting." >&2
        exit 1
    fi

    if ! chown www-data:www-data ${DALORADIUS_ROOT_DIRECTORY}/contrib/scripts/dalo-crontab >/dev/null 2>&1; then
        print_red "KO"
        print_red "[!] Failed to change ownership of dalo-crontab script. Aborting." >&2
        exit 1
    fi

    print_green "OK"
}

# Function to disable all Apache sites
apache_disable_all_sites() {
    echo -n "[+] Disabling all Apache sites... "
    find /etc/apache2/sites-enabled/ -type l -exec rm "{}" \; >/dev/null 2>&1 & print_spinner $!
    if [ $? -ne 0 ]; then
        print_red "KO"
        print_red "[!] Failed to disable all Apache sites. Aborting." >&2
        exit 1
    fi
    print_green "OK"
}

# Function to set up Apache environment variables for daloRADIUS
apache_setup_envvars() {
    echo -n "[+] Setting up Apache environment variables for daloRADIUS... "
    cat <<EOF >> /etc/apache2/envvars
# daloRADIUS users interface port
export DALORADIUS_USERS_PORT=${DALORADIUS_USERS_PORT}

# daloRADIUS operators interface port
export DALORADIUS_OPERATORS_PORT=${DALORADIUS_OPERATORS_PORT}

# daloRADIUS package root directory
export DALORADIUS_ROOT_DIRECTORY=${DALORADIUS_ROOT_DIRECTORY}

# daloRADIUS administrator's email
export DALORADIUS_SERVER_ADMIN=${DALORADIUS_SERVER_ADMIN}
EOF
    if [ $? -ne 0 ]; then
        print_red "KO"
        print_red "[!] Failed to set up Apache environment variables for daloRADIUS. Aborting." >&2
        exit 1
    fi
    print_green "OK"
}

# Function to set up Apache ports for daloRADIUS
apache_setup_ports() {
    echo -n "[+] Setting up Apache ports for daloRADIUS... "
    cat <<EOF > /etc/apache2/ports.conf
# daloRADIUS
Listen \${DALORADIUS_USERS_PORT}
Listen \${DALORADIUS_OPERATORS_PORT}
EOF
    if [ $? -ne 0 ]; then
        print_red "KO"
        print_red "[!] Failed to set up Apache ports for daloRADIUS. Aborting." >&2
        exit 1
    fi
    print_green "OK"
}

# Function to set up Apache site for operators
apache_setup_operators_site() {
    echo -n "[+] Setting up Apache site for operators... "
    
    cat <<EOF > /etc/apache2/sites-available/operators.conf
<VirtualHost *:\${DALORADIUS_OPERATORS_PORT}>
  ServerAdmin \${DALORADIUS_SERVER_ADMIN}
  DocumentRoot \${DALORADIUS_ROOT_DIRECTORY}/app/operators

  <Directory \${DALORADIUS_ROOT_DIRECTORY}/app/operators>
    Options -Indexes +FollowSymLinks
    AllowOverride All
    Require all granted
  </Directory>

  <Directory \${DALORADIUS_ROOT_DIRECTORY}>
    Require all denied
  </Directory>

  ErrorLog \${APACHE_LOG_DIR}/daloradius/operators/error.log
  CustomLog \${APACHE_LOG_DIR}/daloradius/operators/access.log combined
</VirtualHost>
EOF
    if [ $? -ne 0 ]; then
        print_red "KO"
        print_red "[!] Failed to init operators site. Aborting." >&2
        exit 1
    fi

    if ! a2ensite operators.conf >/dev/null 2>&1; then
        print_red "KO"
        print_red "[!] Failed to enable operators site. Aborting." >&2
        exit 1
    fi

    print_green "OK"
}

# Function to set up Apache site for users
apache_setup_users_site() {
    echo -n "[+] Setting up Apache site for users... "

    cat <<EOF > /etc/apache2/sites-available/users.conf
<VirtualHost *:\${DALORADIUS_USERS_PORT}>
  ServerAdmin \${DALORADIUS_SERVER_ADMIN}
  DocumentRoot \${DALORADIUS_ROOT_DIRECTORY}/app/users

  <Directory \${DALORADIUS_ROOT_DIRECTORY}/app/users>
    Options -Indexes +FollowSymLinks
    AllowOverride None
    Require all granted
  </Directory>

  <Directory \${DALORADIUS_ROOT_DIRECTORY}>
    Require all denied
  </Directory>

  ErrorLog \${APACHE_LOG_DIR}/daloradius/users/error.log
  CustomLog \${APACHE_LOG_DIR}/daloradius/users/access.log combined
</VirtualHost>
EOF
    if [ $? -ne 0 ]; then
        print_red "KO"
        print_red "[!] Failed to init users site. Aborting." >&2
        exit 1
    fi

    if ! a2ensite users.conf >/dev/null 2>&1; then
        print_red "KO"
        print_red "[!] Failed to enable users site. Aborting." >&2
        exit 1
    fi

    print_green "OK"
}

# Function to enable and restart Apache
apache_enable_restart() {
    echo -n "[+] Enabling and restarting Apache... "
    if ! systemctl enable apache2.service  >/dev/null 2>&1 || ! systemctl restart apache2.service >/dev/null 2>&1; then
        print_red "KO"
        echo "[!] Failed to enable and restart Apache. Aborting." >&2
        exit 1
    fi
    print_green "OK"
}

# Function to load daloRADIUS SQL schema into MariaDB
daloradius_load_sql_schema() {
    DB_DIR="${DALORADIUS_ROOT_DIRECTORY}/contrib/db"
    echo -n "[+] Loading daloRADIUS SQL schema into MariaDB... "

    mariadb --defaults-extra-file="${MARIADB_CLIENT_FILENAME}" < "${DB_DIR}/fr3-mariadb-freeradius.sql" >/dev/null 2>&1 & print_spinner $!
    if [ $? -ne 0 ]; then
        print_red "KO"
        print_red "[!] Failed to load freeRADIUS SQL schema into MariaDB. Aborting." >&2
        exit 1
    fi

    mariadb --defaults-extra-file="${MARIADB_CLIENT_FILENAME}" < "${DB_DIR}/mariadb-daloradius.sql" >/dev/null 2>&1 & print_spinner $!
    if [ $? -ne 0 ]; then
        print_red "KO"
        print_red "[!] Failed to load daloRADIUS SQL schema into MariaDB. Aborting." >&2
        exit 1
    fi

    print_green "OK"
}

system_finalize() {
    INIT_USERNAME="administrator"
    INIT_PASSWORD=$(generate_random_string 12)
    SQL="UPDATE operators SET password='${INIT_PASSWORD}' WHERE username='${INIT_USERNAME}'"
    if ! mariadb --defaults-extra-file="${MARIADB_CLIENT_FILENAME}" --execute="${SQL}" >/dev/null 2>&1; then
        INIT_PASSWORD="radius"
        print_yellow "[!] Failed to update ${INIT_USERNAME}'s default password"
    fi

    echo -e "[+] ${GREEN}daloRADIUS${NC} has been installed."
    echo -e "    ${BLUE}Here are some installation details:${NC}"
    echo -e "      - DB hostname: ${BLUE}${DB_HOST}${NC}"
    echo -e "      - DB port: ${BLUE}${DB_PORT}${NC}"
    echo -e "      - DB username: ${BLUE}${DB_USER}${NC}"
    echo -e "      - DB password: ${BLUE}${DB_PASS}${NC}"
    echo -e "      - DB schema: ${BLUE}${DB_SCHEMA}${NC}"

    echo -e "    Users' dashboard can be reached via ${BLUE}HTTP${NC} on port ${BLUE}${DALORADIUS_USERS_PORT}${NC}."
    echo -e "    Operators' dashboard can be reached via ${BLUE}HTTP${NC} on port ${BLUE}${DALORADIUS_OPERATORS_PORT}${NC}."
    echo -e "    To log into the ${BLUE}operators' dashboard${NC}, use the following credentials:"
    echo -e "      - Username: ${BLUE}${INIT_USERNAME}${NC}"
    echo -e "      - Password: ${BLUE}${INIT_PASSWORD}${NC}"
}

# Main function calling other functions in the correct order
main() {
    system_ensure_root
    restore_package_list
    system_update

    mariadb_install
    mariadb_secure
    mariadb_db_init
    mariadb_init_conf

    daloradius_install_dep
    daloradius_installation
    daloradius_setup_required_dirs
    daloradius_setup_required_files

    daloradius_load_sql_schema

    freeradius_install
    freeradius_setup_sql_mod
    freeradius_enable_restart

    apache_disable_all_sites
    apache_setup_envvars
    apache_setup_ports
    apache_setup_operators_site
    apache_setup_users_site
    apache_enable_restart

    system_finalize
    mariadb_clean_conf
}

# Parsing command line options
while getopts ":u:p:h:P:s:c" opt; do
  case $opt in
    u) DB_USER="$OPTARG" ;;
    p) DB_PASS="$OPTARG" ;;
    h) DB_HOST="$OPTARG" ;;
    P) DB_PORT="$OPTARG" ;;
    s) DB_SCHEMA="$OPTARG" ;;
    c) ENABLE_COLORS=false ;;
    \?) echo "Invalid option -$OPTARG" >&2; exit 1 ;;
  esac
done

# Generate a random username if not provided
if [ -z "$DB_USER" ]; then
    prefix="user_"
    random_string=$(generate_random_string 6)
    DB_USER="${prefix}${random_string}"
fi

# Generate a random password if not provided
if [ -z "$DB_PASS" ]; then
    DB_PASS=$(generate_random_string 12)
fi

# Generate a random scheme if not provided
if [ -z "$DB_SCHEMA" ]; then
    prefix="radius_"
    random_string=$(generate_random_string 6)
    DB_SCHEMA="${prefix}${random_string}"
fi

# Define color codes
if $ENABLE_COLORS; then
    GREEN='\033[0;32m'
    RED='\033[0;31m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    NC='\033[0m' # No Color
else
    GREEN=''
    RED=''
    YELLOW=''
    BLUE=''
    NC=''
fi

# Call the main function to start the installation process
main
