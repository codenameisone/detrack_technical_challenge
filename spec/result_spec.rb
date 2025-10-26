# frozen_string_literal: true

require_relative '../lib/result'

RSpec.describe Result do
  describe Result::Success do
    subject(:success) { described_class.new(value: 'test_value') }

    it 'returns true for success?' do
      expect(success.success?).to be true
    end

    it 'returns false for failure?' do
      expect(success.failure?).to be false
    end

    it 'provides access to the value' do
      expect(success.value).to eq('test_value')
    end
  end

  describe Result::Failure do
    subject(:failure) { described_class.new(error: 'test_error') }

    it 'returns false for success?' do
      expect(failure.success?).to be false
    end

    it 'returns true for failure?' do
      expect(failure.failure?).to be true
    end

    it 'provides access to the error' do
      expect(failure.error).to eq('test_error')
    end
  end
end
