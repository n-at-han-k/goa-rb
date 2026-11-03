# frozen_string_literal: true

# Released under the Apache License, Version 2.0.
# Copyright, 2026, by General Intelligence Systems.

module Goa
  # Defines everything in the Goa namespace from `Goa-1.0.typelib`.
  #
  # Modelled on ruby-gnome's own loaders -- see
  # gtksourceview5/lib/gtksourceview5/loader.rb for one that has to call the
  # library's init function first, and libsecret/lib/libsecret/loader.rb for
  # one that does not.
  #
  # The version string is the typelib's rather than the library's release
  # number, and the two often differ: this one is "1.0", from
  # `Goa-1.0.typelib`.
  class Loader < GObjectIntrospection::Loader
    def load
      self.version = "1.0"
      super("Goa")
    end

    private

    # There is no pre_load hook here, and that was checked rather than assumed:
    # `Goa-1.0.typelib` declares no `init` function at all --
    #
    #   repo.require("Goa", "1.0"); repo.find("Goa", "init")  # => nil
    #
    # so Goa is shaped like Secret rather than GtkSource, which has to call
    # `gtk_source_init` in pre_load before anything in it works. Calling an
    # init that does not exist would fail loudly; skipping one that does is the
    # bad case, because the namespace loads and then returns nulls.

    def post_load(repository, namespace)
      require_libraries
    end

    def require_libraries
      # Nothing yet. Hand-written Ruby that improves on what the typelib gives
      # -- an each that yields, a to_s, a keyword-argument constructor -- goes
      # in files required from here, which is the convention ruby-gnome uses
      # for exactly that purpose.
    end
  end
end
