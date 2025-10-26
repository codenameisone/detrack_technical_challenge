# frozen_string_literal: true

require_relative '../result'

module Queries
  # Query object for finding clients with duplicate email addresses.
  # Groups clients by normalized email (case-insensitive, trimmed) and returns
  # only those with multiple entries.
  #
  # @example
  #   query = Queries::FindDuplicates.new(clients: all_clients)
  #   result = query.call
  #   result.value # => { 'duplicate@example.com' => [client1, client2] }
  class FindDuplicates
    # @param clients [Array<Models::Client>] collection to analyze
    def initialize(clients:)
      @clients = clients
    end

    # Finds all duplicate email addresses
    #
    # @return [Result::Success<Hash<String, Array<Models::Client>>>]
    #   Hash mapping email addresses to arrays of clients with that email.
    #   Only includes emails that appear more than once.
    def call
      grouped = group_by_email
      duplicates = filter_duplicates(grouped)

      Result::Success.new(value: duplicates)
    end

    private

    attr_reader :clients

    def normalize_email(email)
      email.downcase.strip
    end

    def group_by_email
      clients.group_by { |client| normalize_email(client.email) }
    end

    def filter_duplicates(grouped)
      grouped.select { |_email, client_list| client_list.size > 1 }
    end
  end
end
