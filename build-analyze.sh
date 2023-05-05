#!/bin/bash

if [ ! -d "$HOME"/.sonar ]; then

  git fetch --unshallow

  # Prerequisites
  export SONAR_SCANNER_VERSION="4.8"
  mkdir "$HOME"/.sonar
  
  # Download build-wrapper
  curl -sSLo "$HOME"/.sonar/build-wrapper-macosx-x86.zip https://sonarcloud.io/static/cpp/build-wrapper-macosx-x86.zip
  unzip -o "$HOME"/.sonar/build-wrapper-macosx-x86.zip -d "$HOME"/.sonar/
  export PATH="$HOME"/.sonar/build-wrapper-macosx-x86:$PATH
  
  # Download sonar-scanner
  curl -sSLo "$HOME"/.sonar/sonar-scanner.zip https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-$SONAR_SCANNER_VERSION-macosx.zip
  unzip -o "$HOME"/.sonar/sonar-scanner.zip -d "$HOME"/.sonar/
  export PATH="$HOME"/.sonar/sonar-scanner-$SONAR_SCANNER_VERSION-macosx/bin:$PATH

fi

# Run sonar scanner
sonar-scanner \
  -Dsonar.login="$SONAR_TOKEN"