yum install gcc gcc-c++ make autoconf pkgconfig which wget bzip2 unzip patch nasm

 wget http://www.tortall.net/projects/yasm/releases/yasm-1.1.0.tar.gz
 tar xzf yasm-1.1.0.tar.gz
 cd yasm-1.1.0
 ./configure
 make
 make install

 yum install libpng-devel libtiff-devel lcms-devel libogg-devel libvorbis-devel

  wget http://downloads.sourceforge.net/faac/faad2-2.7.tar.bz2
 wget http://downloads.sourceforge.net/faac/faac-1.28.tar.bz2
 tar xjf faad2-2.7.tar.bz2
 tar xjf faac-1.28.tar.bz2
 cd faad2-2.7
 ./configure
 make
 make install
 cd ..
 cd faac-1.28
 ./configure
 make
 make install


 wget http://downloads.sourceforge.net/project/opencore-amr/opencore-amr/0.1.2/opencore-amr-0.1.2.tar.gz
 tar xzf opencore-amr-0.1.2.tar.gz
 cd opencore-amr-0.1.2
 ./configure
 make
 make install


 wget http://www.quut.com/gsm/gsm-1.0.13.tar.gz
 tar xzf gsm-1.0.13.tar.gz
 cd gsm-1.0-pl13
 make
 mkdir /usr/local/include/gsm
 make install


 wget http://sourceforge.net/projects/lame/files/lame/3.98.4/lame-3.98.4.tar.gz/download
 tar xzf lame-3.98.4.tar.gz
 cd lame-3.98.4
 ./configure
 make
 make install


 wget http://openjpeg.googlecode.com/files/openjpeg_v1_4_sources_r697.tgz
 tar xzf openjpeg_v1_4_sources_r697.tgz
 cd openjpeg_v1_4_sources_r697
 ./configure
 make
 make install


 wget http://downloads.xiph.org/releases/theora/libtheora-1.1.1.tar.bz2
 tar xjf libtheora-1.1.1.tar.bz2
 cd libtheora-1.1.1
 ./configure
 make
 make install


 wget ftp://ftp.videolan.org/pub/videolan/x264/snapshots/x264-snapshot-20110104-2245.tar.bz2
 tar xjf x264-snapshot-20110104-2245.tar.bz2
 cd x264-snapshot-20110104-2245
 ./configure
 make
 make install


 wget http://downloads.xvid.org/downloads/xvidcore-1.2.2.tar.bz2
 tar xjf xvidcore-1.2.2.tar.bz2
 cd xvidcore/build/generic
 ./configure
 make
 make install


 wget http://webm.googlecode.com/files/libvpx-v0.9.5.tar.bz2
 tar xjf libvpx-v0.9.5.tar.bz2
 cd libvpx-v0.9.5
 ./configure --disable-examples
 make
 make install


 wget http://www.ffmpeg.org/releases/ffmpeg-0.6.1.tar.bz2
 tar xjf ffmpeg-0.6.1.tar.bz2
 cd ffmpeg-0.6.1
 ./configure --enable-shared --enable-gpl --enable-version3 --enable-nonfree \
 --disable-ffplay --disable-ffserver --enable-pthreads --enable-libopencore-amrnb \
 --enable-libopencore-amrwb --enable-libfaac --enable-libfaad --enable-libgsm --enable-libmp3lame \
 --enable-libopenjpeg --enable-libtheora --enable-libvorbis --enable-libx264 --enable-libxvid \
 --enable-libvpx --disable-debug
 make
 make install


ffmpeg -version