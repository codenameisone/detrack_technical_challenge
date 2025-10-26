# Client Manager CLI

A Ruby command-line application for managing and analyzing client data from JSON files. Provides searching and duplicate detection capabilities with clean architecture following SOLID principles.

## Table of Contents

- [Features](#features)
- [Requirements](#requirements)
- [Setup](#setup)
  - [Docker-Based Setup (Recommended)](#docker-based-setup-recommended)
  - [Ruby-Based Setup](#ruby-based-setup)
- [Usage](#usage)
  - [Search Clients](#search-clients)
  - [Find Duplicate Emails](#find-duplicate-emails)
- [Architecture](#architecture)
- [Testing](#testing)
- [Linting](#linting)
- [Assumptions and Decisions](#assumptions-and-decisions)
- [Known Limitations and Potential Future Enhancements](#known-limitations-and-potential-future-enhancements)

---

## Features

✅ **Client Search** - Case-insensitive partial name matching  
✅ **Duplicate Detection** - Case-insensitive email duplicate analysis with normalization  
✅ **Clean Architecture** - Value objects, query objects, repository pattern, Result monad  
✅ **Comprehensive Testing** - 93 tests with 98.98% coverage  
✅ **Docker Support** - Containerized for consistent environments  
✅ **Input Validation** - Fail-fast with meaningful error messages  


---

## Requirements

### Docker-Based (Recommended)
- Docker installed and running
- No Ruby installation required

### Ruby-Based
- Ruby >= 3.3.0
- Bundler 2.5.3 or higher
- rbenv (recommended for version management)

---

## Setup

### Docker-Based Setup (Recommended)

The easiest way to run the application without installing Ruby locally:

```bash
# 1. Clone the repository
git clone git@github.com:codenameisone/detrack_technical_challenge.git
cd detrack_challenge

# 2. That's it! Scripts will build Docker image automatically
./scripts/run_cli help
```

### Ruby-Based Setup

For local development with Ruby:

```bash
# 1. Clone the repository
git clone git@github.com:codenameisone/detrack_technical_challenge.git
cd detrack_challenge

# 2. Ensure Ruby 3.3.0 is installed
ruby --version  # Should show ruby 3.3.0

# Using rbenv (recommended):
rbenv install 3.3.0
rbenv local 3.3.0

# 3. Install dependencies
gem install bundler -v 2.5.3
bundle install

# 4. Run the CLI
bin/client_manager help
```

---

## Usage

### Search Clients

Search for clients by partial name match (case-insensitive):

#### Docker:
```bash
# Search for clients with "john" in their name
./scripts/run_cli search john

# Search with multi-word query
./scripts/run_cli search "jane smith"

# Use custom JSON file
./scripts/run_cli search john --file=path/to/custom.json
```

#### Ruby:
```bash
bin/client_manager search john
bin/client_manager search "jane smith"
bin/client_manager search smith --file=data/clients.json
```

**Example Output:**
```
Search results for 'john':
================================================================================
Found 2 client(s):

  ID: 1
  Name: John Doe
  Email: john.doe@gmail.com

  ID: 3
  Name: Alex Johnson
  Email: alex.johnson@hotmail.com
```

### Find Duplicate Emails

Identify clients with duplicate email addresses (case-insensitive, whitespace-trimmed):

#### Docker:
```bash
./scripts/run_cli duplicates
./scripts/run_cli duplicates --file=path/to/custom.json
```

#### Ruby:
```bash
bin/client_manager duplicates
bin/client_manager duplicates --file=data/clients.json
```

**Example Output:**
```
Duplicate Email Analysis:
================================================================================
Found 1 duplicate email(s):

Email: jane.smith@yahoo.com (2 occurrences)
  - ID: 2, Name: Jane Smith
  - ID: 15, Name: Another Jane Smith
```

**Note:** Emails are normalized (lowercase + trimmed) for duplicate detection:
- `Jane@Example.com` and `jane@example.com` → detected as duplicates
- ` test@example.com` and `test@example.com ` → detected as duplicates

---

## Architecture

This project follows **clean architecture** principles with clear separation of concerns:

```
lib/
├── models/
│   └── client.rb              # Immutable value object
├── queries/
│   ├── search_clients.rb      # Query object for searching
│   └── find_duplicates.rb     # Query object for duplicates
├── client_repository.rb       # Data access layer (Port/Adapter)
└── result.rb                  # Result monad for explicit error handling

bin/
└── client_manager             # CLI entry point (Thor)

spec/
├── models/                    # Unit tests
├── queries/                   # Query object tests
├── integration/               # End-to-end CLI tests
└── support/                   # Test helpers
```

### Design Patterns Used

1. **Value Object** (`Models::Client`) - Immutable, validated, frozen
2. **Query Object** (`Queries::SearchClients`, `Queries::FindDuplicates`) - Single-responsibility queries
3. **Repository Pattern** (`ClientRepository`) - Abstracts data access
4. **Result Monad** (`Result::Success`/`Result::Failure`) - Explicit success/failure handling
5. **Dependency Injection** - Queries receive data as constructor arguments
6. **Fail-Fast Validation** - Input validation at boundaries

---

## Testing

### Run All Tests

#### Docker:
```bash
./scripts/test                              # All tests
./scripts/test spec/models                  # Specific directory
./scripts/test spec/queries/search_clients_spec.rb  # Specific file
```

#### Ruby:
```bash
bundle exec rspec                           # All tests
bundle exec rspec spec/models               # Specific directory
bundle exec rspec spec/queries/search_clients_spec.rb  # Specific file
```

**Current Stats:**
- 93 tests, 0 failures
- 98.98% line coverage
- Unit, integration, and edge case coverage

---

## Linting

### RuboCop

#### Docker:
```bash
./scripts/lint           # Run linter
./scripts/lint -a        # Auto-fix safe issues
./scripts/lint -A        # Auto-fix all issues
```

#### Ruby:
```bash
bundle exec rubocop
bundle exec rubocop -a   # Auto-fix
```

**Configured Cops:**
- `rubocop` - Core style guide
- `rubocop-performance` - Performance optimizations
- `rubocop-rspec` - RSpec best practices

---

## Assumptions and Decisions

### Assumptions
1. **JSON File Format** - Root is an array of client objects with `id`, `full_name`, and `email` fields
2. **Data Immutability** - Client data is read-only; no persistence operations needed
3. **Email Normalization** - Emails should be compared case-insensitively with whitespace trimmed
4. **Single User** - CLI designed for single-user local execution (no concurrent access concerns)
5. **Small Dataset** - In-memory processing is acceptable (no pagination or streaming needed)

### Key Design Decisions

#### 1. Email Normalization Strategy
**Decision:** Normalize emails using `downcase.strip` for duplicate detection.

**Rationale:**
- RFC 5321 specifies email local-part is technically case-sensitive, but most providers treat them as case-insensitive
- Real-world duplicate detection should match `User@Example.com` and `user@example.com`
- Whitespace trimming prevents accidental duplicates from data entry errors

**Trade-off:** May group emails that are technically distinct per RFC spec.

#### 2. Result Pattern Over Exceptions
**Decision:** Use `Result::Success`/`Result::Failure` instead of exceptions for control flow.

**Rationale:**
- Makes error handling explicit in type signatures
- Forces callers to handle both success and failure cases
- Avoids expensive exception stack traces for expected failures
- Better composability for functional-style pipelines

**Alternative Considered:** Ruby's built-in exceptions, but they don't force callers to handle errors.

#### 3. Immutable Value Objects
**Decision:** Freeze all `Client` instances after validation.

**Rationale:**
- Prevents accidental mutation bugs
- Safe to share across threads
- Clear intent that clients are data containers, not entities
- Enables safe use as hash keys

#### 4. Repository Pattern for Data Access
**Decision:** Encapsulate file I/O in `ClientRepository` class.

**Rationale:**
- Isolates I/O from business logic
- Easy to swap implementations (file → database → API)
- Centralized error handling for I/O failures
- Testable with in-memory implementations

#### 5. Thor for CLI Framework
**Decision:** Use Thor gem over OptionParser or custom CLI.

**Rationale:**
- Industry-standard CLI framework (used by Rails, Bundler)
- Built-in help generation
- Sub-command support
- Option parsing with type coercion

---

## Known Limitations And Potential Future Enhancements

### 1. **Email Format Validation**
- **Current:** Only validates email is non-empty string
- **Missing:** No regex validation for valid email format
- **Impact:** Accepts malformed emails like `"not-an-email"`

### 2. **In-Memory Processing**
- **Current:** Loads entire JSON file into memory
- **Impact:** Not suitable for files larger than available RAM

### 3. **No Data Persistence**
- **Current:** Read-only operations; no save/update/delete
- **Impact:** Cannot fix duplicates or update records

### 4. **Single File Source**
- **Current:** Only loads from JSON files
- **Impact:** Cannot query databases, APIs, or multiple files

### 5. **No Pagination**
- **Current:** Returns all results at once
- **Impact:** Large result sets flood terminal output

### 6. **Missing Security Tooling**
- **Current:** No Brakeman, bundler-audit, or Reek in CI
- **Impact:** Vulnerabilities may go undetected

### 7. **No Structured Logging**
- **Current:** Simple `puts` and `warn` output
- **Impact:** Difficult to parse logs or integrate with monitoring
