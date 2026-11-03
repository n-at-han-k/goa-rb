# frozen_string_literal: true

# Released under the Apache License, Version 2.0.
# Copyright, 2026, by General Intelligence Systems.

# The gem is published as `goa-rb`, because `goa` was already taken on
# RubyGems by an unrelated gem. The library it provides is `Goa`, which is the
# GObject Introspection namespace `Goa-1.0.typelib` declares, so the code lives
# in lib/goa.rb and lib/goa/ where the namespace says it should.
#
# This file exists so that `require` works under the gem's own name, and so
# that gem_kit can find the gem's deprecations: RubyGems treats a dash as a
# directory separator, so gem_kit infers `goa/rb` from `goa-rb` and warns
# "deprecations will not be detected" when it cannot require something for the
# gem. Either spelling works, and both load the same thing.
require_relative "goa"
