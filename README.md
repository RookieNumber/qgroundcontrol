<p align="center">
  <img src="markdown/frogslogo.svg" alt="Frogs Logo" width="200">
</p>

<p align="center">
  <img src="markdown/release.svg" alt="release" width="100">
</p>

Frogs ground control built on top of QgroundControl version 5.0.6!

---

### _What you do need before building Frogs ground control_

-   _QT Version_: QT Version 6 (6.8.3).
-   _Build Tools_: Cmake 3.30.5, Ninja 1.12.1.
-   _Window Setup_: MSVC 2022 64-bit.
-   _Android Setup_: JDK17 is required for the latest updated versions. NDK Version: 25.1.8937393 You can confirm it is being used by reviewing the project setting: Projects > Manage Kits > Devices > Android (tab) > Android Settings > JDK location.
-   _GStreamer_: Download the gstreamer framework from here: http://gstreamer.freedesktop.org/data/pkg/windows. Supported version is 1.22.12. QGC may work with newer version, but it is untested.

    You need two packages:

    gstreamer-1.0-devel-msvc-x86_64-1.22.12.msi
    gstreamer-1.0-msvc-x86_64-1.22.12.msi
    Make sure you select "Complete" installation instead of "Typical" installation during the install process.

    The following environment variables can be used to configure the GStreamer installation path: GSTREAMER_1_0_ROOT_X86_64 GSTREAMER_1_0_ROOT_MSVC_X86_64 GSTREAMER_1_0_ROOT_MINGW_X86_64.
