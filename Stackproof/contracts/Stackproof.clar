;; Stackproof - Distributed Media Authentication Platform on Stacks

;; Error codes
(define-constant STATUS_UNAUTHORIZED (err u100))
(define-constant STATUS_CONTENT_EXISTS (err u101))
(define-constant STATUS_CONTENT_NOT_FOUND (err u102))
(define-constant STATUS_INVALID_SIGNATURE (err u103))
(define-constant STATUS_CREATOR_QUOTA_EXCEEDED (err u104))
(define-constant STATUS_INVALID_FORMAT (err u105))
(define-constant STATUS_INVALID_INPUT (err u106))

;; System parameters
(define-constant CREATOR_CONTENT_LIMIT u100)
(define-constant SYSTEM_CONTROLLER tx-sender)
(define-constant MIN_TITLE_LENGTH u3)

;; Data storage

;; Stores media verification data indexed by content fingerprint
(define-map content-registry
  { digest: (buff 32) }
  {
    creator: principal,
    timestamp: uint,
    media-type: (string-ascii 20),
    verification-signature: (buff 65),
    title: (string-ascii 100),
    visible: bool,
    reference-url: (optional (string-utf8 256)),
    version: uint
  }
)

;; Maintains creator activity metrics
(define-map creator-metrics
  { account: principal }
  {
    submissions: uint,
    last-activity: uint
  }
)

;; Maps creators to their registered content
(define-map creator-catalog
  { account: principal, index: uint }
  { digest: (buff 32) }
)

;; Authorized verifiers list
(define-map verified-validators
  { validator: principal }
  { active: bool }
)

;; Helper functions for input validation
(define-private (validate-digest (input-digest (buff 32)))
  (begin
    ;; Check that digest is not all zeros
    (if (is-eq input-digest 0x0000000000000000000000000000000000000000000000000000000000000000)
      false
      true)
  )
)

(define-private (validate-media-type (input-type (string-ascii 20)))
  (begin
    ;; Check that media type is not empty and is one of the allowed types
    (and 
      (> (len input-type) u0) 
      (or 
        (is-eq input-type "image")
        (is-eq input-type "video") 
        (is-eq input-type "document")
        (is-eq input-type "audio")
        (is-eq input-type "other")
      )
    )
  )
)

(define-private (validate-signature (input-sig (buff 65)))
  (begin
    ;; Basic check that signature is not empty/all zeros
    (if (is-eq input-sig 0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000)
      false
      true)
  )
)

(define-private (validate-title (input-title (string-ascii 100)))
  (begin
    ;; Check that title is at least 3 characters long
    (>= (len input-title) MIN_TITLE_LENGTH)
  )
)

(define-private (validate-url (input-url (optional (string-utf8 256))))
  (begin
    ;; If URL is provided, ensure it's not empty
    (match input-url
      url-value (> (len url-value) u0)
      true  ;; Optional is none, so valid
    )
  )
)

;; Public functions
(define-public (register-content
                (digest (buff 32))
                (media-type (string-ascii 20))
                (verification-signature (buff 65))
                (title (string-ascii 100))
                (reference-url (optional (string-utf8 256))))
  (begin
    ;; First validate all inputs before proceeding
    (asserts! (validate-digest digest) STATUS_INVALID_INPUT)
    (asserts! (validate-media-type media-type) STATUS_INVALID_INPUT)
    (asserts! (validate-signature verification-signature) STATUS_INVALID_INPUT)
    (asserts! (validate-title title) STATUS_INVALID_INPUT)
    (asserts! (validate-url reference-url) STATUS_INVALID_INPUT)
    
    (let
      (
        (user tx-sender)
        (block-num stacks-block-height)
      )
      ;; Check that the content doesn't already exist
      (asserts! (is-none (map-get? content-registry { digest: digest })) STATUS_CONTENT_EXISTS)
      
      ;; Signature verification (would be implemented in a real contract)
      ;; (asserts! (verify-signature digest verification-signature user) STATUS_INVALID_SIGNATURE)
      
      (let
        (
          (user-data (default-to { submissions: u0, last-activity: u0 } (map-get? creator-metrics { account: user })))
          (submission-count (get submissions user-data))
        )
        (asserts! (< submission-count CREATOR_CONTENT_LIMIT) STATUS_CREATOR_QUOTA_EXCEEDED)
        
        ;; All checks passed, store the content
        (map-set content-registry
          { digest: digest }
          {
            creator: user,
            timestamp: block-num,
            media-type: media-type,
            verification-signature: verification-signature,
            title: title,
            visible: true,
            reference-url: reference-url,
            version: u1
          }
        )
        
        ;; Update creator catalog and metrics
        (map-set creator-catalog
          { account: user, index: submission-count }
          { digest: digest }
        )
        
        (map-set creator-metrics
          { account: user }
          {
            submissions: (+ submission-count u1),
            last-activity: block-num
          }
        )
        
        (ok digest)
      )
    )
  )
)