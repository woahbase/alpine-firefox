[![build status][251]][232] [![commit][255]][231] [![version:x86_64][256]][235] [![size:x86_64][257]][235] [![version:armhf][258]][236] [![size:armhf][259]][236]

## [Alpine-Firefox][234]
#### Container for Alpine Linux + Firefox
---

This [image][233] containerizes the [Firefox][135] browser.

Based on [Alpine Linux][131] from my [alpine-glibc][132] image with
the [s6][133] init system [overlayed][134] in it.

The image is tagged respectively for the following architectures,
* ~~**armhf**~~
* **x86_64** (retagged as the `latest` )

Also,
* **x86_64_esr** The extended support release version (retagged as `latest_esr` )
* **x86_64_esr_52** Firefox 52 (retagged as `latest_esr_52`, no updates )


~~**armhf** builds have embedded binfmt_misc support and contain the~~
~~[qemu-user-static][105] binary that allows for running it also inside~~
~~an x64 environment that has it.~~

---
#### Get the Image
---

Pull the image for your architecture it's already available from
Docker Hub.

```
# make pull
docker pull woahbase/alpine-firefox:x86_64
```

---
#### Run
---

If you want to run images for other architectures, you will need
to have binfmt support configured for your machine. [**multiarch**][104],
has made it easy for us containing that into a docker container.

```
# make regbinfmt
docker run --rm --privileged multiarch/qemu-user-static:register --reset
```

Without the above, you can still run the image that is made for your
architecture, e.g for an x86_64 machine..

Before you run..

* This image already has a user `alpine` configured to drop
  privileges to the passed `PUID`/`PGID` which is ideal if its
  used to run in non-root mode. That way you only need to specify
  the values at runtime and pass the `-u alpine` if need be. (run
  `id` in your terminal to see your own `PUID`/`PGID` values.)

* Uses `--cap-add=SYS_ADMIN` and optionally `--net=host`.

* If docker is not allowed to access the local X-server running on
  the host, make sure `DISPLAY` is exported and also, might need
  to run `xhost +local:docker`.

* To preserve data mount the `/home/alpine` dir in your local. By
  default mounts `$PWD/data`.

* Default directs audio to the pulseaudio client whether
  mounted locally from the host system, or a remote pulseaudio
  server, to use `/dev/snd` (or alsa), need to update
  `/home/alpine/.asoundrc`.

Running `make` starts the browser.

```
# make
docker run --rm -it \
  --name docker_firefox --hostname firefox \
  -e PGID=1000 -e PUID=1000 \
  -c 512 -m 2096m \
  -e DISPLAY=unix:0 \
  -e PULSE_SERVER=localhost \
  -v /usr/share/fonts:/usr/share/fonts:ro \
  -v data:/home/alpine \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  -v /var/run/dbus:/var/run/dbus \
  woahbase/alpine-firefox:x86_64
```

Stop the container with a timeout, (defaults to 2 seconds)

```
# make stop
docker stop -t 2 docker_firefox
```

Removes the container, (always better to stop it first and `-f`
only when needed most)

```
# make rm
docker rm -f docker_firefox
```

Restart the container with

```
# make restart
docker restart docker_firefox
```

---
#### Shell access
---

Get a shell inside a already running container,

```
# make debug
docker exec -it docker_firefox /bin/bash
```

set user or login as root,

```
# make rdebug
docker exec -u root -it docker_firefox /bin/bash
```

To check logs of a running container in real time

```
# make logs
docker logs -f docker_firefox
```

---
### Development
---

If you have the repository access, you can clone and
build the image yourself for your own system, and can push after.

---
#### Setup
---

Before you clone the [repo][231], you must have [Git][101], [GNU make][102],
and [Docker][103] setup on the machine.

```
git clone https://github.com/woahbase/alpine-firefox
cd alpine-firefox
```
You can always skip installing **make** but you will have to
type the whole docker commands then instead of using the sweet
make targets.

---
#### Build
---

You need to have binfmt_misc configured in your system to be able
to build images for other architectures.

Otherwise to locally build the image for your system.
[`ARCH` defaults to `x86_64`, need to be explicit when building
for other architectures.]

```
# make ARCH=x86_64 build
# sets up binfmt if not x86_64
docker build --rm --compress --force-rm \
  --no-cache=true --pull \
  -f ./Dockerfile_x86_64 \
  --build-arg DOCKERSRC=woahbase/alpine-glibc:x86_64 \
  --build-arg PGID=1000 \
  --build-arg PUID=1000 \
  -t woahbase/alpine-firefox:x86_64 \
  .
```

To check if its working..

```
# make ARCH=x86_64 test
docker run --rm -it \
  --name docker_firefox --hostname firefox \
  -e PGID=1000 -e PUID=1000 \
  woahbase/alpine-firefox:x86_64 \
  '--version'
```

And finally, if you have push access,

```
# make ARCH=x86_64 push
docker push woahbase/alpine-firefox:x86_64
```

---
### Maintenance
---

Sources at [Github][106]. Built at [Travis-CI.org][107] (armhf / x64 builds). Images at [Docker hub][108]. Metadata at [Microbadger][109].

Maintained by [WOAHBase][204].

[101]: https://git-scm.com
[102]: https://www.gnu.org/software/make/
[103]: https://www.docker.com
[104]: https://hub.docker.com/r/multiarch/qemu-user-static/
[105]: https://github.com/multiarch/qemu-user-static/releases/
[106]: https://github.com/
[107]: https://travis-ci.org/
[108]: https://hub.docker.com/
[109]: https://microbadger.com/

[131]: https://alpinelinux.org/
[132]: https://hub.docker.com/r/woahbase/alpine-glibc
[133]: https://skarnet.org/software/s6/
[134]: https://github.com/just-containers/s6-overlay
[135]: https://www.mozilla.org/en-US/firefox/

[201]: https://github.com/woahbase
[202]: https://travis-ci.org/woahbase/
[203]: https://hub.docker.com/u/woahbase
[204]: https://woahbase.online/

[231]: https://github.com/woahbase/alpine-firefox
[232]: https://travis-ci.org/woahbase/alpine-firefox
[233]: https://hub.docker.com/r/woahbase/alpine-firefox
[234]: https://woahbase.online/#/images/alpine-firefox
[235]: https://microbadger.com/images/woahbase/alpine-firefox:x86_64
[236]: https://microbadger.com/images/woahbase/alpine-firefox:armhf

[251]: https://travis-ci.org/woahbase/alpine-firefox.svg?branch=master

[255]: https://images.microbadger.com/badges/commit/woahbase/alpine-firefox.svg

[256]: https://images.microbadger.com/badges/version/woahbase/alpine-firefox:x86_64.svg
[257]: https://images.microbadger.com/badges/image/woahbase/alpine-firefox:x86_64.svg

[258]: https://images.microbadger.com/badges/version/woahbase/alpine-firefox:armhf.svg
[259]: https://images.microbadger.com/badges/image/woahbase/alpine-firefox:armhf.svg
