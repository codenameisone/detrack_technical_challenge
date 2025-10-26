# frozen_string_literal: true

require_relative '../../lib/models/client'

RSpec.describe Models::Client do
  describe '#initialize' do
    context 'with valid attributes' do
      subject(:client) do
        described_class.new(id: 1, full_name: 'John Doe', email: 'john@example.com')
      end

      it 'creates a client with correct attributes' do
        expect(client.id).to eq(1)
        expect(client.full_name).to eq('John Doe')
        expect(client.email).to eq('john@example.com')
      end

      it 'freezes the object' do
        expect(client).to be_frozen
      end
    end

    context 'with invalid id' do
      it 'raises ArgumentError for non-integer id' do
        expect do
          described_class.new(id: 'one', full_name: 'John Doe', email: 'john@example.com')
        end.to raise_error(ArgumentError, /id must be a positive integer/)
      end

      it 'raises ArgumentError for zero id' do
        expect do
          described_class.new(id: 0, full_name: 'John Doe', email: 'john@example.com')
        end.to raise_error(ArgumentError, /id must be a positive integer/)
      end

      it 'raises ArgumentError for negative id' do
        expect do
          described_class.new(id: -1, full_name: 'John Doe', email: 'john@example.com')
        end.to raise_error(ArgumentError, /id must be a positive integer/)
      end
    end

    context 'with invalid full_name' do
      it 'raises ArgumentError for non-string full_name' do
        expect do
          described_class.new(id: 1, full_name: 123, email: 'john@example.com')
        end.to raise_error(ArgumentError, /full_name must be a non-empty string/)
      end

      it 'raises ArgumentError for empty full_name' do
        expect do
          described_class.new(id: 1, full_name: '', email: 'john@example.com')
        end.to raise_error(ArgumentError, /full_name must be a non-empty string/)
      end

      it 'raises ArgumentError for whitespace-only full_name' do
        expect do
          described_class.new(id: 1, full_name: '   ', email: 'john@example.com')
        end.to raise_error(ArgumentError, /full_name must be a non-empty string/)
      end
    end

    context 'with invalid email' do
      it 'raises ArgumentError for non-string email' do
        expect do
          described_class.new(id: 1, full_name: 'John Doe', email: nil)
        end.to raise_error(ArgumentError, /email must be a non-empty string/)
      end

      it 'raises ArgumentError for empty email' do
        expect do
          described_class.new(id: 1, full_name: 'John Doe', email: '')
        end.to raise_error(ArgumentError, /email must be a non-empty string/)
      end
    end
  end

  describe '.from_hash' do
    it 'creates a client from a hash with symbol keys' do
      hash = { id: 1, full_name: 'Jane Smith', email: 'jane@example.com' }
      client = described_class.from_hash(hash)

      expect(client.id).to eq(1)
      expect(client.full_name).to eq('Jane Smith')
      expect(client.email).to eq('jane@example.com')
    end

    it 'creates a client from a hash with string keys' do
      hash = { 'id' => 2, 'full_name' => 'Bob Jones', 'email' => 'bob@example.com' }
      client = described_class.from_hash(hash)

      expect(client.id).to eq(2)
      expect(client.full_name).to eq('Bob Jones')
      expect(client.email).to eq('bob@example.com')
    end

    it 'raises ArgumentError for missing keys' do
      hash = { id: 1, full_name: 'Test' }
      expect { described_class.from_hash(hash) }.to raise_error(ArgumentError)
    end
  end

  describe '#to_s' do
    it 'returns a formatted string representation' do
      client = described_class.new(id: 42, full_name: 'Alice Wonder', email: 'alice@example.com')
      expect(client.to_s).to eq('Client #42: Alice Wonder (alice@example.com)')
    end
  end

  describe '#==' do
    let(:client1) { described_class.new(id: 1, full_name: 'Test User', email: 'test@example.com') }
    let(:client2) { described_class.new(id: 1, full_name: 'Test User', email: 'test@example.com') }
    let(:client3) { described_class.new(id: 2, full_name: 'Test User', email: 'test@example.com') }

    it 'returns true for clients with same attributes' do
      expect(client1).to eq(client2)
    end

    it 'returns false for clients with different attributes' do
      expect(client1).not_to eq(client3)
    end

    it 'returns false when comparing with non-Client object' do
      expect(client1).not_to eq('not a client')
    end
  end

  describe '#hash' do
    it 'returns same hash for clients with same attributes' do
      client1 = described_class.new(id: 1, full_name: 'Test', email: 'test@example.com')
      client2 = described_class.new(id: 1, full_name: 'Test', email: 'test@example.com')

      expect(client1.hash).to eq(client2.hash)
    end
  end
end
