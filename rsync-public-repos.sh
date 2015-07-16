#!/bin/bash
#
# Script to mirror package repositories via rsync
#
# Author: Steven Nemetz
# snemetz@hotmail.com
#
# TODO:
#	make email optional
#	make logs optional

MAIL_ADDR="<user>@<company>.com"
REPO_DIR=/data
DATE=/bin/date
MIRROR_DIR=$REPO_DIR/mirror
PARTIAL_DIR=$REPO_DIR/tmp
LOG_DIR=$REPO_DIR/logs
mirror_repos='centos epel opensuse'

if [ ! -d $LOG_DIR ]; then
  mkdir -p $LOG_DIR
fi
if [ ! -d $PARTIAL_DIR ]; then
  mkdir -p $PARTIAL_DIR
fi
if [ ! -d $MIRROR_DIR ]; then
  mkdir -p $MIRROR__DIR
fi

# TODO:
#	Add include
mirror () {
  # Args: repo, mirror site, excludes
  local REPO=$1
  local rsync_module=$2
  local MIRROR_Site=$3
  local MIRROR_Exclude=$4
  local Repo_Name=$REPO
  local MIRROR_DST="${MIRROR_DIR}/${REPO}"
  local MIRROR_SRC="${MIRROR_Site}::${rsync_module}"
  local MIRROR_LOG=$LOG_DIR/mirror.${REPO}.log
  local DATERUN=`/bin/date +%Y-%m-%d`

  if [ -n "$MIRROR_Exclude" ]; then
    local exclude_list=$(echo $MIRROR_Exclude | tr ' ' '\n' | uniq | sed 's/^/--exclude=/' | tr '\n' ' ')
    exclude_list="--delete-excluded ${exclude_list}"
  else
    exclude_list=''
  fi
  echo "Mirroring of $Repo_Name repo on $HOSTNAME started at `$DATE '+%Y-%m-%d %H:%M:%S'`" > $MIRROR_LOG
  echo "CMD: rsync -avzH --stats --delete --partial-dir=$PARTIAL_DIR $exclude_list ${MIRROR_SRC} ${MIRROR_DST}" >> $MIRROR_LOG 2>&1
  rsync -avzH --stats --delete --partial-dir=$PARTIAL_DIR $exclude_list ${MIRROR_SRC} ${MIRROR_DST} >> $MIRROR_LOG 2>&1
  echo "Mirroring of $Repo_Name repo finished at `$DATE '+%Y-%m-%d %H:%M:%S'`" >> $MIRROR_LOG
  mail -s "RSYNC: $Repo_Name Updates on $DATERUN" $MAIL_ADDR < $MIRROR_LOG
}

for M in $mirror_repos; do
  case $M in
    centos)
      mirror 'centos' centos 'mirrors.kernel.org' "'/[234]*' dostools/ graphics/ HEADER.images/ apt/ build/ contrib/ csgfs/ docs/ fasttrack/ isos/ testing/ SRPMS/ alpha/ ia64/ s390/ s390x/ i386/ ppc/"
    ;;
    debian)
      mirror 'debian' debian 'mirrors.kernel.org' ""
    ;;
    epel)
      mirror 'epel' fedora-epel 'mirrors.kernel.org' "4\*/ beta/ testing/ ppc/ ppc64/ i386/ SRPMS/ debug/ repoview/"
    ;;
    opensuse)
      mirror 'opensuse' opensuse 'mirrors.kernel.org' "'/10.*' '/factory*' delta/ 'i[56]86/' iso/ src/ '*-test/'"
    ;;
    ubuntu)
      mirror 'ubuntu' ubuntu 'mirrors.kernel.org' ""
    ;;
    *)
      echo "Unknown repo '$M' to mirror"
    ;;
  esac
done

exit

# Remove everything below here after testing is done

if [ 1 -eq 2 ]; then
#==================================================
# Mirror CentOS from source repo
#==================================================
#    rsync -avz --delete --exclude='/[2345]*' rsync://mirrors.kernel.org/mirrors/centos/ centos

#mirror('centos', 'mirrors.kernel.org', "'/[234]*' dostools/ graphics/ HEADER.images/ apt/ build/ contrib/ csgfs/ docs/ fasttrack/ isos/ testing/ SRPMS/ alpha/ ia64/ s390/ s390x/ i386/ ppc/")

MIRROR_SRC="mirrors.kernel.org::centos"
#MIRROR_SRC="mirror.stanford.edu/mirrors/centos"
#MIRROR_SRC="linux.mirrors.es.net/centos"
MIRROR_LOG=$LOG_DIR/mirror.centos.log
MIRROR_DST=$MIRROR_DIR/centos
DATERUN=`/bin/date +%Y-%m-%d`

echo "Mirroring of CentOS repo on $HOSTNAME started at `$DATE '+%Y-%m-%d %H:%M:%S'`" > $MIRROR_LOG

rsync -avzH --stats --delete --partial-dir=$PARTIAL_DIR --delete-excluded --exclude='/[234]*' --exclude=dostools/ --exclude=graphics/ --exclude=HEADER.images/ --exclude=apt/ --exclude=build/ --exclude=contrib/ --exclude=csgfs/ --exclude=docs/ --exclude=fasttrack/ --exclude=isos/ --exclude=testing/ --exclude=SRPMS/ --exclude=alpha/ --exclude=ia64/ --exclude=s390/ --exclude=s390x/ --exclude=i386/ --exclude=ppc/ ${MIRROR_SRC} ${MIRROR_DST} >> $MIRROR_LOG 2>&1

