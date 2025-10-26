# frozen_string_literal: true

# Result pattern for explicit success/failure handling.
# Prefer this over nil/boolean returns or using exceptions for control flow.
#
# @example Success case
#   result = Result::Success.new(value: [client1, client2])
#   result.success? # => true
#   result.value    # => [client1, client2]
#
# @example Failure case
#   result = Result::Failure.new(error: 'File not found')
#   result.failure? # => true
#   result.error    # => 'File not found'
module Result
  # Represents a successful operation with a value
  Success = Data.define(:value) do
    # @return [Boolean] true
    def success?
      true
    end

    # @return [Boolean] false
    def failure?
      false
    end
  end

  # Represents a failed operation with an error
  Failure = Data.define(:error) do
    # @return [Boolean] false
    def success?
      false
    end

    # @return [Boolean] true
    def failure?
      true
    end
  end
end
