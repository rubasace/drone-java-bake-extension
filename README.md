# Drone Java Bake Plugin #

[![Build Status](https://drone.nasvigo.com/api/badges/rubasace/drone-java-bake-extension/status.svg)](https://drone.nasvigo.com/rubasace/drone-java-bake-extension)

This Drone extension can be used to generate Docker images from Java compiled applications, as part of the CI process.

## How to use it

Use this extension on the bake stage of the `.drone.yml` manifest:

```yaml
- name: bake
  image: plugins/docker
  settings:
    username:
      from_secret: docker_user
    password:
      from_secret: docker_pass
    repo: registry.nasvigo.com/v2/twentyninetech/homefin
    registry: registry.nasvigo.com/v2
    tags: 1.0.0.${CI_BUILD_NUMBER}
    when:
      branch:
        - main
  ...
```

## How to deploy services baked with this image

This image provides a set of default JVM flags that are considered our standard, so there's no need to provide any parameter for the JVM, unless you need to tweak the JVM for that particular service (more on this bellow).

These flags can be checked in the `/entrypoint.sh` file (`DEFAULT_JDK_JAVA_OPTIONS` variable).

In order to deploy the applications, it's only needed to specify the Spring profile via the `SPRING_PROFILES_ACTIVE` environment variable:

```yaml
deploy:
  image: extensions/gke:stable
  ...
  container:
    env:
      SPRING_PROFILES_ACTIVE: stg
    ...
```

### How to customize the JVM options

By default, this extension provides some sensitive defaults for the JVM options that can be checked in the [app-entrypoint.sh file](app-entrypoint.sh) (check how the `JDK_JAVA_OPTIONS` is set).

Sometimes, we might want to tweak the default properties. The default options allow granular tweaking via specific environment variables. You can find all the possible options checking the entrypoint file or in the following table:

| JVM Option                   | ENV                         | Default Value | Description                                                                                                                                                                                              |
|------------------------------|-----------------------------|---------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `-XX:InitialRAMPercentage`   | `INITIAL_RAM_PERCENTAGE`    | `50`          | Value for `-XX:InitialRAMPercentage` option                                                                                                                                                              |
| `-XX:MaxRAMPercentage`       | `MAX_RAM_PERCENTAGE`        | `75`          | Value for `-XX:MaxRAMPercentage` option                                                                                                                                                                  |
| `-XX:MaxJavaStackTraceDepth` | `MAX_JAVA_STACKTRACE_DEPTH` | `15`          | Value for `-XX:MaxJavaStackTraceDepth ` option                                                                                                                                                           |
| Extra options                | `EXTRA_JAVA_OPTIONS`        | None          | Environment variable that can be set to specify any extra options for the JVM. They will be appended to the default ones. One common case for this property is specifying the path to some certificates. |

For example, we can keep all the defaults but change the `-XX:MaxRAMPercentage` option to `90`  by setting the `-XX:MaxRAMPercentage` property:

```yaml
deploy:
  image: extensions/gke:stable
  ...
  container:
    env:
      SPRING_PROFILES_ACTIVE: stg
      MAX_RAM_PERCENTAGE: 90
    ...
```

**As a last resort**, you can provide the JVM standard `JDK_JAVA_OPTIONS` environment variable indicating the entire set of options:

```yaml
deploy:
  image: extensions/gke:stable
  ...
  container:
    env:
      SPRING_PROFILES_ACTIVE: stg
      JDK_JAVA_OPTIONS: "-XX:+UseContainerSupport -XX:InitialRAMPercentage=50.0 -XX:MaxRAMPercentage=75.0 -XX:MaxMetaspaceSize=256M -XX:+DoEscapeAnalysis -XX:+UseBiasedLocking  -XX:+UseCompressedOops  -XX:+UseParallelGC -XX:+UseParallelOldGC -XX:-UseAdaptiveSizePolicy -XX:MaxTenuringThreshold=15 -XX:SurvivorRatio=12 -XX:MaxJavaStackTraceDepth=15"
    ...
```

> **Caution**: When you override the `JDK_JAVA_OPTIONS` environment variable, the default flags won't be provided. It's recommended to consider adding them manually, unless you know exactly what you are doing.