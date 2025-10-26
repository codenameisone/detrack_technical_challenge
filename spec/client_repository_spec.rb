# frozen_string_literal: true

require 'tempfile'
require 'json'
require_relative '../lib/client_repository'

RSpec.describe ClientRepository do
  describe '#load_all' do
    context 'with valid JSON file' do
      subject(:repository) { described_class.new(file_path: temp_file.path) }

      let(:valid_data) do
        [
          { id: 1, full_name: 'John Doe', email: 'john@example.com' },
          { id: 2, full_name: 'Jane Smith', email: 'jane@example.com' }
        ]
      end
      let(:temp_file) do
        file = Tempfile.new(['clients', '.json'])
        file.write(valid_data.to_json)
        file.rewind
        file
      end

      after { temp_file.close! }

      it 'returns a success result' do
        result = repository.load_all
        expect(result).to be_success
      end

      it 'loads all clients' do
        result = repository.load_all
        expect(result.value.size).to eq(2)
      end

      it 'creates Client objects with correct attributes' do
        result = repository.load_all
        client = result.value.first

        expect(client).to be_a(Models::Client)
        expect(client.id).to eq(1)
        expect(client.full_name).to eq('John Doe')
        expect(client.email).to eq('john@example.com')
      end
    end

    context 'when file does not exist' do
      subject(:repository) { described_class.new(file_path: '/nonexistent/file.json') }

      it 'returns a failure result' do
        result = repository.load_all
        expect(result).to be_failure
      end

      it 'includes error message' do
        result = repository.load_all
        expect(result.error).to match(/File not found/)
      end
    end

    context 'with invalid JSON' do
      subject(:repository) { described_class.new(file_path: temp_file.path) }

      let(:temp_file) do
        file = Tempfile.new(['invalid', '.json'])
        file.write('{ invalid json }')
        file.rewind
        file
      end

      after { temp_file.close! }

      it 'returns a failure result' do
        result = repository.load_all
        expect(result).to be_failure
      end

      it 'includes JSON parsing error message' do
        result = repository.load_all
        expect(result.error).to match(/Invalid JSON format/)
      end
    end

    context 'when JSON root is not an array' do
      subject(:repository) { described_class.new(file_path: temp_file.path) }

      let(:temp_file) do
        file = Tempfile.new(['object', '.json'])
        file.write({ id: 1, name: 'test' }.to_json)
        file.rewind
        file
      end

      after { temp_file.close! }

      it 'returns a failure result' do
        result = repository.load_all
        expect(result).to be_failure
      end

      it 'includes appropriate error message' do
        result = repository.load_all
        expect(result.error).to match(/JSON root must be an array/)
      end
    end

    context 'with invalid client data' do
      subject(:repository) { described_class.new(file_path: temp_file.path) }

      let(:invalid_data) do
        [
          { id: 1, full_name: 'Valid Client', email: 'valid@example.com' },
          { id: 'invalid', full_name: 'Invalid ID', email: 'test@example.com' }
        ]
      end
      let(:temp_file) do
        file = Tempfile.new(['invalid_client', '.json'])
        file.write(invalid_data.to_json)
        file.rewind
        file
      end

      after { temp_file.close! }

      it 'returns a failure result' do
        result = repository.load_all
        expect(result).to be_failure
      end

      it 'includes index and validation error' do
        result = repository.load_all
        expect(result.error).to match(/Invalid client data at index 1/)
        expect(result.error).to match(/id must be a positive integer/)
      end
    end

    context 'with missing required fields' do
      subject(:repository) { described_class.new(file_path: temp_file.path) }

      let(:incomplete_data) do
        [{ id: 1, full_name: 'John Doe' }]
      end
      let(:temp_file) do
        file = Tempfile.new(['incomplete', '.json'])
        file.write(incomplete_data.to_json)
        file.rewind
        file
      end

      after { temp_file.close! }

      it 'returns a failure result' do
        result = repository.load_all
        expect(result).to be_failure
      end
    end

    context 'with empty array' do
      subject(:repository) { described_class.new(file_path: temp_file.path) }

      let(:temp_file) do
        file = Tempfile.new(['empty', '.json'])
        file.write([].to_json)
        file.rewind
        file
      end

      after { temp_file.close! }

      it 'returns success with empty array' do
        result = repository.load_all
        expect(result).to be_success
        expect(result.value).to eq([])
      end
    end
  end

  describe '#initialize' do
    it 'uses default file path when not provided' do
      repository = described_class.new
      expect(repository.file_path).to include('data/clients.json')
    end

    it 'uses custom file path when provided' do
      repository = described_class.new(file_path: '/custom/path.json')
      expect(repository.file_path).to eq('/custom/path.json')
    end
  end
end
