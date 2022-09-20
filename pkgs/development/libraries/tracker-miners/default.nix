{ stdenv
, lib
, fetchurl
, fetchpatch
, asciidoc
, docbook-xsl-nons
, docbook_xml_dtd_45
, gettext
, itstool
, libxslt
, gexiv2, rawSupport ? true
, tracker
, meson
, ninja
, pkg-config
, vala
, wrapGAppsHook
#, bzip2
, dbus
#, evolution-data-server
, exempi, xmpSupport ? true
, giflib, gifSupport ? true
, glib
, gnome
, gst_all_1, withGstreamer ? true
, icu
, json-glib
, libcue, cueSupport ? true
, libexif, exifSupport ? true
, libgsf, gsfSupport ? true
, libgxps, xpsSupport ? true
, libiptcdata, iptcSupport ? true
, libjpeg, jpegSupport ? true
, libosinfo, isoSupport ? true
, libpng, pngSupport ? true
, libseccomp
#, libsoup
, libtiff, tiffSupport ? true
#, libuuid,
, util-linux
, libxml2, xmlSupport ? true
, networkmanager, withNetworkManager ? stdenv.isLinux
, poppler, pdfSupport ? true
, systemd, withSystemd ? stdenv.isLinux
#, taglib
, upower, withUpower ? stdenv.isLinux
, totem-pl-parser, playlistSupport ? true
, e2fsprogs

# libgrss is unmaintained and has no new releases since 2015, and an open
# security issue since then. Despite a patch now being available in nixpkgs,
# we're opting to be safe due to the general state of the project
, libgrss, rssSupport ? false
}:

stdenv.mkDerivation rec {
  pname = "tracker-miners";
  version = "3.3.1";

  src = fetchurl {
    url = "mirror://gnome/sources/${pname}/${lib.versions.majorMinor version}/${pname}-${version}.tar.xz";
    sha256 = "Pt3G0nLAKWn6TCwV360MSddtAh8aJ+xwi2m+gCU1PJQ=";
  };

  # TODO: remove me on 3.4.0
  patches = [
    (fetchpatch {
      url = "https://gitlab.gnome.org/GNOME/tracker-miners/-/commit/cc655ba0f95022cf35bc6d44cb5155788fee2e24.patch";
      sha256 = "sha256-a85ygtabpkruiDgKbseQxYbFIAQlVDhs3eWkbStJjKs=";
    })
    (fetchpatch {
      url = "https://gitlab.gnome.org/GNOME/tracker-miners/-/commit/9e613ceb37ec41fd1cd88c3d539e3ee03e8f6ba6.patch";
      sha256 = "sha256-ht7EfZztyl0st0Sv7H92Q37vwXY4T61GQm9WJ8IxTTg=";
    })
  ];

  nativeBuildInputs = [
    asciidoc
    docbook-xsl-nons
    docbook_xml_dtd_45
    gettext
    itstool
    libxslt
    meson
    ninja
    pkg-config
    vala
    wrapGAppsHook
  ];

  buildInputs = [
    #bzip2
    dbus
    glib
    totem-pl-parser
    tracker
    icu
    json-glib
    #libsoup
    #libuuid
    util-linux
    #taglib
  ] ++ lib.optional xmpSupport exempi
    ++ lib.optional gifSupport giflib
    ++ lib.optional rawSupport gexiv2
    ++ lib.optional cueSupport libcue
    ++ lib.optional exifSupport libexif
    ++ lib.optional gsfSupport libgsf
    ++ lib.optional xpsSupport libgxps
    ++ lib.optional iptcSupport libiptcdata
    ++ lib.optional jpegSupport libjpeg
    ++ lib.optional isoSupport libosinfo
    ++ lib.optional pngSupport libpng
    ++ lib.optional tiffSupport libtiff
    ++ lib.optional xmlSupport libxml2
    ++ lib.optional pdfSupport poppler
    ++ lib.optional playlistSupport totem-pl-parser
    ++ lib.optionals withGstreamer [
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    gst_all_1.gst-plugins-bad
    gst_all_1.gst-plugins-ugly
    gst_all_1.gstreamer
    gst_all_1.gst-libav
  ] ++ lib.optional stdenv.isLinux libseccomp
    ++ lib.optional withNetworkManager networkmanager
    ++ lib.optional withSystemd systemd
    ++ lib.optional withUpower upower
    ++ lib.optionals stdenv.isDarwin [
    e2fsprogs
  ];

  mesonFlags = [
    # TODO: tests do not like our sandbox
    "-Dfunctional_tests=false"
  ] ++ lib.optional (!rssSupport) "-Dminer_rss=false"
    ++ lib.optional (!cueSupport) "-Dcue=disabled"
    ++ lib.optional (!exifSupport) "-Dexif=disabled"
    ++ lib.optional (!gifSupport) "-Dgif=disabled"
    ++ lib.optional (!gsfSupport) "-Dgsf=disabled"
    ++ lib.optional (!iptcSupport) "-Diptc=disabled"
    ++ lib.optional (!isoSupport) "-Diso=disabled"
    ++ lib.optional (!jpegSupport) "-Djpeg=disabled"
    ++ lib.optional (!pdfSupport) "-Dpdf=disabled"
    ++ lib.optional (!playlistSupport) "-Dplaylist=disabled"
    ++ lib.optional (!pngSupport) "-Dpng=disabled"
    ++ lib.optional (!rawSupport) "-Draw=disabled"
    ++ lib.optional (!tiffSupport) "-Dtiff=disabled"
    ++ lib.optional (!xmlSupport) "-Dxml=disabled"
    ++ lib.optional (!xmpSupport) "-Dxmp=disabled"
    ++ lib.optional (!xpsSupport) "-Dxps=disabled"
    ++ lib.optional (!withNetworkManager) "-Dnetwork_manager=disabled"
    ++ lib.optional (!withSystemd) "-Dsystemd_user_services=false";

  postInstall = ''
    glib-compile-schemas "$out/share/glib-2.0/schemas"
  '';

  passthru = {
    updateScript = gnome.updateScript {
      packageName = pname;
    };
  };

  meta = with lib; {
    homepage = "https://wiki.gnome.org/Projects/Tracker";
    description = "Desktop-neutral user information store, search tool and indexer";
    maintainers = teams.gnome.members;
    license = licenses.gpl2Plus;
    platforms = platforms.unix;
  };
}
