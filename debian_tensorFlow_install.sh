#!/bin/sh

# Raspbian のシステム更新
sudo apt update
sudo apt -yV upgrade
sudo apt -yV dist-upgrade
sudo rpi-update
sudo apt -yV autoremove
sudo apt autoclean
# sudo shutdown -r now



# システムの Python について, pip の更新
cd /tmp
sudo rm -f get-pip.py
wget https://bootstrap.pypa.io/get-pip.py
sudo /usr/bin/python3 get-pip.py
sudo /usr/bin/python get-pip.py

# virtualenv, virtualenv wrapperのインストール
sudo rm -rf $HOME/.virtualenvs
sudo rm -rf ~/.cache/pip
sudo pip install virtualenv virtualenvwrapper
sudo pip3 install virtualenv virtualenvwrapper
export WORKON_HOME=$HOME/.virtualenvs
export VIRTUALENVWRAPPER_PYTHON=/usr/bin/python3
source /usr/local/bin/virtualenvwrapper.sh
touch ~/.bashrc
echo -e "\n# virtualenv and virtualenvwrapper" >> ~/.bashrc
echo "export WORKON_HOME=$HOME/.virtualenvs" >> ~/.bashrc
echo "export VIRTUALENVWRAPPER_PYTHON=/usr/bin/python3" >> ~/.bashrc
echo "source /usr/local/bin/virtualenvwrapper.sh" >> ~/.bashrc
source ~/.bashrc


# 隔離された Python 3 環境を作る
mkvirtualenv --python=/usr/bin/python3 py35
lsvirtualenv
source /usr/local/bin/virtualenvwrapper.sh
workon py35
pip list


# pip の更新
workon py35
cd /tmp
sudo rm -f get-pip.py
wget https://bootstrap.pypa.io/get-pip.py
python get-pip.py
pip list

# TensorFlow, Keras のインストール
workon py35
pip install -U --ignore-installed tensorflow
pip install -U --ignore-installed keras
plp list


# tensorflow のバージョン確認
python -c "import tensorflow as tf; print( tf.__version__ )"

# keras のバージョン確認
python -c "import keras; print( keras.__version__ )"


# matplotlib, pandas, pillow, Dlib, face_recognition, mtcnn, imutils のインストール
workon py35
cd /tmp
sudo apt -yV install python3-matplotlib
sudo apt -yV install python3-pandas
pip3 install -U --ignore-installed pillow
pip3 install -U --ignore-installed six numpy wheel mock
pip3 install -U --ignore-installed git+https://github.com/davisking/dlib
pip3 install -U --ignore-installed git+https://github.com/ageitgey/face_recognition
pip3 install -U --ignore-installed mtcnn
pip3 install -U --ignore-installed git+https://github.com/jrosebr1/imutils

sudo /sbin/ldconfig
sudo apt install imagemagick

# Raspberry Pi で OpenCV をインストール
sudo apt -yV install build-essential gcc g++ dpkg-dev pkg-config python3-dev python3-pip python3-numpy python-dev python-pip python-numpy
sudo apt -yV install git make cmake cmake-curses-gui autoconf automake flex bison clang binutils swig curl
sudo apt -yV install subversion ccache
sudo apt -yV install zip unzip
sudo apt -yV install libopenblas-dev liblapack-dev nvidia-cuda-dev
# sudo apt -yV install nvidia-cuda-toolkit
sudo apt -yV install libxi-dev libsndfile1-dev libopenexr-dev libalut-dev libsdl2-dev libavdevice-dev libavformat-dev libavutil-dev libavcodec-dev libswscale-dev libx264-dev libxvidcore-dev libmp3lame-dev libspnav-dev libglu1-mesa-dev libv4l-dev
sudo apt -yV install libbz2-dev libsqlite3-dev libssl-dev libreadline-dev libpng-dev libtiff-dev zlib1g-dev libx11-dev libgl1-mesa-dev libxrandr-dev libxxf86dga-dev libxcursor-dev libfreetype6-dev libvorbis-dev libeigen3-dev libopenal-dev libode-dev libbullet-dev libgtk2.0-dev
# sudo apt -yV install libjasper-dev
sudo apt -yV install libgtk-3-dev libatlas-base-dev gfortran python2.7-dev python3-dev
sudo apt -yV install nvidia-cg-toolkit
# jpeg
sudo apt -yV install libjpeg62-turbo-dev
cd /tmp
wget http://www.ijg.org/files/jpegsrc.v9c.tar.gz
tar -xvzof jpegsrc.v9c.tar.gz
cd jpeg-9c
./configure
make
sudo make install

workon py35
pip install numpy
cd /tmp
rm -rf opencv
rm -rf opencv_contrib
git clone https://github.com/opencv/opencv.git
git clone https://github.com/opencv/opencv_contrib.git
sudo apt install python-dev python3-dev
cd opencv
rm -rf build
mkdir build
cd build
cmake -D CMAKE_BUILD_TYPE=RELEASE \
      -D CMAKE_INSTALL_PREFIX=/usr/local \
      -D INSTALL_PYTHON_EXAMPLES=ON \
      -D OPENCV_EXTRA_MODULES_PATH=/tmp/opencv_contrib/modules \
      -D BUILD_opencv_python2=OFF \
      -D BUILD_opencv_python3=ON \
      -D PYTHON_DEFAULT_EXECUTABLE=python3 \
      -D BUILD_EXAMPLES=ON ..
make
sudo make install
sudo /sbin/ldconfig
# copy python3 cv2 under .virtualenv
rm -f ~/.virtualenvs/py35/lib/python3.5/site-packages/
cp /tmp/opencv/build/lib/python3/cv2*.so ~/.virtualenvs/py35/lib/python3.5/site-packages
python -c "import cv2; print( cv2.__version__ )"


# OpenCV のバージョン確認
python -c "import cv2; print( cv2.__version__ )"

# dlib のバージョン確認
python -c "import dlib; print( dlib.__version__ )"