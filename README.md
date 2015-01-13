# Sharemind SDK build repository (build-sdk.git)

## Quick start guide

To quickly build everything handled by this repository (including the
dependencies), use something like this:

```bash
cd /path/to/this/repository
echo 'SET(Thing_SKIP "")' > config.local
mkdir b
cd b
cmake ..
make
```

After this, everything should already be installed in the prefix/ directory
under /path/to/this/repository/.
