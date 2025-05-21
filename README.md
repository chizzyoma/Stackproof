# Stackproof

A decentralized media authentication platform built on the Stacks blockchain.

## Overview

Stackproof provides a trustless solution for verifying the authenticity and origin of digital media. It enables creators to register their original content on the blockchain, creating an immutable record of ownership and a verifiable trail of authenticity.

## Features

- **Content Registration**: Register digital media with cryptographic hashes to prove ownership
- **Media Type Support**: Support for various media types including images, videos, documents, and audio
- **Creator Catalog**: Maintain a searchable catalog of content by creator
- **Content Verification**: Verify authenticity of digital media through cryptographic signatures
- **Creator Metrics**: Track creator activity and submission history

## Technical Details

### Data Structures

- **Content Registry**: Stores media verification data indexed by content fingerprint
- **Creator Metrics**: Maintains activity metrics for content creators
- **Creator Catalog**: Maps creators to their registered content
- **Verified Validators**: List of authorized validators for content verification

### Error Codes

- `STATUS_UNAUTHORIZED` (100): Unauthorized operation
- `STATUS_CONTENT_EXISTS` (101): Content with the same fingerprint already registered
- `STATUS_CONTENT_NOT_FOUND` (102): Referenced content not found
- `STATUS_INVALID_SIGNATURE` (103): Invalid cryptographic signature
- `STATUS_CREATOR_QUOTA_EXCEEDED` (104): Creator has reached their content limit
- `STATUS_INVALID_FORMAT` (105): Content format is invalid
- `STATUS_INVALID_INPUT` (106): Invalid input parameters

### System Parameters

- `CREATOR_CONTENT_LIMIT`: Maximum number of content items a creator can register (default: 100)
- `MIN_TITLE_LENGTH`: Minimum length requirement for content titles (default: 3)

## Usage

### Registering Content

To register new content on Stackproof:

```clarity
(contract-call? .stackproof register-content 
  <content-hash>          ;; (buff 32) SHA-256 hash of the content
  <media-type>            ;; (string-ascii 20) One of: "image", "video", "document", "audio", "other"
  <verification-signature> ;; (buff 65) Cryptographic signature
  <title>                 ;; (string-ascii 100) Content title (min 3 chars)
  <reference-url>         ;; (optional (string-utf8 256)) Optional URL reference
)
```

### Validation Process

All content submissions go through a validation process:

1. Input validation to ensure proper formatting and content integrity
2. Duplicate check to prevent re-registration of existing content
3. Cryptographic signature verification (to be implemented)
4. Creator quota check to prevent spam

## Development

### Building the Contract

```bash
# Compile the contract
clarity-cli check Stackproof.clar

# Test the contract
# (using Clarinet or other Clarity testing frameworks)
clarinet test
```

### Security Considerations

- All user inputs are validated before processing
- Creator quotas prevent spam attacks
- Content fingerprints ensure uniqueness of registered media

## Future Enhancements

- Content update and versioning system
- Delegated verification for trusted third parties
- Integration with decentralized storage solutions
- Reputation systems for creators and validators
- Token-based incentives for validators
