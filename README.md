# offline-lab-archive-keyring

GnuPG archive key and apt sources for the [Offline Lab](https://496.be) package repository at `repo.496.be`.
Installing this package configures your system to trust and use the Offline Lab repository:

```
deb https://repo.496.be stable main
```

## Installing

```sh
apt install offline-lab-archive-keyring
```

If you are bootstrapping a fresh system before this package is available:

```sh
curl -fsSL https://repo.496.be/repo.gpg \
  | sudo tee /usr/share/keyrings/offline-lab-archive-keyring.asc > /dev/null

sudo tee /etc/apt/sources.list.d/offline-lab.sources <<EOF
Types: deb
URIs: https://repo.496.be
Suites: stable
Components: main
Signed-By: /usr/share/keyrings/offline-lab-archive-keyring.asc
EOF

sudo apt update
```

## Development

### Requirements

- macOS with Docker and `git-buildpackage` installed
- `brew install git-buildpackage`

### First time setup

Fetch the current signing key from the repository:

```sh
./bin/refresh-key.sh
```

Commit the result. Only needs to be re-run after a key rotation.

### Building

```sh
./bin/build.sh
```

This will:

1. Update `debian/changelog` from git commits using `gbp dch`
2. Build the `.deb` inside a `debian:trixie` Docker container
3. Place the result in `dist/`
4. Clean up build artifacts

### Publishing

Publishing is handled automatically by GitHub Actions on every push to `main`. Add the following secrets to the repository:

| Secret | Description |
|---|---|
| `APTLY_PASS` | HTTP basic auth password for the aptly API |
