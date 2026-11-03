# frozen_string_literal: true

# Released under the Apache License, Version 2.0.
# Copyright, 2026, by General Intelligence Systems.

# RubyGems treats a dash in a gem name as a directory separator, so the
# conventional entry point for `goa-rb` is `goa/rb`. gem_kit infers that and
# requires it to find the gem's deprecations; without this file it warns
#
#   could not require "goa/rb" (cannot load such file -- goa/rb);
#   deprecations will not be detected
#
# and a declared deprecation would stop gating releases. `gem kit` runs as a
# RubyGems plugin and never loads the project's Rakefile, so
# GemKit::Release.configure cannot reach it -- satisfying the convention is
# what works.
#
# The real entry point stays `goa-rb`, and the namespace stays Goa.
require_relative "../goa-rb"
