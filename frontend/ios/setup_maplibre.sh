#!/bin/bash
# Script to download MapLibre and MapLibreAnnotationExtension source for local podspecs

set -e

cd "$(dirname "$0")"
LOCAL_PODS_DIR="local_pods"
MAPLIBRE_REPO="https://github.com/maplibre/maplibre-native.git"
MAPLIBRE_TAG="ios-v5.12.0-pre.1"
ANNOTATION_REPO="https://github.com/m0nac0/maplibre-annotation-extension.git"
ANNOTATION_BRANCH="master"

echo "Setting up MapLibre dependencies for local podspecs..."

# Create local_pods directory if it doesn't exist
mkdir -p "$LOCAL_PODS_DIR"

# Clone MapLibre if not already cloned
if [ ! -d "$LOCAL_PODS_DIR/maplibre-native" ]; then
    echo "Cloning MapLibre repository..."
    git clone --depth 1 --branch "$MAPLIBRE_TAG" "$MAPLIBRE_REPO" "$LOCAL_PODS_DIR/maplibre-native"
    # Initialize and update submodules (needed for mapbox-base/geometry headers)
    cd "$LOCAL_PODS_DIR/maplibre-native"
    git submodule update --init --recursive --depth 1 vendor/mapbox-base 2>/dev/null || echo "Note: Submodule initialization may have failed, trying manual geometry.hpp clone..."
    cd - > /dev/null
else
    echo "MapLibre source already exists, skipping clone..."
    # Try to initialize submodules if they're missing
    if [ ! -d "$LOCAL_PODS_DIR/maplibre-native/vendor/mapbox-base/deps" ]; then
        echo "Initializing mapbox-base submodule..."
        cd "$LOCAL_PODS_DIR/maplibre-native"
        git submodule update --init --recursive --depth 1 vendor/mapbox-base 2>/dev/null || echo "Submodule init failed, will try manual geometry.hpp clone..."
        cd - > /dev/null
    fi
fi

# If mapbox-base submodule failed, manually clone geometry.hpp
if [ ! -d "$LOCAL_PODS_DIR/maplibre-native/vendor/mapbox-base/deps/geometry.hpp" ]; then
    echo "Cloning geometry.hpp directly..."
    mkdir -p "$LOCAL_PODS_DIR/maplibre-native/vendor/mapbox-base/deps"
    git clone --depth 1 https://github.com/mapbox/geometry.hpp.git "$LOCAL_PODS_DIR/maplibre-native/vendor/mapbox-base/deps/geometry.hpp" 2>/dev/null || echo "Warning: Could not clone geometry.hpp"
fi

# Clone MapLibreAnnotationExtension if not already cloned
if [ ! -d "$LOCAL_PODS_DIR/maplibre-annotation-extension" ]; then
    echo "Cloning MapLibreAnnotationExtension repository..."
    git clone --depth 1 --branch "$ANNOTATION_BRANCH" "$ANNOTATION_REPO" "$LOCAL_PODS_DIR/maplibre-annotation-extension"
else
    echo "MapLibreAnnotationExtension source already exists, skipping clone..."
fi

echo "All dependencies downloaded!"
echo "Now run: cd ios && pod install"
