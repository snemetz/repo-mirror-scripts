#!/bin/bash
#
# Mirror repos with debmirror
#
# Author: Steven Nemetz
# snemetz@hotmail.com

MAIL_ADDR="<user>@<company>.com"
mirror_repos='debian ubuntu'
dir_repo=/data
dir_mirrors=${dir_repo}/mirror
dir_logs=${dir_repo}/logs
proto=http
DATE=/bin/date

mirror () {
  # Args: distro, src server, releases, sections, arch
  local distro=$1
  local mirror_log="${dir_logs}/mirror.${distro}.log"
  local DATERUN=`/bin/date +%Y-%m-%d`

  echo "Mirroring of $distro repo on $HOSTNAME started at `$DATE '+%Y-%m-%d %H:%M:%S'`" > $mirror_log
  debmirror --host=$2 --dist=$3 --section=$4 --arch=$5 --nosource --ignore-release-gpg --no-check-gpg --method=$proto --root=/${distro} ${dir_mirrors}/${distro} >> $mirror_log 2>&1
  # --exclude=regex --include=regex
  echo "Mirroring of $distro repo finished at `$DATE '+%Y-%m-%d %H:%M:%S'`" >> $mirror_log
  mail -s "DebMirror: $distro Updates on $DATERUN" $MAIL_ADDR < $mirror_log
}

for M in $mirror_repos; do
  case $M in
    debian)
      mirror $M 'ftp.us.debian.org' 'wheezy,wheezy-updates' 'main' 'amd64'
      # mirrors.kernel.org
    ;;
    ubuntu)
      mirror $M 'us.archive.ubuntu.com' 'precise,precise-updates,trusty,trusty-updates' 'main,restricted,universe,multiverse' 'amd64'
    ;;
    *)
      echo "Unknown repo '$M'"
    ;;
  esac
done

