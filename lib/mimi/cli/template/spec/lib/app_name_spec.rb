require 'spec_helper'

describe <%= module_name %> do
  it 'supposed to be a Module ' do
    expect(described_class).to be_a Module
  end

  it 'is a banana' do
    expect(described_class).to be 'a banana'
  end
end
