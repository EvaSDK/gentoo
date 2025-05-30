# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake llvm prefix

LLVM_MAX_SLOT=17

if [[ ${PV} == *9999 ]] ; then
	EGIT_REPO_URI="https://github.com/RadeonOpenCompute/ROCm-CompilerSupport/"
	inherit git-r3
	S="${WORKDIR}/${P}/lib/comgr"
else
	SRC_URI="https://github.com/RadeonOpenCompute/ROCm-CompilerSupport/archive/rocm-${PV}.tar.gz -> ${P}.tar.gz"
	S="${WORKDIR}/ROCm-CompilerSupport-rocm-${PV}/lib/comgr"
	KEYWORDS="~amd64"
fi

IUSE="test"
RESTRICT="!test? ( test )"

PATCHES=(
	"${FILESDIR}/${PN}-5.1.3-rocm-path.patch"
	"${FILESDIR}/0001-Specify-clang-exe-path-in-Driver-Creation.patch"
	"${FILESDIR}/0001-Find-CLANG_RESOURCE_DIR-using-clang-print-resource-d.patch"
	"${FILESDIR}/${PN}-5.7.0-optional.patch"
	"${FILESDIR}/${PN}-5.7.0-lld.patch"
	"${FILESDIR}/${PN}-5.7.0-disassembly.patch"
	"${FILESDIR}/${PN}-5.7.0-metadata.patch"
	"${FILESDIR}/${PN}-5.7.0-symbolizer.patch"
	"${FILESDIR}/${PN}-5.7.1-fix-tests.patch"
	"${FILESDIR}/${PN}-5.7.1-correct-license-install-dir.patch"
)

DESCRIPTION="Radeon Open Compute Code Object Manager"
HOMEPAGE="https://github.com/RadeonOpenCompute/ROCm-CompilerSupport"
LICENSE="MIT"
SLOT="0/$(ver_cut 1-2)"

RDEPEND="
	>=dev-libs/rocm-device-libs-${PV}
	<dev-libs/rocm-device-libs-6
	llvm-core/clang:${LLVM_MAX_SLOT}=
	llvm-core/clang-runtime:=
	llvm-core/lld:${LLVM_MAX_SLOT}="
DEPEND="${RDEPEND}"

CMAKE_BUILD_TYPE=Release

src_prepare() {
	sed '/sys::path::append(HIPPath/s,"hip","",' -i src/comgr-env.cpp || die
	sed "/return LLVMPath;/s,LLVMPath,llvm::SmallString<128>(\"$(get_llvm_prefix ${LLVM_MAX_SLOT})\")," -i src/comgr-env.cpp || die
	eapply $(prefixify_ro "${FILESDIR}"/${PN}-5.0-rocm_path.patch)
	eapply $(prefixify_ro "${FILESDIR}"/${PN}-5.7.1-fix-tests-rocm-path.patch)
	cmake_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-DLLVM_DIR="$(get_llvm_prefix ${LLVM_MAX_SLOT})"
		-DCMAKE_STRIP=""  # disable stripping defined at lib/comgr/CMakeLists.txt:58
		-DBUILD_TESTING=$(usex test ON OFF)
	)
	cmake_src_configure
}
