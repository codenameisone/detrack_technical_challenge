# frozen_string_literal: true

require_relative '../../lib/queries/search_clients'
require_relative '../../lib/models/client'

RSpec.describe Queries::SearchClients do
  subject(:query) { described_class.new(clients: clients) }

  let(:clients) do
    [
      Models::Client.new(id: 1, full_name: 'John Doe', email: 'john@example.com'),
      Models::Client.new(id: 2, full_name: 'Jane Smith', email: 'jane@example.com'),
      Models::Client.new(id: 3, full_name: 'John Smith', email: 'johnsmith@example.com'),
      Models::Client.new(id: 4, full_name: 'Bob Johnson', email: 'bob@example.com')
    ]
  end

  describe '#call' do
    context 'with valid search term' do
      it 'finds exact matches' do
        result = query.call(search_term: 'John Doe')
        expect(result).to be_success
        expect(result.value.size).to eq(1)
        expect(result.value.first.full_name).to eq('John Doe')
      end

      it 'finds partial matches' do
        result = query.call(search_term: 'John')
        expect(result).to be_success
        expect(result.value.size).to eq(3)
        expect(result.value.map(&:full_name)).to contain_exactly('John Doe', 'John Smith', 'Bob Johnson')
      end

      it 'is case-insensitive' do
        result = query.call(search_term: 'JOHN')
        expect(result).to be_success
        expect(result.value.size).to eq(3)
      end

      it 'handles lowercase search' do
        result = query.call(search_term: 'smith')
        expect(result).to be_success
        expect(result.value.size).to eq(2)
        expect(result.value.map(&:full_name)).to contain_exactly('Jane Smith', 'John Smith')
      end

      it 'handles mixed case search' do
        result = query.call(search_term: 'SmItH')
        expect(result).to be_success
        expect(result.value.size).to eq(2)
      end

      it 'strips whitespace from search term' do
        result = query.call(search_term: '  John  ')
        expect(result).to be_success
        expect(result.value.size).to eq(3)
      end

      it 'returns empty array when no matches found' do
        result = query.call(search_term: 'Nonexistent')
        expect(result).to be_success
        expect(result.value).to eq([])
      end
    end

    context 'with invalid search term' do
      it 'returns failure for nil search_term' do
        result = query.call(search_term: nil)
        expect(result).to be_failure
        expect(result.error).to match(/cannot be nil/)
      end

      it 'returns failure for non-string search_term' do
        result = query.call(search_term: 123)
        expect(result).to be_failure
        expect(result.error).to match(/must be a string/)
      end

      it 'returns failure for empty search_term' do
        result = query.call(search_term: '')
        expect(result).to be_failure
        expect(result.error).to match(/cannot be empty/)
      end

      it 'returns failure for whitespace-only search_term' do
        result = query.call(search_term: '   ')
        expect(result).to be_failure
        expect(result.error).to match(/cannot be empty/)
      end
    end

    context 'with empty client list' do
      subject(:query) { described_class.new(clients: []) }

      it 'returns empty array' do
        result = query.call(search_term: 'test')
        expect(result).to be_success
        expect(result.value).to eq([])
      end
    end

    context 'with special characters in names' do
      let(:clients) do
        [
          Models::Client.new(id: 1, full_name: "O'Brien", email: 'obrien@example.com'),
          Models::Client.new(id: 2, full_name: 'Test-User', email: 'test@example.com')
        ]
      end

      it 'finds names with apostrophes' do
        result = query.call(search_term: "o'brien")
        expect(result).to be_success
        expect(result.value.size).to eq(1)
      end

      it 'finds names with hyphens' do
        result = query.call(search_term: 'test-user')
        expect(result).to be_success
        expect(result.value.size).to eq(1)
      end
    end
  end
end
