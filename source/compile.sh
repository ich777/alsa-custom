# Set Variables
export DATA_DIR="/root/alsa"
export APP_NAME="alsa"
export LAT_V=1.2.4
CPU_COUNT=12

# Download necessary packages and extract them
cd ${DATA_DIR}
wget -q -nc --show-progress --progress=bar:force:noscroll -O ${DATA_DIR}/alsa-lib-$LAT_V.tar.bz2 ftp://ftp.alsa-project.org/pub/lib/alsa-lib-${LAT_V}.tar.bz2
wget -q -nc --show-progress --progress=bar:force:noscroll -O ${DATA_DIR}/alsa-topology-conf-$LAT_V.tar.bz2 ftp://ftp.alsa-project.org/pub/lib/alsa-topology-conf-${LAT_V}.tar.bz2
wget -q -nc --show-progress --progress=bar:force:noscroll -O ${DATA_DIR}/alsa-utils-$LAT_V.tar.bz2 ftp://ftp.alsa-project.org/pub/utils/alsa-utils-${LAT_V}.tar.bz2
tar -xvf ${DATA_DIR}/alsa-lib-${LAT_V}.tar.bz2
tar -xvf ${DATA_DIR}/alsa-topology-conf-$LAT_V.tar.bz2
tar -xvf ${DATA_DIR}/alsa-utils-${LAT_V}.tar.bz2

# Copy files to their appropriate location for ALSA-lib
cp ${DATA_DIR}/smixer.conf ${DATA_DIR}/alsa-lib-${LAT_V}/src/conf/
cd ${DATA_DIR}/alsa-lib-${LAT_V}

# Configure and compile ALSA-lib
./configure \
  --libdir=/usr/lib64 \
  --enable-mixer-modules \
  --enable-topology \
  --disable-ucm
make -j$CPU_COUNT
DESTDIR=${DATA_DIR}/ALSA make install

# Copy files to their appropriate location for ALSA-utils
mkdir -p ${DATA_DIR}/ALSA/etc
echo "# ALSA system-wide config file" > ${DATA_DIR}/ALSA/etc/asound.conf
rm -rf ${DATA_DIR}/ALSA/usr/lib64/*.la
cp -rf ${DATA_DIR}/alsa-topology-conf-$LAT_V/topology ${DATA_DIR}/ALSA/usr/share/alsa/
cd ${DATA_DIR}/alsa-utils-${LAT_V}

# Configure and compile ALSA-utils
./configure \
  --prefix=/usr \
  --libdir=/usr/lib64 \
  --mandir=/usr/man \
  --sysconfdir=/etc \
  --disable-alsaconf \
  --with-asound-state-dir=/boot/config/plugins/sound-driver/conf
make -j$CPU_COUNT
DESTDIR=${DATA_DIR}/ALSA make install

# Cleanup
find ${DATA_DIR}/ALSA | xargs file | grep -e "executable" -e "shared object" | grep ELF | cut -f 1 -d : | xargs strip --strip-unneeded 2>/dev/null
mkdir -p ${DATA_DIR}/v$LAT_V
cd ${DATA_DIR}/ALSA
rm -rf ${DATA_DIR}/ALSA/boot

# Create archive
tar cfvz ${DATA_DIR}/v$LAT_V/alsa-$LAT_V.tar.gz *
