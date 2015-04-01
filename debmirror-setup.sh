#!/bin/bash
#
# Install debmirror on CentoOS
#
# Updated: 2015-03-31
#
debmirror_version='2.16'
tarfile="debmirror_${debmirror_version}ubuntu1.tar.gz"

yum install -y perl-libwww-perl perl-Compress-Zlib perl-Digest-SHA1 perl-Net* rsync perl-LockFile-Simple perl-Digest-MD5 bzip2 ed patch
wget http://archive.ubuntu.com/ubuntu/pool/universe/d/debmirror/${tarfile}
tar -xzvf ${tarfile}
cd debmirror-${debmirror_version}ubuntu1
make
cp debmirror mirror-size /usr/local/bin/
cp debmirror.1 /usr/share/man/man1/
