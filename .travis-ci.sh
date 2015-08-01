#!/bin/bash
# Based on a test script from avsm/ocaml repo https://github.com/avsm/ocaml

# APT Packages to test
TESTING_PACKAGES="tor tor-geoipdb"

# ARM architectures to test
ARCHITECTURES="armel armhf"

# Tor Debian repository variables
TOR_DEB_REPO="http://deb.torproject.org/torproject.org"
REPO_KEY="A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89"
KEYSERVER="hkp://pool.sks-keyservers.net"
APT_REPO_LIST="/etc/apt/sources.list.d/tor.list"

# Chroot specific variables
CHROOT_DIR=/tmp/$RANDOM
MIRROR="http://http.debian.net/debian/"
VERSION=wheezy

# Debian package dependencies for the host
HOST_DEPENDENCIES="debootstrap qemu-user-static binfmt-support sbuild"

# Debian package dependencies for the chrooted environment
GUEST_DEPENDENCIES="build-essential git m4 sudo python"

# Command used to run the tests
TEST_COMMAND="sudo apt-get install -qq -y"

function setup_arm_chroot {
    # Host dependencies
    sudo apt-get update -qq
    sudo apt-get install -qq -y ${HOST_DEPENDENCIES}

    # Create chrooted environment
    sudo mkdir ${CHROOT_DIR}-${CHROOT_ARCH}
    sudo debootstrap --foreign --no-check-gpg --include=fakeroot,build-essential \
        --arch=${CHROOT_ARCH} ${VERSION} ${CHROOT_DIR}-${CHROOT_ARCH} ${MIRROR}
    sudo cp /usr/bin/qemu-arm-static ${CHROOT_DIR}-${CHROOT_ARCH}/usr/bin/
    sudo chroot ${CHROOT_DIR}-${CHROOT_ARCH} ./debootstrap/debootstrap --second-stage
    sudo sbuild-createchroot --arch=${CHROOT_ARCH} --foreign --setup-only \
        ${VERSION} ${CHROOT_DIR}-${CHROOT_ARCH} ${MIRROR}

    # Create file with environment variables which will be used inside chrooted
    # environment
    echo "export ARCH=${ARCH}" > envvars.sh
    echo "export TRAVIS_BUILD_DIR=${TRAVIS_BUILD_DIR}" >> envvars.sh
    chmod a+x envvars.sh

    # Install dependencies inside chroot
    sudo chroot ${CHROOT_DIR}-${CHROOT_ARCH} apt-get -qq update
    sudo chroot ${CHROOT_DIR}-${CHROOT_ARCH} apt-get -qq --allow-unauthenticated install \
        -y ${GUEST_DEPENDENCIES}

    # Create build dir and copy travis build files to our chroot environment
    sudo mkdir -p ${CHROOT_DIR}-${CHROOT_ARCH}/${TRAVIS_BUILD_DIR}
    sudo rsync -avq ${TRAVIS_BUILD_DIR}/ ${CHROOT_DIR}-${CHROOT_ARCH}/${TRAVIS_BUILD_DIR}/

    # Indicate chroot environment has been set up
    sudo touch ${CHROOT_DIR}-${CHROOT_ARCH}/.chroot_is_done

    # Call ourselves again which will cause tests to run
    sudo chroot ${CHROOT_DIR}-${CHROOT_ARCH} bash -c "cd ${TRAVIS_BUILD_DIR} && ./.travis-ci.sh"
}

if [ -e "/.chroot_is_done" ]; then
  # We are inside ARM chroot
  echo "Running inside chrooted environment"

  . ./envvars.sh
else
  if [ "${ARCH}" = "arm" ]; then
    # ARM test run, need to set up chrooted environment first
    for CHROOT_ARCH in ${ARCHITECTURES}
    do
      echo "Setting up chrooted  ${CHROOT_ARCH} environment"
      setup_arm_chroot
    done
  fi
fi

echo "Running tests"
echo "Environment: $(uname -a)"
sudo apt-key adv --keyserver ${KEYSERVER} --recv-keys `expr substr ${REPO_KEY} 33 8`
echo "deb ${TOR_DEB_REPO} ${VERSION} main" | sudo tee -a ${APT_REPO_LIST}
sudo apt-get -qq update
${TEST_COMMAND} ${TESTING_PACKAGES}
