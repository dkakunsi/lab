FROM ghcr.io/dkakunsi/lab/ops:1.2

# -----------------------------
# JAVA + GRADLE (SDKMAN)
# -----------------------------
RUN bash -c "source ${SDKMAN_DIR}/bin/sdkman-init.sh && \
    sdk install java 21-tem && \
    sdk default java 21-tem"

ENV JAVA_HOME="${SDKMAN_DIR}/candidates/java/current"
ENV PATH="${JAVA_HOME}/bin:${PATH}"

RUN bash -c "source ${SDKMAN_DIR}/bin/sdkman-init.sh && \
    sdk install gradle 9.1.0 && \
    sdk default gradle 9.1.0"

ENV GRADLE_HOME="${SDKMAN_DIR}/candidates/gradle/current"
ENV PATH="${GRADLE_HOME}/bin:${PATH}"

# -----------------------------
# ANDROID + FLUTTER SETUP
# -----------------------------
ENV ANDROID_SDK_ROOT="${INSTALLATION_DIR}/android-sdk"
ENV FLUTTER_SDK_ROOT="${INSTALLATION_DIR}/flutter"
ENV FLUTTER_SDK_VERSION="3.27.1"

RUN mkdir -p ${ANDROID_SDK_ROOT} ${FLUTTER_SDK_ROOT}

ENV PATH="${PATH}:${FLUTTER_SDK_ROOT}/bin:${FLUTTER_SDK_ROOT}/bin/cache/dart-sdk/bin"
ENV PATH="${PATH}:${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin:${ANDROID_SDK_ROOT}/platform-tools"

ENV DEBIAN_FRONTEND=noninteractive

RUN git config --global --add safe.directory ${FLUTTER_SDK_ROOT}

# -----------------------------
# ANDROID COMMANDLINE TOOLS (multi-arch safe)
# -----------------------------
RUN mkdir -p ${ANDROID_SDK_ROOT}/cmdline-tools && \
    wget -O commandlinetools.zip \
      "https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip" && \
    unzip commandlinetools.zip -d ${ANDROID_SDK_ROOT}/cmdline-tools && \
    mv ${ANDROID_SDK_ROOT}/cmdline-tools/cmdline-tools \
       ${ANDROID_SDK_ROOT}/cmdline-tools/latest && \
    rm commandlinetools.zip && \
    yes | ${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin/sdkmanager --licenses

# -----------------------------
# INSTALL ANDROID PACKAGES (auto-arch)
# sdkmanager installs ARM64 or AMD64 automatically
# -----------------------------
RUN ${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin/sdkmanager \
      "platform-tools" \
      "platforms;android-36" \
      "build-tools;36.0.0" \
      "ndk;27.0.12077973"

# -----------------------------
# FLUTTER INSTALL (multi-arch)
# -----------------------------
RUN ARCH=$(dpkg --print-architecture) && \
    if [ "$ARCH" = "amd64" ]; then \
        FLUTTER_URL="https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_SDK_VERSION}-stable.tar.xz"; \
    elif [ "$ARCH" = "arm64" ]; then \
        FLUTTER_URL="https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_arm64_${FLUTTER_SDK_VERSION}-stable.tar.xz"; \
    else \
        echo "Unsupported architecture: $ARCH" && exit 1; \
    fi && \
    curl -L $FLUTTER_URL -o flutter.tar.xz && \
    tar xf flutter.tar.xz -C ${INSTALLATION_DIR} && \
    mv ${INSTALLATION_DIR}/flutter ${FLUTTER_SDK_ROOT} && \
    rm flutter.tar.xz && \
    flutter --disable-analytics && \
    flutter doctor -v

SHELL ["/bin/bash", "-c"]