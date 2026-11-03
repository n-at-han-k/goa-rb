# goa

Ruby bindings for [GNOME Online Accounts](https://gitlab.gnome.org/GNOME/gnome-online-accounts):
the accounts the user has already configured in GNOME Settings, and the
credentials that go with them.

```ruby
require "goa"

client = Goa::Client.new   # talks to the session's goa daemon over D-Bus

client.accounts.each do |object|
  account = object.account

  puts "#{account.provider_name}: #{account.presentation_identity}"

  # The service interfaces are per-account and may be absent.
  oauth2 = object.oauth2_based
  access_token, = oauth2.call_get_access_token_sync if oauth2
end
```

`Goa::Client.new` needs a session bus with the GNOME Online Accounts daemon on
it, so it is for a desktop application rather than a server or a CI job.
Everything else — the `*Skeleton` classes, the interfaces, the constants — is
ordinary GObject and works anywhere.

## How this works, and what it costs to install

The library ships a GObject Introspection typelib — `Goa-1.0.typelib` —
describing every class, method, property and signal it has. `Goa::Loader`,
about twenty lines, hands that to ruby-gnome's
`GObjectIntrospection::Loader`, which defines the Ruby classes from it at
`require` time. You get the whole library rather than the subset somebody got
round to wrapping by hand, and it does not drift when the library gains API.

Be precise about what that does and does not buy you at install time.
`gem install goa` **does** compile C, because `gobject-introspection` and
`glib2` are themselves native extensions built against glib, so a compiler and
glib's development headers are needed. What this gem adds on top of that is
nothing: it has no extension and no build step of its own, and those two
extensions are the ones every ruby-gnome application already has, since `gtk4`
depends on them. If you are writing a Ruby GTK app, goa costs you no build step
you were not already paying.

This is how [ruby-gnome](https://github.com/ruby-gnome/ruby-gnome) itself ships
gtksourceview5, libsecret and the rest.

## The one thing you must install

The typelib is a C-library artefact, so it belongs to your distribution and
this gem cannot install it:

| | |
|---|---|
| Debian / Ubuntu | `gir1.2-goa-1.0` (and `libglib2.0-dev` for the gem's own dependencies) |
| Fedora | `gnome-online-accounts` (and `glib2-devel`) |
| Arch | `gnome-online-accounts` |
| nix | `pkgs.gnome-online-accounts` |

If the typelib is not in the default search path, point `GI_TYPELIB_PATH` at
the directory holding `Goa-1.0.typelib`. The dev shell in `flake.nix` does
this, for the typelib and for the `GLib`/`GObject`/`Gio` typelibs it depends
on.

**One trap worth knowing.** The typelib must come from the same glib build as
the `gobject-introspection` gem. Mixing two registers GIO twice in one process
and fails with `cannot register existing type 'GTlsCertificate'`. Under nix,
take both from one nixpkgs — and note that glib's typelibs live in its `out`
output, not the default one.

## Development

```sh
nix develop
bin/test
```

CI runs `nix develop --command bin/test`: the same shell, deliberately, because
the environment is the hard part of a GI binding and CI checking a different
one than people develop in is how an environment bug reaches a release.

## Licence

Apache-2.0. GNOME Online Accounts itself is LGPL-2.1-or-later; this gem links
nothing and copies no code from it — it reads a description of it at runtime.
See NOTICE.
