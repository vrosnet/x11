# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/cairo/cairo-1.8.4.ebuild,v 1.1 2008/12/04 16:45:36 cardoe Exp $

inherit autotools eutils flag-o-matic git libtool

EGIT_REPO_URI="git://anongit.freedesktop.org/git/cairo"

DESCRIPTION="A vector graphics library with cross-device output support"
HOMEPAGE="http://cairographics.org/"

LICENSE="|| ( LGPL-2.1 MPL-1.1 )"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~sh ~sparc ~x86 ~x86-fbsd"
IUSE="cairoscript debug directfb doc glitz opengl sdl svg X xcb"

# Test causes a circular depend on gtk+... since gtk+ needs cairo but test needs gtk+ so we need to block it
RESTRICT="test"

RDEPEND="media-libs/fontconfig
	>=media-libs/freetype-2.1.9
	sys-libs/zlib
	media-libs/libpng
	>=x11-libs/pixman-0.12.0
	directfb? ( >=dev-libs/DirectFB-0.9.24 )
	glitz? ( >=media-libs/glitz-0.5.1 )
	svg? ( dev-libs/libxml2 )
	X? ( 	>=x11-libs/libXrender-0.6
		x11-libs/libXext
		x11-libs/libX11
		virtual/xft )
	xcb? (	>=x11-libs/libxcb-0.92
		x11-libs/xcb-util )
	sdl? ( >=media-libs/sdl-1.2 )"
#	test? (
#	pdf test
#	x11-libs/pango
#	>=x11-libs/gtk+-2.0
#	>=app-text/poppler-bindings-0.9.2
#	ps test
#	virtual/ghostscript
#	svg test
#	>=x11-libs/gtk+-2.0
#	>=gnome-base/librsvg-2.15.0

DEPEND="${RDEPEND}
	>=dev-util/pkgconfig-0.19
	doc? (	>=dev-util/gtk-doc-1.6
		~app-text/docbook-xml-dtd-4.2 )
	X? ( x11-proto/renderproto )
	xcb? ( x11-proto/xcb-proto )"

#pkg_setup() {
#	if ! built_with_use app-text/poppler-bindings gtk ; then
#		eerror 'poppler-bindings with gtk is required for the pdf backend'
#		die 'poppler-bindings built without gtk support'
#	fi
#}

src_unpack() {
	git_src_unpack

	# from autogen.sh
	> boilerplate/Makefile.am.features
	> src/Makefile.am.features
	touch ChangeLog

	eautoreconf
}

src_compile() {
	#gets rid of fbmmx.c inlining warnings
	append-flags -finline-limit=1200

	if use glitz && use opengl; then
		export glitz_LIBS=-lglitz-glx
	fi

	econf $(use_enable X xlib) $(use_enable doc gtk-doc) \
		$(use_enable directfb) $(use_enable xcb) \
		$(use_enable svg) $(use_enable glitz) $(use_enable X xlib-xrender) \
		$(use_enable cairoscript script) $(use_enable sdl) \
		$(use_enable debug test-surfaces) --enable-pdf  --enable-png \
		--enable-ft --enable-ps

	emake || die "compile failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "Installation failed"
	dodoc AUTHORS ChangeLog NEWS README
}
