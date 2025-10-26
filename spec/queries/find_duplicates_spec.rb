# frozen_string_literal: true

require_relative '../../lib/queries/find_duplicates'
require_relative '../../lib/models/client'

RSpec.describe Queries::FindDuplicates do
  describe '#call' do
    context 'with duplicate emails' do
      subject(:query) { described_class.new(clients: clients) }

      let(:clients) do
        [
          Models::Client.new(id: 1, full_name: 'John Doe', email: 'duplicate@example.com'),
          Models::Client.new(id: 2, full_name: 'Jane Smith', email: 'unique@example.com'),
          Models::Client.new(id: 3, full_name: 'Bob Jones', email: 'duplicate@example.com'),
          Models::Client.new(id: 4, full_name: 'Alice Wonder', email: 'another@example.com'),
          Models::Client.new(id: 5, full_name: 'Charlie Brown', email: 'another@example.com')
        ]
      end

      it 'returns success result' do
        result = query.call
        expect(result).to be_success
      end

      it 'finds all duplicate emails' do
        result = query.call
        expect(result.value.keys).to contain_exactly('duplicate@example.com', 'another@example.com')
      end

      it 'groups clients by duplicate email' do
        result = query.call
        duplicates = result.value

        expect(duplicates['duplicate@example.com'].size).to eq(2)
        expect(duplicates['duplicate@example.com'].map(&:id)).to contain_exactly(1, 3)
      end

      it 'includes all clients with same email' do
        result = query.call
        duplicates = result.value

        expect(duplicates['another@example.com'].size).to eq(2)
        expect(duplicates['another@example.com'].map(&:full_name))
          .to contain_exactly('Alice Wonder', 'Charlie Brown')
      end

      it 'does not include unique emails' do
        result = query.call
        expect(result.value.keys).not_to include('unique@example.com')
      end
    end

    context 'with no duplicates' do
      subject(:query) { described_class.new(clients: clients) }

      let(:clients) do
        [
          Models::Client.new(id: 1, full_name: 'John Doe', email: 'john@example.com'),
          Models::Client.new(id: 2, full_name: 'Jane Smith', email: 'jane@example.com'),
          Models::Client.new(id: 3, full_name: 'Bob Jones', email: 'bob@example.com')
        ]
      end

      it 'returns success with empty hash' do
        result = query.call
        expect(result).to be_success
        expect(result.value).to eq({})
      end
    end

    context 'with empty client list' do
      subject(:query) { described_class.new(clients: []) }

      it 'returns success with empty hash' do
        result = query.call
        expect(result).to be_success
        expect(result.value).to eq({})
      end
    end

    context 'with single client' do
      subject(:query) { described_class.new(clients: clients) }

      let(:clients) do
        [Models::Client.new(id: 1, full_name: 'John Doe', email: 'john@example.com')]
      end

      it 'returns empty hash' do
        result = query.call
        expect(result).to be_success
        expect(result.value).to eq({})
      end
    end

    context 'with three clients sharing same email' do
      subject(:query) { described_class.new(clients: clients) }

      let(:clients) do
        [
          Models::Client.new(id: 1, full_name: 'User One', email: 'shared@example.com'),
          Models::Client.new(id: 2, full_name: 'User Two', email: 'shared@example.com'),
          Models::Client.new(id: 3, full_name: 'User Three', email: 'shared@example.com')
        ]
      end

      it 'groups all three clients together' do
        result = query.call
        expect(result.value['shared@example.com'].size).to eq(3)
      end
    end

    context 'with mixed case emails' do
      subject(:query) { described_class.new(clients: clients) }

      let(:clients) do
        [
          Models::Client.new(id: 1, full_name: 'User One', email: 'Test@Example.com'),
          Models::Client.new(id: 2, full_name: 'User Two', email: 'test@example.com')
        ]
      end

      it 'treats emails as case-insensitive and finds duplicates' do
        result = query.call
        expect(result).to be_success
        expect(result.value.keys).to contain_exactly('test@example.com')
        expect(result.value['test@example.com'].size).to eq(2)
        expect(result.value['test@example.com'].map(&:id)).to contain_exactly(1, 2)
      end
    end

    context 'with emails containing whitespace' do
      subject(:query) { described_class.new(clients: clients) }

      let(:clients) do
        [
          Models::Client.new(id: 1, full_name: 'User One', email: ' test@example.com'),
          Models::Client.new(id: 2, full_name: 'User Two', email: 'test@example.com '),
          Models::Client.new(id: 3, full_name: 'User Three', email: 'test@example.com')
        ]
      end

      it 'strips whitespace and finds duplicates' do
        result = query.call
        expect(result).to be_success
        expect(result.value.keys).to contain_exactly('test@example.com')
        expect(result.value['test@example.com'].size).to eq(3)
        expect(result.value['test@example.com'].map(&:id)).to contain_exactly(1, 2, 3)
      end
    end
  end
end
