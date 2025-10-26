# frozen_string_literal: true

# Helper methods for CLI integration testing.
# Provides utilities for capturing output, stubbing exit calls, and managing fixtures.
module CLIHelper
  # Captures stdout and stderr during block execution
  #
  # @yield Block to execute while capturing output
  # @return [Hash] Hash with :stdout and :stderr keys containing captured output
  #
  # @example
  #   output = capture_output { puts "Hello" }
  #   output[:stdout] # => "Hello\n"
  def capture_output
    original_stdout = $stdout
    original_stderr = $stderr
    $stdout = StringIO.new
    $stderr = StringIO.new

    yield

    { stdout: $stdout.string, stderr: $stderr.string }
  ensure
    $stdout = original_stdout
    $stderr = original_stderr
  end

  # Returns the path to an integration test fixture file
  #
  # @param filename [String] Name of the fixture file
  # @return [String] Full path to the fixture file
  #
  # @example
  #   fixture_path('valid_clients.json')
  #   # => "/path/to/spec/integration/fixtures/valid_clients.json"
  def fixture_path(filename)
    File.join(__dir__, '..', 'integration', 'fixtures', filename)
  end

  # Stubs the exit method to capture exit code without terminating process
  # Use with catch(:exit_called) to capture the exit code
  #
  # @param cli_instance [ClientManagerCLI] The CLI instance to stub
  # @return [nil]
  #
  # @example
  #   cli = ClientManagerCLI.new
  #   exit_code = catch(:exit_called) do
  #     stub_exit(cli)
  #     cli.search('test')
  #   end
  #   exit_code # => 1
  def stub_exit(cli_instance)
    allow(cli_instance).to receive(:exit) do |code|
      throw :exit_called, code
    end
  end
end
