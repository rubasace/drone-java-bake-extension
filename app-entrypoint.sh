#!/bin/sh

if [ -z "$JDK_JAVA_OPTIONS" ]; then
  INITIAL_RAM_PERCENTAGE="${INITIAL_RAM_PERCENTAGE:-50}"
  MAX_RAM_PERCENTAGE="${MAX_RAM_PERCENTAGE:-75}"
  MAX_JAVA_STACKTRACE_DEPTH="${MAX_JAVA_STACKTRACE_DEPTH:-15}"
  export JDK_JAVA_OPTIONS="-XX:+UseContainerSupport -XX:-OmitStackTraceInFastThrow -XX:InitialRAMPercentage=${INITIAL_RAM_PERCENTAGE} -XX:MaxRAMPercentage=${MAX_RAM_PERCENTAGE} -XX:MaxJavaStackTraceDepth=${MAX_JAVA_STACKTRACE_DEPTH} ${EXTRA_JAVA_OPTIONS}"
fi

exec java -cp @/app/jib-classpath-file @/app/jib-main-class-file