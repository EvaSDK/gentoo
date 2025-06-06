# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake fcaps

DESCRIPTION="Fast network scanner designed for Internet-wide network surveys"
HOMEPAGE="https://zmap.io/"
SRC_URI="https://github.com/zmap/zmap/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="amd64 arm ~arm64 x86"

RDEPEND="
	dev-libs/gmp:=
	dev-libs/judy
	dev-util/gengetopt
	net-libs/libpcap
	dev-libs/json-c:=
"
DEPEND="${RDEPEND}"
BDEPEND="
	app-alternatives/lex
	dev-util/gengetopt
	dev-util/byacc
	virtual/pkgconfig
"

FILECAPS=( cap_net_raw=ep usr/sbin/zmap )

src_prepare() {
	sed \
		-e '/ggo/s:CMAKE_CURRENT_SOURCE_DIR}:CMAKE_BINARY_DIR}/src:g' \
		-i src/CMakeLists.txt || die
	cmake_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-DENABLE_DEVELOPMENT=OFF
		-DWITH_WERROR=OFF
	)

	cmake_src_configure
}
