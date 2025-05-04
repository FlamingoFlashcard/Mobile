default: run

run:
    flutter run --dart-define-from-file=.env

init:
    dart run ./bootstrap.dart

set shell := ["powershell.exe", "-c"]
