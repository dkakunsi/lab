FROM ghcr.io/dkakunsi/lab/ops:1.1

# Install Gradle
RUN bash -c "source ${SDKMAN_DIR}/bin/sdkman-init.sh && \
    sdk install gradle 9.1.0 && \
    sdk default gradle 9.1.0"

ENV GRADLE_HOME="${SDKMAN_DIR}/candidates/gradle/current"
ENV PATH="${GRADLE_HOME}/bin:${PATH}"

## FLUTTER SETUP
# Set environment variables
ENV ANDROID_SDK_ROOT="${INSTALLATION_DIR}/android-sdk"
ENV FLUTTER_SDK_ROOT="${INSTALLATION_DIR}/flutter"
ENV FLUTTER_SDK_VERSION=3.27.1-stable

RUN mkdir -p ${ANDROID_SDK_ROOT} && \
    mkdir -p ${FLUTTER_SDK_ROOT}

# Include flutter and android tools in path
ENV PATH="${PATH}:${FLUTTER_SDK_ROOT}/bin:${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin:${ANDROID_SDK_ROOT}/platform-tools"

# Enable noninteractive installation
ENV DEBIAN_FRONTEND=noninteractive

# Add flutter to safe directory in git
RUN git config --global --add safe.directory ${FLUTTER_SDK_ROOT}

# Download and install Android Command Line Tools
# Accept Android SDK licenses and install necessary components
# Install Flutter SDK using Git (works for all architectures)
# Disable Flutter telemetry
RUN mkdir -p ${ANDROID_SDK_ROOT}/cmdline-tools && \
    wget -O commandlinetools.zip "https://dl.google.com/android/repository/commandlinetools-linux-8512546_latest.zip" && \
    unzip commandlinetools.zip -d ${ANDROID_SDK_ROOT}/cmdline-tools && \
    mv ${ANDROID_SDK_ROOT}/cmdline-tools/cmdline-tools ${ANDROID_SDK_ROOT}/cmdline-tools/latest && \
    rm commandlinetools.zip && \
    yes | ${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin/sdkmanager --licenses && \
    ${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin/sdkmanager "platform-tools" "platforms;android-36" "build-tools;36.0.0" "ndk;27.0.12077973" && \
    git clone https://github.com/flutter/flutter.git -b stable ${FLUTTER_SDK_ROOT} && \
    flutter --disable-analytics

# Default shell to bash
SHELL ["/bin/bash", "-c"]

