# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake xdg-utils

DESCRIPTION="CD and DVD image access library"
HOMEPAGE="https://cdemu.sourceforge.io"
SRC_URI="https://download.sourceforge.net/cdemu/libmirage/${P}.tar.xz"

LICENSE="GPL-2+"
SLOT="0/11"
KEYWORDS="amd64 x86"
IUSE="doc +introspection"

DEPEND="
	>=app-arch/bzip2-1:=
	>=app-arch/xz-utils-5:=
	>=dev-libs/glib-2.38:2
	>=media-libs/libsamplerate-0.1:=
	>=media-libs/libsndfile-1.0:=
	sys-libs/zlib:=
	introspection? ( >=dev-libs/gobject-introspection-1.30 )
"
RDEPEND="
	${DEPEND}
"
BDEPEND="
	dev-util/desktop-file-utils
	dev-util/intltool
	sys-devel/gettext
	virtual/pkgconfig
	doc? ( dev-util/gtk-doc )
	introspection? ( >=dev-libs/gobject-introspection-1.30 )
"

DOCS=( AUTHORS README )

src_configure() {
	local mycmakeargs=(
		-DGTKDOC_ENABLED="$(usex doc)"
		-DINTROSPECTION_ENABLED="$(usex introspection)"
		-DPOST_INSTALL_HOOKS=OFF # avoid sandbox violation, #487304
	)
	cmake_src_configure
}

pkg_postinst() {
	xdg_mimeinfo_database_update
}

pkg_postrm() {
	xdg_mimeinfo_database_update
}
