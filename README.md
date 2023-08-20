# Attempting a Serde Bitwise Reproduction.

```
podman build . -t serde-bits --no-cache | tee build_log.txt
cid=$(podman create serde-bits)
podman cp $cid:/serde/precompiled/serde_derive/serde_derive-x86_64-unknown-linux-gnu ./from_podman
diffoscope --html diff1.html ./from_podman ./serde_derive-1.0.183/serde_derive-x86_64-unknown-linux-gnu
```

## Misc Commands

```
$ curl -L# https://crates.io/api/v1/crates/serde_derive/1.0.183/download | tar xz
$ readelf -p .comment ./serde_derive-1.0.183/serde_derive-x86_64-unknown-linux-gnu 

String dump of section '.comment':
  [     0]  GCC: (GNU) 9.4.0
  [    11]  rustc version 1.73.0-nightly (f3623871c 2023-08-06)
$ sha256sum ./from_podman ./serde_derive-1.0.183/serde_derive-x86_64-unknown-linux-gnu
a88f7722eafbaaeecce8b649540f7fc2b88eb9acada2455b6c8caca2f7af6749  ./from_podman
13579639363426dff17ddacd76d4bdf149663a4a7904095f5b0fd865a9ed01c9  ./serde_derive-1.0.183/serde_derive-x86_64-unknown-linux-gnu
```