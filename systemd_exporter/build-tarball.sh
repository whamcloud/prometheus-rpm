#!/usr/bin/env bash
set -euo pipefail

out_dir=$(cd "${1:?Usage: build-tarball.sh OUTPUT_DIR}" && pwd)
work_dir=$(mktemp -d)
trap 'rm -rf -- "$work_dir"' EXIT

repo=https://github.com/prometheus-community/systemd_exporter.git
revision=638533fd23cbc2debacbaab3fb8f23778814d222
export GOTOOLCHAIN=go1.27.4
export GOWORK=off

git clone --quiet --no-checkout "$repo" "$work_dir/src"
cd "$work_dir/src"
git checkout --quiet --detach "$revision"

# This revision already meets the requested x/crypto, x/oauth2, x/sys and
# x/text minimums. Update x/net and klauspost/compress beyond its module pins.
go get golang.org/x/net@v0.62.0 github.com/klauspost/compress@v1.20.2

version=$(<VERSION)
package="systemd_exporter-${version}.linux-amd64"
mkdir -p "$work_dir/$package"
CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -mod=readonly -trimpath -buildvcs=false \
    -ldflags "-X github.com/prometheus/common/version.Version=$version -X github.com/prometheus/common/version.Revision=$revision" \
    -o "$work_dir/$package/systemd_exporter" .
go version -m "$work_dir/$package/systemd_exporter"

tar -czf "$out_dir/$package.tar.gz" -C "$work_dir" "$package"
