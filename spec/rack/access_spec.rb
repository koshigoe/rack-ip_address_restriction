require 'spec_helper'
require 'rack/contrib/access'
require_relative 'shared_examples_for_rack_access'

describe Rack::Access do
  it_behaves_like 'Rack::Access'
end
