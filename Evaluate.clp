
; =================================== evaluate ============================================ 
; evaluate does all the criteria checking for loan approval.
; input : norms and case
; output: case is true/false
; currently there are 5 norms to be awared of
; namely age, financial performance, salary-aspects, address-verified and repayment-ability


;====================
;Age
;
;Age > 18 to be valid
;====================

(defrule evaluate-age-true (declare (salience 400))
	(object (is-a Abstracted-Value) (criteria age) (value ?value)	(cf ?cf) )
	(object (is-a Norm-Value) 	(criteria age) (value ?value2&:(> ?value ?value2)))
	(object (is-a Loan) (approved nil))
	=>
	(bind ?rule-cf 1.0)
	(make-instance ev-age of Evaluated-Value (criteria age) (value YES) (cf (* ?cf ?rule-cf) ) )
)

(defrule evaluate-age-false (declare (salience 400))
	(object (is-a Abstracted-Value) (criteria age) (value ?value)	(cf ?cf) )
	(object (is-a Norm-Value) 	(criteria age) (value ?value2&:(<= ?value ?value2)))
	(object (is-a Loan) (approved nil))
	=>
	(bind ?rule-cf -1.0)
	(make-instance ev-age of Evaluated-Value (criteria age) (value YES) (cf (* ?cf ?rule-cf) ) )
)

;===================== 
;financial performance 
;
;Refer to specify-norm.clp for the matrices containing the valid instances
;=====================

(defrule evaluate-financial-performance  (declare (salience 400))
	(object (is-a Abstracted-Value) (criteria credit-card) 	(value ?value1) (cf ?cf1))
	(object (is-a Abstracted-Value) (criteria cheque) 	(value ?value2) (cf ?cf2))
	(object (is-a Abstracted-Value) (criteria bank-history) (value ?value3) (cf ?cf3))
	(object (is-a Abstracted-Value) (criteria property) 	(value ?value4) (cf ?cf4))

	(object (is-a Financial-Criteria) 
		(credit-card 		?value1) 	
		(cheque 		?value2)
		(bank-history 		?value3)
		(property 		?value4)
		(financial-value 	?value5)
	)
	(object (is-a Loan) (approved nil))
	=>
	(bind ?rule-cf 1.0)
	(make-instance evaluated-financial of Evaluated-Value 
		(criteria financial-performance) 
		(value ?value5)
		(cf  (* (min ?cf1 ?cf2 ?cf3 ?cf4) ?rule-cf))
		
	)
)



;====================================== 
;salary aspects
;1) meets estimated monthly repayments 
;   (surplus 2 times more than monthly repayment)
;2) time with employer more than 2 years
;==============================================

;meets-estimate YES and sufficient-years YES
;meets-estimate NO and sufficient-years NO

(defrule evaluate-salary-aspects-1  (declare (salience 400))
	(object (is-a Abstracted-Value) (criteria meets-estimate) 	(value ?value1)	(cf ?cf1))
	(object (is-a Abstracted-Value) (criteria abstracted-sufficient-years) 	(value ?value2)	(cf ?cf2))
	
	(object (is-a Norm-Value) 	(criteria meets-estimate) 	(value ?value3&:(eq ?value1 ?value3)) (cf ?rule-cf1))
	(object (is-a Norm-Value) 	(criteria abstracted-sufficient-years) (value ?value4&:(eq ?value2 ?value4)) (cf ?rule-cf2))

	(object (is-a Loan) (approved nil))
	=>	
	(make-instance (sym-cat evaluated-salary-aspects-(gensym*)) of Evaluated-Value 
		(criteria salary-aspects) (value ?value1) (cf  (* (min ?cf1 ?cf2) (min ?rule-cf1 ?rule-cf2)))	
	)
)




;======================== 
;address verified 
;
;rule:
;1. present address
;2. previous address
;3. special circumstances
;4. impeccable finances
;========================

;;==========================================================
;; if we obtain an address that has a positive certainty
;; factor, we take it that this address is acceptable to us.
;; we will only add this verifiable factor if it is positive
;;
;; if we obtain an address that has a negative certainty
;; factor, we take it that this address is mildly not acceptable to us.
;; The CF factor is set quite low here because the present and previous address are not so critical
;; If these criterion do not match, we will look at special circumstances
;;==========================================================


(defrule evaluate-address-verified  	(declare (salience 400))
	(object (is-a Abstracted-Value) (criteria abstracted-address) 	(value ?value1) (cf ?cf))
	(object (is-a Norm-Value) 	(criteria abstracted-address) (value ?value2&:(eq ?value1 ?value2)) (cf ?rule-cf))
	(object (is-a Loan) (approved nil))
	=>
	(make-instance (sym-cat loan-address-verified-(gensym*)) of Evaluated-Value (criteria address-verified) (value YES) (cf (* ?cf ?rule-cf)))
)



;;========================================================
;; for the case if there is special circumstances
;; surrounding verification of his address
;;========================================================

(defrule evaluate-special-circumstances  (declare (salience 400))
	(object (is-a Abstracted-Value) (criteria special-circumstances) (value ?value1) (cf ?cf))
	(object (is-a Norm-Value) 	(criteria special-circumstances) (value ?value2&:(eq ?value1 ?value2)) (cf ?rule-cf))
	(object (is-a Loan) (approved nil))
	=>
	(make-instance (sym-cat loan-address-verified-(gensym*)) of Evaluated-Value (criteria address-verified) (value YES) (cf (* ?cf ?rule-cf)))
)

;;==========================================================
;; for the case where the customer has impeccable finance
;;==========================================================

(defrule evaluate-impeccable-finances  (declare (salience 400))
	(object (is-a Abstracted-Value) (criteria impeccable-finances) (value ?value1) (cf ?cf))
	(object (is-a Norm-Value) 	(criteria impeccable-finances) (value ?value2&:(eq ?value1 ?value2)) (cf ?rule-cf))
	(object (is-a Loan) (approved nil))
	=>
	(make-instance (sym-cat loan-address-verified-(gensym*)) of Evaluated-Value (criteria address-verified) (value YES) (cf (* ?cf ?rule-cf)))
)


;================================================================================== 
;repayment ability 
;
;rule:
;1. present employment = full-time
;==================================================================================


(defrule evaluate-repayment-ability  (declare (salience 400))
	(object (is-a Abstracted-Value) (criteria full-time) (value ?value1) (cf ?cf))
	(object (is-a Norm-Value) 	(criteria full-time) (value ?value2&:(eq ?value1 ?value2)) (cf ?rule-cf))
	(object (is-a Loan) (approved nil))
	=>
	(make-instance evaluated-repayment-ability of Evaluated-Value (criteria repayment-ability) (value YES) (cf (* ?cf ?rule-cf)))
)


;;================================================
;; Job stability, determined by the abstract value
;; of the same name
;;================================================

(defrule evaluate-job-stability (declare (salience 400))
	(object (is-a Abstracted-Value) (criteria job-stability) (value ?value1) (cf ?cf))
	(object (is-a Norm-Value) 	(criteria job-stability) (value ?value2&:(eq ?value1 ?value2)) (cf ?rule-cf))
	(object (is-a Loan) (approved nil))
	=>
	(make-instance evaluated-job-stability of Evaluated-Value (criteria job-stability) (value YES) (cf (* ?cf ?rule-cf)))
)

