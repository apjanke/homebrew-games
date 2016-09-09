class GoGui < Formula
  desc "GUI for playing Go over Go Text Protocol"
  homepage "http://gogui.sourceforge.net"
  url "https://downloads.sourceforge.net/project/gogui/gogui/1.4.9/gogui-1.4.9.zip"
  sha256 "32684b756ab5b6bf9412c035594eddfd1be9250de12d348c3501850857b86662"
  revision 1

  head do
    url "git://git.code.sf.net/p/gogui/code"

    depends_on "docbook" => :build
    depends_on "docbook-xsl" => :build
  end

  depends_on :ant => :build
  depends_on :java => "1.6+"

  resource "quaqua" do
    url "http://www.randelshofer.ch/quaqua/files/quaqua-5.4.1.nested.zip"
    sha256 "a01ce8bcce6e81941ca928468e728e76e0773957c685c349474ee04f3be677d6"
  end

  # Disable Linux-specific install steps
  # See https://github.com/Homebrew/homebrew-games/pull/598
  # and https://sourceforge.net/p/gogui/bugs/43/
  patch :DATA

  def install
    inreplace "build.xml", "/Developer/Tools/SetFile", "/usr/bin/SetFile"
    if build.head?
      resource("quaqua").stage do
        system "unzip", "quaqua-*.zip"
        (buildpath/"lib").install "Quaqua/dist/quaqua.jar"
      end
      args = %W[
        -Ddocbook-xsl.dir=#{Formula["docbook-xsl"].prefix}/docbook-xsl
        -Ddocbook.dtd-4.2=#{Formula["docbook"].prefix}/docbook/xml/4.2
      ]
    else
      args = %W[
        -Ddoc-uptodate=true
      ]
    end
    # Use the Linux-style install instead of gogui.app to avoid Apple Java 1.6
    # dependency. https://sourceforge.net/p/gogui/bugs/42/
    system "./install.sh", "-p", prefix, "-j", "/usr"
  end

  test do
    assert_equal "GoGui #{version}", shell_output("#{bin}/gogui -version").chomp
  end
end

__END__
diff --git a/install.sh b/install.sh
index 848b399..3851420 100755
--- a/install.sh
+++ b/install.sh
@@ -94,6 +94,8 @@ install -m 644 config/gogui.desktop "$PREFIX/share/applications"
 install -d "$PREFIX/share/mime/packages"
 install -m 644 config/gogui-mime.xml "$PREFIX/share/mime/packages"
 
+if [ `uname` == 'linux' ]; then
+
 # Install Gnome 2 thumbnailer
 
 install -d "$SYSCONFDIR/gconf/schemas"
@@ -126,3 +128,5 @@ update-desktop-database "$PREFIX/share/applications" >/dev/null 2>&1
 # MIME database
 
 update-mime-database "$PREFIX/share/mime" >/dev/null 2>&1
+
+fi
