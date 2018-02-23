# yumライブラリをインストール
yum -y install autoconf automake make gcc gcc-c++ pkgconfig wget libtool zlib-devel
yum -y install git
yum -y install http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
yum -y install --enablerepo=epel yasm

# x264 をインストール
cd /usr/local/src
git clone git://git.videolan.org/x264
cd x264
./configure --enable-shared
make
make install

# fdk-aac をインストール
cd /usr/local/src
git clone --depth 1 git://github.com/mstorsjo/fdk-aac.git
cd fdk-aac
autoreconf -fiv
./configure
make
make install

# ライブラリパスを設定
export LD_LIBRARY_PATH=/usr/local/lib/
echo /usr/local/lib >> /etc/ld.so.conf.d/custom-libs.conf
ldconfig

# ffmpeg のインストール
cd /usr/local/src
git clone git://source.ffmpeg.org/ffmpeg.git ffmpeg
cd ffmpeg
./configure --enable-gpl --enable-nonfree --enable-libfdk_aac --enable-libx264 --enable-shared --arch=x86_64 --enable-pthreads
make
make install
ffmpeg -version

# ImageMagickをインストール
yum -y install ImageMagick ImageMagick-devel