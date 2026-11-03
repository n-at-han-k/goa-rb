# frozen_string_literal: true

# Released under the Apache License, Version 2.0.
# Copyright, 2026, by General Intelligence Systems.

require "goa"

describe Goa do
  it "defines the namespace from the typelib" do
    # Not an arbitrary number: it is the point of the loader. A hand-written
    # binding exposes what someone got round to wrapping; this exposes what
    # Goa-1.0.typelib has, which is a little over a hundred constants -- an
    # interface, a proxy and a skeleton for each of the dozen-odd account
    # services. A drop to single digits means the loader half-ran.
    expect(Goa.constants.size).to be > 80
  end

  it "defines the classes a caller actually reaches for" do
    # The client, the three things it hands back, and one service interface.
    expect(Goa.const_defined?(:Client)).to be == true
    expect(Goa.const_defined?(:Object)).to be == true
    expect(Goa.const_defined?(:Account)).to be == true
    expect(Goa.const_defined?(:Manager)).to be == true
    expect(Goa.const_defined?(:OAuth2Based)).to be == true
  end

  it "loads classes that descend from GObject" do
    # The typelib describes GObject types, so what the loader produces should
    # be GLib::Object subclasses rather than bare Ruby classes.
    expect(Goa::Client.ancestors).to be(:include?, GLib::Object)
    expect(Goa::AccountSkeleton.ancestors).to be(:include?, GLib::Object)
  end

  it "maps instance methods onto a class, not just constants" do
    # A loader that registered the types but defined no methods would satisfy
    # every assertion above, so this is the one that catches a half-loaded
    # namespace. Goa::Client has around 25 methods of its own.
    methods = Goa::Client.instance_methods - Object.instance_methods

    expect(methods.size).to be > 10
    expect(methods).to be(:include?, :accounts)
    expect(methods).to be(:include?, :lookup_by_id)
  end

  it "maps the D-Bus interfaces onto modules with their methods" do
    # Account and Manager are interfaces rather than classes, and the loader
    # defines them as modules. Getting that wrong loses every account property.
    expect(Goa::Account).to be_a(Module)
    expect(Goa::Account.instance_methods).to be(:include?, :presentation_identity)
    expect(Goa::Manager.instance_methods).to be(:include?, :call_add_account_sync)
  end

  it "constructs a skeleton and round-trips a GObject property" do
    # The real thing without needing a session bus or the goa daemon:
    # Goa::Client.new would talk D-Bus, which CI has no business doing, but a
    # skeleton is an ordinary GObject. If properties did not land, this is nil.
    account = Goa::AccountSkeleton.new

    expect(account).to be_a(Goa::AccountSkeleton)
    expect(account.presentation_identity).to be_nil

    account.presentation_identity = "someone@example.com"

    expect(account.presentation_identity).to be == "someone@example.com"
  end

  it "exposes the library's own version constants" do
    # Enums and constants come through the same load, and these say which
    # gnome-online-accounts the typelib on GI_TYPELIB_PATH came from.
    expect(Goa::MAJOR_VERSION).to be_a(Integer)
    expect(Goa::MAJOR_VERSION).to be >= 3
  end
end
