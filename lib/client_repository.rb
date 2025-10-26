# frozen_string_literal: true

require 'json'
require_relative 'models/client'
require_relative 'result'

# Repository for loading and accessing client data from JSON files.
# Implements port/adapter pattern to isolate data access.
#
# @example
#   repo = ClientRepository.new(file_path: 'data/clients.json')
#   result = repo.load_all
#   if result.success?
#     clients = result.value
#   else
#     puts result.error
#   end
class ClientRepository
  # Default path to clients data file
  DEFAULT_FILE_PATH = File.join(__dir__, '..', 'data', 'clients.json')

  attr_reader :file_path

  # Creates a new repository instance
  #
  # @param file_path [String] path to JSON file containing client data
  def initialize(file_path: DEFAULT_FILE_PATH)
    @file_path = file_path
  end

  # Loads all clients from the JSON file
  #
  # @return [Result::Success<Array<Models::Client>>] on success
  # @return [Result::Failure<String>] on file or parsing errors
  def load_all
    validate_file_exists!
    raw_data = read_file
    clients = parse_and_build_clients(raw_data)

    Result::Success.new(value: clients)
  rescue StandardError => e
    Result::Failure.new(error: e.message)
  end

  private

  def validate_file_exists!
    return if File.exist?(file_path)

    raise "File not found: #{file_path}"
  end

  def read_file
    File.read(file_path)
  rescue Errno::ENOENT => e
    raise "File not found: #{e.message}"
  rescue Errno::EACCES => e
    raise "Permission denied: #{e.message}"
  rescue StandardError => e
    raise "Error reading file: #{e.message}"
  end

  def parse_and_build_clients(raw_data)
    json_data = parse_json(raw_data)
    validate_array!(json_data)
    build_clients(json_data)
  end

  def parse_json(raw_data)
    JSON.parse(raw_data)
  rescue JSON::ParserError => e
    raise "Invalid JSON format: #{e.message}"
  end

  def validate_array!(data)
    raise 'JSON root must be an array' unless data.is_a?(Array)
  end

  def build_clients(data)
    data.map.with_index do |attributes, index|
      Models::Client.from_hash(attributes)
    rescue ArgumentError => e
      raise "Invalid client data at index #{index}: #{e.message}"
    end
  end
end
