# encoding: utf-8
require File.expand_path("../../spec_helper", __FILE__)

describe Babosa::Transliterator::Macedonian do

  let(:t) { described_class.instance }
  it_behaves_like "a cyrillic transliterator"

end
