require 'spec_helper'
require_relative 'shared_examples_for_rack_access'

describe Rack::IpAddressRestriction do
  it 'has a version number' do
    expect(Rack::IpAddressRestriction::VERSION).not_to be nil
  end

  it_behaves_like 'Rack::Access'
end
