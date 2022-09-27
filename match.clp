;;==============================================
;; Rules for matching the relevant
;; Evaluated-Values
;;==============================================

;;=======================================================
;; Rule to match basic requirements
;; Age must be acceptable and
;; Address must be verified and
;; Must be able to make repayment and
;; Salary must be verified
;;=======================================================

(defrule match-basic1 (declare (salience 201))
	(object (is-a Evaluated-Value) (criteria age) (value YES) (cf ?age-cf))
	(object (is-a Evaluated-Value) (criteria address-verified) (value YES) (cf ?address-verified-cf))
	(object (is-a Evaluated-Value) (criteria salary-aspects) (value YES) (cf ?salary-verified-cf))
	(object (is-a Evaluated-Value) (criteria repayment-ability) (value YES) (cf ?repayment-ability-cf))
	(not (terminate-early))
	(object (is-a Loan) (approved nil))
	=>
	(bind ?rule-cf 0.9)
	(make-instance (sym-cat loan-decision-(gensym)) of Evaluated-Value (criteria loan-decision) (value YES) 
		(cf (* ?rule-cf (conjunctive-evidence
			?age-cf ?address-verified-cf ?salary-verified-cf ?repayment-ability-cf
		)))
	)

)

;;==========================================
;; we match and terminate early if
;; we can't find any more information to
;; change our conclusion
;;==========================================

;; terminating early

(defrule match-basic2  (declare (salience 600))
	(terminate-early)
	?obj <- (object (is-a Loan) (approved nil))
	=>
	(modify-instance ?obj (approved NO))
	(make-instance (sym-cat loan-decision-(gensym)) of Evaluated-Value (criteria loan-decision) (value YES) (cf -1))

)

;;==============================================
;; Rules regarding financial performance
;; Value of financial-performance must be either
;; HIGH or MEDIUM in order for the loan decision 
;; to be positive
;;==============================================

(defrule match-financial-performance1 (declare (salience 201))
	(object (is-a Evaluated-Value) (criteria financial-performance) (value HIGH | MEDIUM) (cf ?financial-performance-cf))
	(object (is-a Evaluated-Value) (criteria job-stability) (cf ?job-stability-cf&:(> ?job-stability-cf 0)))
	=>
	(bind ?rule-cf 0.3)
	(make-instance (sym-cat loan-decision-(gensym)) of Evaluated-Value (criteria loan-decision) (value YES) (cf (* ?rule-cf (min ?financial-performance-cf ?job-stability-cf))))
)

;;======================================================
;; When financial performance is low, the decision to
;; give the loan will be a no
;;======================================================

(defrule match-financial-performance2 (declare (salience 201))
	(object (is-a Evaluated-Value) (criteria financial-performance) (value LOW) (cf ?financial-performance-cf))
	=>
	(bind ?rule-cf -0.9)
	(make-instance (sym-cat loan-decision-(gensym)) of Evaluated-Value (criteria loan-decision) (value YES) (cf (* ?rule-cf ?financial-performance-cf)))
)

;;=================================================
;; if job stability is low
;; then we do not give out the loan
;;=================================================

(defrule match-financial-performance3 (declare (salience 201))

	(object (is-a Evaluated-Value) (criteria job-stability) (cf ?cf&:(<= ?cf 0)))
	=>
	(bind ?rule-cf 0.9)
	(make-instance (sym-cat loan-decision-(gensym)) of Evaluated-Value (criteria loan-decision) (value YES) (cf (* ?rule-cf ?cf)))
)

;;=======================================================
;; Rules to set the loan approval
;;=======================================================

(defrule match-loan-approval1 (declare (salience 200))

	(object (is-a Evaluated-Value) (criteria loan-decision) (cf ?cf&:(> ?cf 0.5)))
	?obj <- (object (is-a Loan) (approved nil))
	=>

	(modify-instance ?obj (approved YES))
)

(defrule match-loan-approval2 (declare (salience 200))

	(object (is-a Evaluated-Value) (criteria loan-decision) (cf ?cf&:(<= ?cf 0.5)))
	?obj <- (object (is-a Loan) (approved nil))
	=>

	(modify-instance ?obj (approved NO))
)
