# frozen_string_literal: true

require_relative '../result'

module Queries
  # Query object for searching clients by partial name match.
  # Implements case-insensitive search against full_name field.
  #
  # @example
  #   query = Queries::SearchClients.new(clients: all_clients)
  #   result = query.call(search_term: 'john')
  #   result.value # => [client1, client2]
  class SearchClients
    # @param clients [Array<Models::Client>] collection to search
    def initialize(clients:)
      @clients = clients
    end

    # Executes the search query
    #
    # @param search_term [String] the term to search for
    # @return [Result::Success<Array<Models::Client>>] matching clients
    # @return [Result::Failure<String>] if search_term is invalid
    def call(search_term:)
      validate_search_term!(search_term)

      normalized_term = normalize(search_term)
      matches = find_matches(normalized_term)

      Result::Success.new(value: matches)
    rescue ArgumentError => e
      Result::Failure.new(error: e.message)
    end

    private

    attr_reader :clients

    def validate_search_term!(term)
      raise ArgumentError, 'search_term cannot be nil' if term.nil?
      raise ArgumentError, 'search_term must be a string' unless term.is_a?(String)
      raise ArgumentError, 'search_term cannot be empty' if term.strip.empty?
    end

    def normalize(string)
      string.strip.downcase
    end

    def find_matches(normalized_term)
      clients.select do |client|
        normalized_name = normalize(client.full_name)
        normalized_name.include?(normalized_term)
      end
    end
  end
end
