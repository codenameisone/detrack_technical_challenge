FROM ruby:3.3.0-alpine

# Install dependencies for building native extensions
RUN apk add --no-cache \
    build-base \
    git

# Set working directory
WORKDIR /app

# Copy Gemfile and Gemfile.lock
COPY Gemfile* ./

# Install gems
RUN bundle install

# Copy application code
COPY . .

# Default command
CMD ["/bin/sh"]
