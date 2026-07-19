# Custom Caddy build: official image + TransIP DNS module for DNS-01 wildcard certs.
#
# The stock `caddy` image ships NO DNS provider plugins, so wildcard (DNS-01)
# issuance is impossible without rebuilding. This adds caddy-dns/transip.
#
# Caddy is a BOOTSTRAP stack (hand-managed, outside the doco-cd/Renovate loop),
# so nothing auto-bumps this image -- you own the version by hand.
#
# Pin >= 2.11.4: (1) 2.10+ is where a managed wildcard cert is auto-served for the
# explicit subdomain blocks (so they stop minting individual per-host certs);
# (2) 2.11.4 patches the path/host matcher auth-bypass CVEs (CVE-2026-27585..589)
# that are directly relevant to your path-based Authelia bypasses (/api, /opds).
ARG CADDY_VERSION=2.11.4

FROM caddy:${CADDY_VERSION}-builder AS builder
# NOTE: no @version on the module. caddy-dns/transip is tagged v2.0.3 but its
# module path has no /v2 suffix, which violates Go semantic-import-versioning --
# `...transip@v2.0.3` fails with "major version must be compatible: should be
# v0 or v1, not v2". The bare path resolves the default-branch pseudo-version
# (identical code), which is how caddy-dns modules are meant to be referenced.
# Reproducibility comes from the GHCR image digest pin in compose, not this tag.
RUN xcaddy build \
    --with github.com/caddy-dns/transip

FROM caddy:${CADDY_VERSION}
COPY --from=builder /usr/bin/caddy /usr/bin/caddy
