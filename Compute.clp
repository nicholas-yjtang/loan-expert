; =================================== COMPUTE ============================================ ;
; Compute does the computation of raw data from the applicant to be used in abstraction & evaluation process
; Input : raw data
; Output: computed case


;=============================================================================
;Compute Monthly Repayment
;Loan Period is based on year(s)
;
;The value will be used in checking repayment-ability under Evaluate inference
;=============================================================================
(deffunction compute-monthly-repayment (?loan-amount ?loan-period)
	
	 (return (/ ?loan-amount (* ?loan-period 12)) )
	 
)

;================================================================================
;Check whether the present salary is sufficient to cover for the montly repayment
;
;YES if NET-salary > (2 times monthly repayment amount)
;
;NET-salary = (present-salary - expenses - commitments)
;
;The value will be used in checking repayment-ability under Evaluate inference
;
;================================================================================
(deffunction check-salary-satisfied (?expenses ?commitments ?salary ?monthly-repayment)
	
	(bind ?surplus (- ?salary (+ ?expenses ?commitments) ) )
	(if (> ?surplus  (* 2 ?monthly-repayment) ) then
		(return YES)
	else
		(return NO)
	)
)


;=======================================
;MONTHLY REPAYMENT
;
;Compute and store monthly repayment amount in Loan class
;The value will be used in evaluation of repayment-ability and 
;computation of monthly-repayment with interests
;=======================================

(defrule compute-repayment (declare (salience 500))
	?loan <- (object (is-a Loan) (amount ?amount)	(period ?period) )
	=>
	(send ?loan put-monthly-repayment (compute-monthly-repayment ?amount ?period) )	
)



;====================================== 
;SALARY 
;= Income - Monthly Expenses - Montyly Commitments
;==============================================

(defrule compute-salary-verified1 (declare (salience 500))
	(object (is-a Employment) 	(salary ?salary&:(> ?salary 0)))
	(object (is-a Additional-Info) 	
		(monthly-expenses ?expenses&:(>= ?expenses 0))
		(commitments ?commitments&:(>= ?commitments 0)))
	?loan <- (object (is-a Loan) 	(monthly-repayment ?monthly-repayment)	)
	(test (eq (check-salary-satisfied ?expenses ?commitments ?salary ?monthly-repayment) YES))
	=>
	(make-instance abs-salary-verified of Abstracted-Value 
			(criteria meets-estimate) 
			(value YES)
			(cf 0.8)
	)

)

(defrule compute-salary-verified2 (declare (salience 500))
	(object (is-a Employment) 	(salary ?salary&:(> ?salary 0)))
	(object (is-a Additional-Info) 	
		(monthly-expenses ?expenses&:(>= ?expenses 0))
		(commitments ?commitments&:(>= ?commitments 0)))
	?loan <- (object (is-a Loan) 	(monthly-repayment ?monthly-repayment)	)
	(test (eq (check-salary-satisfied ?expenses ?commitments ?salary ?monthly-repayment) NO))
	=>
	(make-instance abs-salary-verified of Abstracted-Value 
			(criteria meets-estimate) 
			(value NO)
			(cf 0.8)
	)

)


;=========================== COMPUTE ======================================
; can get monthly repayment form loan class
; put amount back to loan:monthly-repayment-with-interest
(deffunction compute-monthly-repayment-with-interest (?monthly-repayment ?loan-interest-amount)
	
	 (return (+ ?monthly-repayment ?loan-interest-amount))
	 
)

(deffunction compute-interest (?loan-amount ?monthly-repayment ?interest-rate)
	
	 (return 
	 	(/ (* (- ?loan-amount ?monthly-repayment) (/ ?interest-rate 100) ) 12)
	 )
	 
)

(defrule define-interest-of-two-seven-five
	?loan <- (object (is-a Loan) (approved YES))
	(object (is-a Abstracted-Value) (criteria job-stability) 		(value YES))
	(object (is-a Evaluated-Value) 	(criteria financial-performance) 	(value HIGH))
	=>
	(send ?loan put-interest-rate 2.75)
)

(defrule define-interest-of-three-five
	?loan <- (object (is-a Loan) 	(approved YES))
	(object (is-a Evaluated-Value) 	(criteria financial-performance) 	(value MEDIUM))
	=>
	(send ?loan put-interest-rate 3.5)
)


(defrule monthly-repayment-with-interest
	?loan <- (object (is-a Loan) 	(approved YES) 
					(amount ?loan-amount) 
					(monthly-repayment ?monthly-repayment)
					(interest-rate ?rate&:(<> ?rate 0))
		)
	=>
	(bind ?interest (compute-interest ?loan-amount ?monthly-repayment ?rate) )
	(send ?loan put-monthly-repayment-with-interest (compute-monthly-repayment-with-interest ?monthly-repayment ?interest))
)


