FROM ghcr.io/dkakunsi/lab/ops:1.2

## JAVA AND MAVEN SETUP
# Set JAVA_HOME dynamically based on architecture
RUN bash -c "source ${SDKMAN_DIR}/bin/sdkman-init.sh && \
    sdk install java 25-tem && \
    sdk default java 25-tem"

ENV JAVA_HOME="${SDKMAN_DIR}/candidates/java/current"
ENV PATH="${JAVA_HOME}/bin:${PATH}"

# Install Maven
RUN bash -c "source ${SDKMAN_DIR}/bin/sdkman-init.sh && \
    sdk install maven 3.9.12 && \
    sdk default maven 3.9.12"

ENV MAVEN_HOME="${SDKMAN_DIR}/candidates/maven/current"
ENV PATH="${MAVEN_HOME}/bin:${PATH}"

# Default shell to bash
SHELL ["/bin/bash", "-c"]

