# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

USE_RUBY="ruby32 ruby33"
RUBY_FAKEGEM_EXTRADOC="CHANGELOG.md README.md"
RUBY_FAKEGEM_GEMSPEC="${PN}.gemspec"

inherit ruby-fakegem

MY_PV="2025-03-11"
DESCRIPTION="Ruby FFI bindings for llhttp"
HOMEPAGE="https://github.com/bryanp/llhttp"
# Use -> ${MY_PV} in SRC_URI here to help spot forgotten MY_PV updates
# (pkgcheck will warn on matching checksums)
SRC_URI="https://github.com/bryanp/llhttp/archive/refs/tags/${MY_PV}.tar.gz -> llhttp-${MY_PV}.tar.gz"

LICENSE="MPL-2.0"
SLOT="$(ver_cut 1)/$(ver_cut 1-2)"
KEYWORDS="~amd64 ~arm ~arm64 ~hppa ~ppc ~ppc64 ~sparc ~x86"
IUSE="test"
RUBY_S="llhttp-${MY_PV}/ffi"

ruby_add_rdepend "=dev-ruby/ffi-compiler-1*"

ruby_add_bdepend "test? (
	dev-ruby/async-io
	dev-ruby/rspec:3
)"

DEPEND="test? ( net-misc/curl )"

all_ruby_prepare() {
	sed -i -e 's/gem "rake-compiler"//g' "Gemfile" || die
}

each_ruby_compile() {
	cd ext && "${RUBY}" -S rake || die
	local FFI_PLATFORM_NAME="$(${RUBY} --disable=did_you_mean -e "require 'ffi' ; p \"#{FFI::Platform::ARCH}-#{FFI::Platform::OS}\"" | tr -d "\"")"
	install -D "${FFI_PLATFORM_NAME}/libllhttp-ext.so" "../lib/${FFI_PLATFORM_NAME}/libllhttp-ext.so" || die
}

each_ruby_install() {
	each_fakegem_install
	ruby_fakegem_extensions_installed
}
