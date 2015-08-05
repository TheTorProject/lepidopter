#!/bin/bash
# Source: http://www.tomaz.me/2013/12/02/running-travis-ci-tests-on-arm.html
# Based on a test script from avsm/ocaml repo https://github.com/avsm/ocaml

# APT Packages to test
TESTING_PACKAGES="tor tor-geoipdb"

# Tor Debian repository variables
TOR_DEB_REPO="http://deb.torproject.org/torproject.org"
REPO_KEY="A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89"
KEYSERVER="hkp://pool.sks-keyservers.net"
APT_REPO_LIST="/etc/apt/sources.list.d/tor.list"

# Chroot specific variables
CHROOT_DIR=/tmp/$RANDOM
MIRROR="http://http.debian.net/debian/"
VERSION=$ENV_VERSION
PROPOSED_UPDATES_VERSION="tor-nightly-master-${VERSION}"

# Debian package dependencies for the chrooted environment
GUEST_DEPENDENCIES="build-essential git m4 sudo python wget"

# Command used to run the tests
TEST_COMMAND="sudo apt-get install -q -y"

function setup_arm_chroot {
    # Create chrooted environment
    sudo mkdir ${CHROOT_DIR}-${CHROOT_ARCH}
    sudo debootstrap --foreign --include=fakeroot,build-essential \
        --arch=${CHROOT_ARCH} ${VERSION} ${CHROOT_DIR}-${CHROOT_ARCH} ${MIRROR}
    sudo cp /usr/bin/qemu-arm-static ${CHROOT_DIR}-${CHROOT_ARCH}/usr/bin/
    sudo chroot ${CHROOT_DIR}-${CHROOT_ARCH} ./debootstrap/debootstrap --second-stage
    sudo sbuild-createchroot --arch=${CHROOT_ARCH} --foreign --setup-only \
        ${VERSION} ${CHROOT_DIR}-${CHROOT_ARCH} ${MIRROR}

    # Create file with environment variables which will be used inside chrooted
    # environment
    echo "export ARCH=${ARCH}" > envvars.sh
    echo "export TRAVIS_BUILD_DIR=${TRAVIS_BUILD_DIR}" >> envvars.sh
    echo "export VERSION=${ENV_VERSION}" >> envvars.sh
    chmod a+x envvars.sh

    # Install dependencies inside chroot
    sudo chroot ${CHROOT_DIR}-${CHROOT_ARCH} apt-get -qq update
    sudo chroot ${CHROOT_DIR}-${CHROOT_ARCH} apt-get -qq install \
        -y ${GUEST_DEPENDENCIES}

    # Create build dir and copy travis build files to our chroot environment
    sudo mkdir -p ${CHROOT_DIR}-${CHROOT_ARCH}/${TRAVIS_BUILD_DIR}
    sudo rsync -avq ${TRAVIS_BUILD_DIR}/ ${CHROOT_DIR}-${CHROOT_ARCH}/${TRAVIS_BUILD_DIR}/

    # Indicate chroot environment has been set up
    sudo touch ${CHROOT_DIR}-${CHROOT_ARCH}/.chroot_is_done

    # Call ourselves again which will cause tests to run
    sudo chroot ${CHROOT_DIR}-${CHROOT_ARCH} bash -c "cd ${TRAVIS_BUILD_DIR} &&
        ./.travis-ci-test-install-tor-packages-proposed-updates-repo.sh"
}

if [ -e "/.chroot_is_done" ]; then
  # We are inside ARM chroot
  echo "Running inside chrooted environment"

  . ./envvars.sh
echo "Running tests"
echo "Environment: $(uname -a)"
sudo apt-key adv --keyserver ${KEYSERVER} --recv-keys `expr substr ${REPO_KEY} 33 8`
echo "deb ${TOR_DEB_REPO} ${VERSION} main" | sudo tee -a ${APT_REPO_LIST}
echo "deb ${TOR_DEB_REPO} ${PROPOSED_UPDATES_VERSION} main" |
sudo tee -a ${APT_REPO_LIST}
sudo apt-get -qq update
${TEST_COMMAND} ${TESTING_PACKAGES}
echo "End of tests for: $(uname -a)"
dpkg -l ${TESTING_PACKAGES}
else
  if [ "${ARCH}" = "arm" ]; then
    # ARM test run, need to set up chrooted environment first
      echo "Setting up chrooted  ${CHROOT_ARCH} environment"
      setup_arm_chroot
  fi
fi

