/// Legacy export for the refactored home page implementation.
///
/// Some parts of the application – particularly older routes or feature
/// experiments – still import `package:navy_encrypt/pages/home_page.dart` out of
/// habit.  The actual, fully featured home page that supports picking files from
/// Google Drive, OneDrive and the local file system on iOS, Android and Windows
/// now lives under `pages/home/`.  Re-exporting the modern implementation from
/// this file keeps those imports working without duplicating widgets that might
/// fall out of sync across platforms.
export 'home/home_page.dart';
