# Maintainer Note: THIS FORMULA IS GOING TO BREAK WHEN HOMEBREW_SANDBOX BECOMES MANDATORY
# https://github.com/Homebrew/homebrew-versions/pull/774

class Postgis20 < Formula
  desc "Adds support for geographic objects to PostgreSQL"
  homepage "http://postgis.net"
  url "http://download.osgeo.org/postgis/source/postgis-2.0.7.tar.gz"
  sha256 "35877fd5b591202941c2ae0a6f3fd84b0856649712f760375f17d9903c4c922a"

  keg_only "This formula conflicts with PostGIS in Homebrew/homebrew."

  def pour_bottle?
    # Postgres extensions must live in the Postgres prefix, which precludes
    # bottling: https://github.com/Homebrew/homebrew/issues/10247
    # Overcoming this will likely require changes in Postgres itself.
    false
  end

  option "with-gui", "Build shp2pgsql-gui in addition to command line tools"

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build
  depends_on "gpp" => :build
  depends_on "postgresql92"
  depends_on "proj"
  depends_on "geos"
  depends_on "gtk+" if build.with? "gui"

  # For GeoJSON and raster handling
  depends_on "gdal"
  depends_on "json-c"

  # Force GPP to be used when pre-processing SQL files. See:
  # http://trac.osgeo.org/postgis/ticket/1694
  patch :DATA

  def install
    # Follow the PostgreSQL linked keg back to the active Postgres installation
    # as it is common for people to avoid upgrading Postgres.
    postgres_realpath = Formula["postgresql92"].opt_prefix.realpath

    ENV.deparallelize

    args = [
      "--disable-dependency-tracking",
      # Can't use --prefix, PostGIS disrespects it and flat-out refuses to
      # accept it with 2.0.
      "--with-projdir=#{HOMEBREW_PREFIX}",
      "--with-jsondir=#{Formula["json-c"].opt_prefix}",
      # This is against Homebrew guidelines, but we have to do it as the
      # PostGIS plugin libraries can only be properly inserted into Homebrew's
      # Postgresql keg.
      "--with-pgconfig=#{postgres_realpath}/bin/pg_config",
      # Unfortunately, NLS support causes all kinds of headaches because
      # PostGIS gets all of it's compiler flags from the PGXS makefiles. This
      # makes it nigh impossible to tell the buildsystem where our keg-only
      # gettext installations are.
      "--disable-nls",
    ]

    args << "--with-gui" if build.with? "gui"

    system "./autogen.sh"
    system "./configure", *args
    system "make"

    # PostGIS includes the PGXS makefiles and so will install __everything__
    # into the Postgres keg instead of the PostGIS keg. Unfortunately, some
    # things have to be inside the Postgres keg in order to be function. So, we
    # install everything to a staging directory and manually move the pieces
    # into the appropriate prefixes.
    mkdir "stage"
    system "make", "install", "DESTDIR=#{buildpath}/stage"

    # Install PostGIS plugin libraries into the Postgres keg so that they can
    # be loaded and so PostGIS databases will continue to function even if
    # PostGIS is removed.
    (postgres_realpath/"lib").install Dir["stage/**/*.so"]

    # Install extension scripts to the Postgres keg.
    # `CREATE EXTENSION postgis;` won't work if these are located elsewhere.
    (postgres_realpath/"share/postgresql92/extension").install Dir["stage/**/extension/*"]

    bin.install Dir["stage/**/bin/*"]
    lib.install Dir["stage/**/lib/*"]
    include.install Dir["stage/**/include/*"]

    # Stand-alone SQL files will be installed the share folder
    (share/"postgis").install Dir["stage/**/contrib/postgis-2.0/*"]

    # Extension scripts
    bin.install %w[
      utils/create_undef.pl
      utils/postgis_proc_upgrade.pl
      utils/postgis_restore.pl
      utils/profile_intersects.pl
      utils/test_estimation.pl
      utils/test_geography_estimation.pl
      utils/test_geography_joinestimation.pl
      utils/test_joinestimation.pl
    ]

    man1.install Dir["doc/**/*.1"]
  end

  def caveats;
    pg = Formula["postgresql92"].opt_prefix
    <<-EOS.undent
      To create a spatially-enabled database, see the documentation:
        http://postgis.refractions.net/documentation/manual-2.0/postgis_installation.html#create_new_db_extensions
      and to upgrade your existing spatial databases, see here:
        http://postgis.refractions.net/documentation/manual-2.0/postgis_installation.html#upgrading

      PostGIS SQL scripts installed to:
        #{HOMEBREW_PREFIX}/share/postgis
      PostGIS plugin libraries installed to:
        #{pg}/lib
      PostGIS extension modules installed to:
        #{pg}/share/postgresql/extension
      EOS
  end
end

__END__
Force usage of GPP as the SQL pre-processor as Clang chokes and fix json-c link error

diff --git a/configure.ac b/configure.ac
index 68d9240..8514041 100644
--- a/configure.ac
+++ b/configure.ac
@@ -31,17 +31,8 @@ AC_SUBST([ANT])
 dnl
 dnl SQL Preprocessor
 dnl
-AC_PATH_PROG([CPPBIN], [cpp], [])
-if test "x$CPPBIN" != "x"; then
-  SQLPP="${CPPBIN} -traditional-cpp -P"
-else
-  AC_PATH_PROG([GPP], [gpp_], [])
-  if test "x$GPP" != "x"; then
-    SQLPP="${GPP} -C -s \'" dnl Use better string support
-  else
-    SQLPP="${CPP} -traditional-cpp"
-  fi
-fi
+AC_PATH_PROG([GPP], [gpp], [])
+SQLPP="${GPP} -C -s \'" dnl Use better string support
 AC_SUBST([SQLPP])

 dnl
