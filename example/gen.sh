#!/usr/bin/env bash
FB=${HOME}/fvm/versions/3.7.0/bin/flutter

$FB pub run build_runner clean

$FB pub run build_runner build --delete-conflicting-outputs