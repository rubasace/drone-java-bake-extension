# Drone Java Bake Plugin #

[![Build Status](https://drone.nasvigo.com/api/badges/rubasace/drone-java-bake-extension/status.svg)](https://drone.nasvigo.com/rubasace/drone-java-bake-extension)

This Drone plugin can be used to generate Docker images from Java compiled applications, as part of the CI process.

## Baking the application

Use this plugin on the bake stage of the `.drone.yml` manifest:

```yaml
- name: bake
  image: rubasace/drone-java-bake-plugin
  settings:
    container: myorg/test-app:latest
```

## Customizing the bake stage

The bake stage can be customized using the following settings:

| Setting             | Description                                                                                                                                                                                                                                                | Default Value |
|---------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|---------------|
| `container`         | The full name (including tag) of the container to be baked.                                                                                                                                                                                                |               |
| `container_uid`     | The UID of the process running the application within the container.                                                                                                                                                                                       | 1000          |
| `container_gid`     | The GID of the process running the application within the container.                                                                                                                                                                                       | 1000          |
| `registry_user`     | The username for the container registry, in case the `container` points to a private registry.                                                                                                                                                             |               |
| `registry_pass`     | The password for the container registry, in case the `container` points to a private registry.                                                                                                                                                             |               |
| `extra_jib_options` | Extra options that can be past to the jib command while baking the image. This can be useful for indicating where the `settings.xml` file is located or debugging failing builds, among others. It can be past as an array or as a space-separated string. |               |

> **Caution**: The `container` setting is mandatory and the bake process will fail if not provided.

An example with a private registry would look similar to this:

```yaml
- name: bake
  image: rubasace/drone-java-bake-plugin
  settings:
    container: privateregistry.com/myorg/test-app:1.0.0.${CI_BUILD_NUMBER}
    container_uid: 1829
    container_gid: 1829
    registry_user:
      from_secret: registry_user
    registry_pass:
      from_secret: registry_pass
    extra_jib_options:
      - "-s settings.xml"
      - "-X"
```

Or passing `extra_jib_options` as a space-separated string:

```yaml
- name: bake
  image: rubasace/drone-java-bake-plugin
  settings:
    container: privateregistry.com/myorg/test-app:1.0.0.${CI_BUILD_NUMBER}
    container_uid: 1829
    container_gid: 1829
    registry_user:
      from_secret: registry_user
    registry_pass:
      from_secret: registry_pass
    extra_jib_options: -s settings.xml -X
```

## Running the application

This image provides a set of default opinionated JVM flags that are considered best practices by the author, so the container can be run in Kubernetes/Docker (or any other container environment) without further configuration.

The JVM flags that are applied can be checked in the [app-entrypoint.sh file](app-entrypoint.sh) (check how the
`JDK_JAVA_OPTIONS` is set). Alternatively, the applied flags can be checked on the logs at the startup of the application. A line like the following can be found in the logs:

```text
NOTE: Picked up JDK_JAVA_OPTIONS: -XX:+UseContainerSupport -XX:InitialRAMPercentage=75 -XX:MaxRAMPercentage=75 -XX:MaxJavaStackTraceDepth=15
```

> It's important to note that the plugin uses `-XX:+UseContainerSupport` to allow the JVM to see the container's memory and CPU limits.

### How to customize the JVM options

Sometimes, we might want to tweak the default properties. The default options allow granular tweaking via specific environment variables. You can find all the possible options
checking the entrypoint file or in the following table:

| JVM Option                   | ENV                         | Default Value | Description                                                                                                                                                                                              |
|------------------------------|-----------------------------|---------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `-XX:InitialRAMPercentage`   | `INITIAL_RAM_PERCENTAGE`    | `50`          | Value for `-XX:InitialRAMPercentage` option                                                                                                                                                              |
| `-XX:MaxRAMPercentage`       | `MAX_RAM_PERCENTAGE`        | `75`          | Value for `-XX:MaxRAMPercentage` option                                                                                                                                                                  |
| `-XX:MaxJavaStackTraceDepth` | `MAX_JAVA_STACKTRACE_DEPTH` | `15`          | Value for `-XX:MaxJavaStackTraceDepth ` option                                                                                                                                                           |
| Extra options                | `EXTRA_JAVA_OPTIONS`        | None          | Environment variable that can be set to specify any extra options for the JVM. They will be appended to the default ones. One common case for this property is specifying the path to some certificates. |

For example, we can keep all the defaults but change the `-XX:MaxRAMPercentage` option to `90`  by setting the `-XX:MaxRAMPercentage` property on our Kubernetes deployment:

```yaml
image: myorg/myapp:1.0.0
env:
  - name: MAX_RAM_PERCENTAGE
    value: "90"
```

We can also add extra flags by setting the `EXTRA_JAVA_OPTIONS` environment variable:

```yaml
image: myorg/myapp:1.0.0
env:
- name: MAX_RAM_PERCENTAGE
  value: "90"
- name: EXTRA_JAVA_OPTIONS
  value: "-XX:+UnlockDiagnosticVMOptions -XX:+DebugNonSafepoints"
```

**As a last resort**, you can provide the JVM standard `JDK_JAVA_OPTIONS` environment variable indicating the entire set of options:

```yaml
image: myorg/myapp:1.0.0
env:
- name: JDK_JAVA_OPTIONS
  value: "-XX:+UseContainerSupport -XX:MaxRAMPercentage=75.0 -XX:+UseG1GC -XX:InitiatingHeapOccupancyPercent=40"
```

> **Caution**: When you override the `JDK_JAVA_OPTIONS` environment variable, the default flags won't be provided. It's recommended to consider adding them manually, unless you
> know exactly what you are doing.