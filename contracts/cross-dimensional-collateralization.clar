;; Cross-dimensional Collateralization Contract
;; Allows assets from one dimension to be used as collateral in another

(define-map collaterals
  { id: uint }
  {
    property-id: uint,
    loan-amount: uint,
    source-dimension: uint,
    target-dimension: uint,
    borrower: principal,
    lender: principal,
    active: bool,
    liquidation-threshold: uint
  }
)

(define-data-var next-collateral-id uint u0)

(define-public (create-collateral (property-id uint) (loan-amount uint)
                                 (source-dimension uint) (target-dimension uint)
                                 (lender principal) (liquidation-threshold uint))
  (let
    ((collateral-id (var-get next-collateral-id)))
    (var-set next-collateral-id (+ collateral-id u1))
    (ok (map-set collaterals
      { id: collateral-id }
      {
        property-id: property-id,
        loan-amount: loan-amount,
        source-dimension: source-dimension,
        target-dimension: target-dimension,
        borrower: tx-sender,
        lender: lender,
        active: true,
        liquidation-threshold: liquidation-threshold
      }
    ))
  )
)

(define-public (liquidate-collateral (collateral-id uint))
  (match (map-get? collaterals { id: collateral-id })
    collateral
      (begin
        (asserts! (is-eq tx-sender (get lender collateral)) (err u403))
        (asserts! (get active collateral) (err u400))
        (ok (map-set collaterals
          { id: collateral-id }
          (merge collateral { active: false })
        )))
    (err u404)
  )
)

(define-public (repay-loan (collateral-id uint))
  (match (map-get? collaterals { id: collateral-id })
    collateral
      (begin
        (asserts! (is-eq tx-sender (get borrower collateral)) (err u403))
        (asserts! (get active collateral) (err u400))
        (ok (map-set collaterals
          { id: collateral-id }
          (merge collateral { active: false })
        )))
    (err u404)
  )
)

(define-read-only (get-collateral (collateral-id uint))
  (map-get? collaterals { id: collateral-id })
)