echo "Mirroring of CentOS repo finished at `$DATE '+%Y-%m-%d %H:%M:%S'`" >> $MIRROR_LOG
mail -s "RSYNC: CentOS Updates on $DATERUN" $MAIL_ADDR < $MIRROR_LOG
fi
#==================================================
# Mirror Debian from source repo
#==================================================
#    rsync -avz --delete rsync://mirrors.kernel.org/mirrors/debian/ debian

#mirror('debian', 'mirrors.kernel.org', "")

REPO='debian'
MIRROR_DST=$MIRROR_DIR/$REPO
MIRROR_SRC="mirrors.kernel.org::$REPO"
MIRROR_LOG=$LOG_DIR/mirror.${REPO}.log
Repo_Name='Debian'
DATERUN=`/bin/date +%Y-%m-%d`
echo "Mirroring of $Repo_Name repo on $HOSTNAME started at `$DATE '+%Y-%m-%d %H:%M:%S'`" > $MIRROR_LOG
rsync -avzH --stats --delete --partial-dir=$PARTIAL_DIR ${MIRROR_SRC} ${MIRROR_DST} >> $MIRROR_LOG 2>&1
echo "Mirroring of $Repo_Name repo finished at `$DATE '+%Y-%m-%d %H:%M:%S'`" >> $MIRROR_LOG
mail -s "RSYNC: $Repo_Name Updates on $DATERUN" $MAIL_ADDR < $MIRROR_LOG

if [ 1 -eq 2 ]; then
#==================================================
# Mirror Fedora Project EPEL from source repo
#==================================================

#mirror('epel', 'mirrors.kernel.org', "4\*/ beta/ testing/ ppc/ ppc64/ i386/ SRPMS/ debug/ repoview/")

MIRROR_DST=$MIRROR_DIR/epel
MIRROR_SRC="mirrors.kernel.org::fedora-epel"
MIRROR_LOG=$LOG_DIR/mirror.epel.log
DATERUN=`/bin/date +%Y-%m-%d`
# Mirror sources: mirrors.kernel.org, fedora.mirror.facebook.com
# Size: epel/5 17G, SRPMS 2.9G, i386 5.3G, x86_64 7.1G,
# 2008-12-31 7.1G for command below

echo "Mirroring of EPEL repo on $HOSTNAME started at `$DATE '+%Y-%m-%d %H:%M:%S'`" > $MIRROR_LOG

rsync -avzH --stats --delete --partial-dir=$PARTIAL_DIR --delete-excluded --include=6\*/ --include=5\*/ --exclude=4\*/ --exclude=beta/ --exclude=testing/ --exclude=ppc/ --exclude=ppc64/ --exclude=i386/ --exclude=SRPMS/ --exclude=debug/ --exclude=repoview/ ${MIRROR_SRC} ${MIRROR_DST} >> $MIRROR_LOG 2>&1
# Fix for Oracle
ln -s $MIRROR_DST/6 $MIRROR_DST/6Server

echo "Mirroring of EPEL repo finished at `$DATE '+%Y-%m-%d %H:%M:%S'`" >> $MIRROR_LOG
mail -s "RSYNC: EPEL Updates on $DATERUN" $MAIL_ADDR < $MIRROR_LOG
fi
if [ 1 -eq 2 ]; then
#==================================================
# Mirror OpenSUSE from source repo
#==================================================
#    rsync -avz --delete --exclude='/factory*' --exclude=iso/ --exclude=delta/ rsync://mirrors.kernel.org/mirrors/opensuse/ opensuse

#mirror('opensuse', 'mirrors.kernel.org', "'/factory*' delta/ iso/")

MIRROR_DST=$MIRROR_DIR/opensuse
MIRROR_SRC="mirrors.kernel.org::opensuse"
MIRROR_LOG=$LOG_DIR/mirror.opensuse.log
Repo_Name='OpenSUSE'
DATERUN=`/bin/date +%Y-%m-%d`
echo "Mirroring of $Repo_Name repo on $HOSTNAME started at `$DATE '+%Y-%m-%d %H:%M:%S'`" > $MIRROR_LOG
rsync -avzH --stats --delete --partial-dir=$PARTIAL_DIR --delete-excluded --exclude='/factory*' --exclude=delta/ --exclude=iso/ ${MIRROR_SRC} ${MIRROR_DST} >> $MIRROR_LOG 2>&1
echo "Mirroring of $Repo_Name repo finished at `$DATE '+%Y-%m-%d %H:%M:%S'`" >> $MIRROR_LOG
mail -s "RSYNC: $Repo_Name Updates on $DATERUN" $MAIL_ADDR < $MIRROR_LOG
fi
#==================================================
# Mirror Ubuntu from source repo
#==================================================
#    rsync -avz --delete rsync://mirrors.kernel.org/mirrors/ubuntu/ ubuntu

#mirror('ubuntu', 'mirrors.kernel.org', "")

REPO='ubuntu'
MIRROR_DST=$MIRROR_DIR/$REPO
MIRROR_SRC="mirrors.kernel.org::$REPO"
MIRROR_LOG=$LOG_DIR/mirror.${REPO}.log
Repo_Name='Ubuntu'
DATERUN=`/bin/date +%Y-%m-%d`
echo "Mirroring of $Repo_Name repo on $HOSTNAME started at `$DATE '+%Y-%m-%d %H:%M:%S'`" > $MIRROR_LOG
rsync -avzH --stats --delete --partial-dir=$PARTIAL_DIR ${MIRROR_SRC} ${MIRROR_DST} >> $MIRROR_LOG 2>&1
echo "Mirroring of $Repo_Name repo finished at `$DATE '+%Y-%m-%d %H:%M:%S'`" >> $MIRROR_LOG
mail -s "RSYNC: $Repo_Name Updates on $DATERUN" $MAIL_ADDR < $MIRROR_LOG

