# frozen_string_literal: true

require 'spec_helper'

# Load the CLI class definition
load File.expand_path('../../bin/client_manager', __dir__)

RSpec.describe ClientManagerCLI, type: :integration do
  let(:cli) { described_class.new }

  describe '#search' do
    context 'with matching results' do
      it 'displays found clients with correct format' do
        output = capture_output do
          cli.options = { file: fixture_path('valid_clients.json') }
          cli.search('john')
        end

        expect(output[:stdout]).to include("Search results for 'john'")
        expect(output[:stdout]).to include('=' * 80)
        expect(output[:stdout]).to include('Found 2 client(s)')
        expect(output[:stdout]).to include('ID: 1')
        expect(output[:stdout]).to include('Name: John Doe')
        expect(output[:stdout]).to include('Email: john.doe@example.com')
        expect(output[:stdout]).to include('ID: 3')
        expect(output[:stdout]).to include('Name: Bob Johnson')
      end

      it 'performs case-insensitive search' do
        output = capture_output do
          cli.options = { file: fixture_path('valid_clients.json') }
          cli.search('SMITH')
        end

        expect(output[:stdout]).to include('Found 3 client(s)')
        expect(output[:stdout]).to include('Jane Smith')
        expect(output[:stdout]).to include('Alice Smith')
        expect(output[:stdout]).to include('Another Jane Smith')
      end

      it 'shows count of results' do
        output = capture_output do
          cli.options = { file: fixture_path('valid_clients.json') }
          cli.search('smith')
        end

        expect(output[:stdout]).to match(/Found \d+ client\(s\)/)
      end

      it 'searches partial matches' do
        output = capture_output do
          cli.options = { file: fixture_path('valid_clients.json') }
          cli.search('doe')
        end

        expect(output[:stdout]).to include('Found 1 client(s)')
        expect(output[:stdout]).to include('John Doe')
      end
    end

    context 'with no matches' do
      it 'displays "No clients found" message' do
        output = capture_output do
          cli.options = { file: fixture_path('valid_clients.json') }
          cli.search('xyz123nonexistent')
        end

        expect(output[:stdout]).to include('No clients found matching your search')
        expect(output[:stdout]).to include("Search results for 'xyz123nonexistent'")
      end
    end

    context 'with custom file' do
      it 'loads data from specified file path' do
        output = capture_output do
          cli.options = { file: fixture_path('no_duplicates.json') }
          cli.search('alice')
        end

        expect(output[:stdout]).to include('Alice Anderson')
        expect(output[:stdout]).to include('alice@unique.com')
      end

      it 'uses default file when no option provided' do
        output = capture_output do
          cli.options = {}
          cli.search('john')
        end

        # Should load from default data/clients.json
        expect(output[:stdout]).to include('Search results')
      end
    end

    context 'with empty dataset' do
      it 'displays no clients found message' do
        output = capture_output do
          cli.options = { file: fixture_path('empty_clients.json') }
          cli.search('anything')
        end

        expect(output[:stdout]).to include('No clients found matching your search')
      end
    end

    context 'with errors' do
      it 'exits with code 1 on invalid file path' do
        exit_code = catch(:exit_called) do
          stub_exit(cli)
          capture_output do
            cli.options = { file: 'nonexistent_file.json' }
            cli.search('john')
          end
        end

        expect(exit_code).to eq(1)
      end

      it 'displays error message for nonexistent file' do
        stub_exit(cli)
        output = capture_output do
          catch(:exit_called) do
            cli.options = { file: 'nonexistent_file.json' }
            cli.search('john')
          end
        end

        expect(output[:stderr]).to include('Error:')
        expect(output[:stderr]).to include('Failed to load clients')
      end

      it 'exits with code 1 on malformed JSON' do
        exit_code = catch(:exit_called) do
          stub_exit(cli)
          capture_output do
            cli.options = { file: fixture_path('invalid_json.json') }
            cli.search('john')
          end
        end

        expect(exit_code).to eq(1)
      end

      it 'displays error message for malformed JSON' do
        stub_exit(cli)
        output = capture_output do
          catch(:exit_called) do
            cli.options = { file: fixture_path('invalid_json.json') }
            cli.search('john')
          end
        end

        expect(output[:stderr]).to include('Error:')
        expect(output[:stderr]).to match(/Invalid JSON|parse/i)
      end

      it 'exits with code 1 on missing required fields' do
        exit_code = catch(:exit_called) do
          stub_exit(cli)
          capture_output do
            cli.options = { file: fixture_path('missing_fields.json') }
            cli.search('john')
          end
        end

        expect(exit_code).to eq(1)
      end

      it 'displays validation error for missing fields' do
        stub_exit(cli)
        output = capture_output do
          catch(:exit_called) do
            cli.options = { file: fixture_path('missing_fields.json') }
            cli.search('john')
          end
        end

        expect(output[:stderr]).to include('Error:')
      end

      it 'exits with code 1 on invalid data types' do
        exit_code = catch(:exit_called) do
          stub_exit(cli)
          capture_output do
            cli.options = { file: fixture_path('invalid_types.json') }
            cli.search('john')
          end
        end

        expect(exit_code).to eq(1)
      end
    end
  end

  describe '#duplicates' do
    context 'with duplicate emails' do
      it 'displays all clients sharing same email' do
        output = capture_output do
          cli.options = { file: fixture_path('valid_clients.json') }
          cli.duplicates
        end

        expect(output[:stdout]).to include('Duplicate Email Analysis')
        expect(output[:stdout]).to include('=' * 80)
        expect(output[:stdout]).to include('Found 1 duplicate email(s)')
        expect(output[:stdout]).to include('Email: jane.smith@example.com')
        expect(output[:stdout]).to include('2 occurrences')
        expect(output[:stdout]).to include('ID: 2, Name: Jane Smith')
        expect(output[:stdout]).to include('ID: 5, Name: Another Jane Smith')
      end

      it 'shows correct occurrence count' do
        output = capture_output do
          cli.options = { file: fixture_path('valid_clients.json') }
          cli.duplicates
        end

        expect(output[:stdout]).to match(/\(2 occurrences\)/)
      end

      it 'lists all clients with duplicate email' do
        output = capture_output do
          cli.options = { file: fixture_path('valid_clients.json') }
          cli.duplicates
        end

        jane_section = output[:stdout].match(/Email: jane\.smith@example\.com.*?(?=\n\n|\z)/m).to_s
        expect(jane_section).to include('Jane Smith')
        expect(jane_section).to include('Another Jane Smith')
      end
    end

    context 'with no duplicates' do
      it 'displays "No duplicate emails found" message' do
        output = capture_output do
          cli.options = { file: fixture_path('no_duplicates.json') }
          cli.duplicates
        end

        expect(output[:stdout]).to include('No duplicate emails found')
        expect(output[:stdout]).to include('Duplicate Email Analysis')
      end
    end

    context 'with custom file' do
      it 'loads data from specified file path' do
        output = capture_output do
          cli.options = { file: fixture_path('valid_clients.json') }
          cli.duplicates
        end

        expect(output[:stdout]).to include('jane.smith@example.com')
      end
    end

    context 'with empty dataset' do
      it 'displays no duplicates message' do
        output = capture_output do
          cli.options = { file: fixture_path('empty_clients.json') }
          cli.duplicates
        end

        expect(output[:stdout]).to include('No duplicate emails found')
      end
    end

    context 'with errors' do
      it 'exits with code 1 on invalid file path' do
        exit_code = catch(:exit_called) do
          stub_exit(cli)
          capture_output do
            cli.options = { file: 'nonexistent.json' }
            cli.duplicates
          end
        end

        expect(exit_code).to eq(1)
      end

      it 'displays error message for file errors' do
        stub_exit(cli)
        output = capture_output do
          catch(:exit_called) do
            cli.options = { file: 'does_not_exist.json' }
            cli.duplicates
          end
        end

        expect(output[:stderr]).to include('Error:')
        expect(output[:stderr]).to include('Failed to load clients')
      end

      it 'exits with code 1 on malformed JSON' do
        exit_code = catch(:exit_called) do
          stub_exit(cli)
          capture_output do
            cli.options = { file: fixture_path('invalid_json.json') }
            cli.duplicates
          end
        end

        expect(exit_code).to eq(1)
      end

      it 'exits with code 1 on missing required fields' do
        exit_code = catch(:exit_called) do
          stub_exit(cli)
          capture_output do
            cli.options = { file: fixture_path('missing_fields.json') }
            cli.duplicates
          end
        end

        expect(exit_code).to eq(1)
      end

      it 'exits with code 1 on invalid data types' do
        exit_code = catch(:exit_called) do
          stub_exit(cli)
          capture_output do
            cli.options = { file: fixture_path('invalid_types.json') }
            cli.duplicates
          end
        end

        expect(exit_code).to eq(1)
      end
    end
  end

  describe 'output formatting' do
    it 'includes separator lines in search results' do
      output = capture_output do
        cli.options = { file: fixture_path('valid_clients.json') }
        cli.search('john')
      end

      expect(output[:stdout]).to include('=' * 80)
    end

    it 'includes separator lines in duplicate results' do
      output = capture_output do
        cli.options = { file: fixture_path('valid_clients.json') }
        cli.duplicates
      end

      expect(output[:stdout]).to include('=' * 80)
    end

    it 'includes newlines between clients in search results' do
      output = capture_output do
        cli.options = { file: fixture_path('valid_clients.json') }
        cli.search('smith')
      end

      # Should have blank lines between client entries
      expect(output[:stdout]).to match(/Email:.*\n\n.*ID:/m)
    end
  end
end
