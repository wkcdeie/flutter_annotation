#!/usr/bin/env bash
FB=../.fvm/flutter_sdk/bin/dart

$FB run build_runner clean

$FB run build_runner build --delete-conflicting-outputs