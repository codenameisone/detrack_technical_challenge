# frozen_string_literal: true

module Models
  # Immutable value object representing a client.
  # Validates all attributes at construction time.
  #
  # @example
  #   client = Models::Client.new(id: 1, full_name: 'John Doe', email: 'john@example.com')
  #   client.id         # => 1
  #   client.full_name  # => "John Doe"
  #   client.email      # => "john@example.com"
  class Client
    attr_reader :id, :full_name, :email

    # Creates a new Client instance with validation
    #
    # @param id [Integer] the client's unique identifier
    # @param full_name [String] the client's full name
    # @param email [String] the client's email address
    # @raise [ArgumentError] if any attribute is invalid
    def initialize(id:, full_name:, email:)
      validate_id!(id)
      validate_full_name!(full_name)
      validate_email!(email)

      @id = id
      @full_name = full_name
      @email = email

      freeze
    end

    # Creates a Client from a hash (e.g., parsed JSON)
    #
    # @param attributes [Hash] hash with string or symbol keys
    # @return [Models::Client]
    # @raise [ArgumentError] if required keys are missing or invalid
    def self.from_hash(attributes)
      symbolized = attributes.transform_keys(&:to_sym)

      new(
        id: symbolized[:id],
        full_name: symbolized[:full_name],
        email: symbolized[:email]
      )
    end

    # String representation for display
    #
    # @return [String]
    def to_s
      "Client ##{id}: #{full_name} (#{email})"
    end

    # Equality comparison based on all attributes
    #
    # @param other [Object]
    # @return [Boolean]
    def ==(other)
      other.is_a?(Client) &&
        id == other.id &&
        full_name == other.full_name &&
        email == other.email
    end

    alias eql? ==

    # Hash code for use in collections
    #
    # @return [Integer]
    def hash
      [id, full_name, email].hash
    end

    private

    def validate_id!(id)
      raise ArgumentError, 'id must be a positive integer' unless id.is_a?(Integer) && id.positive?
    end

    def validate_full_name!(full_name)
      raise ArgumentError, 'full_name must be a non-empty string' unless
        full_name.is_a?(String) && !full_name.strip.empty?
    end

    def validate_email!(email)
      raise ArgumentError, 'email must be a non-empty string' unless
        email.is_a?(String) && !email.strip.empty?
    end
  end
end
