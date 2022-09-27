
; =================================== MESSAGES ============================================ ;
; Print out the causes of the application to be rejected

;When age is invalid
(defrule age
	(object (is-a Evaluated-Value) (criteria age) (cf ?age-cf&:(< ?age-cf 0.0) ))
	=>
	(make-instance msg-age of Message-Evaluation (criteria Age) (value "Age is not qualified for the loan"))	
)

;; ================================== ADDRESS VERIFIED =====================================
;When address-verified is invalid
(defrule address-verified
	(declare (salience -997))
	(object (is-a Evaluated-Value) (criteria address-verified) (cf ?value&:(< ?value 0.0) ))
	=>
	(make-instance msg-address of Message-Evaluation (criteria address-verified)  (value "Address is not safe and not stable"))
	
)

;Check whether present or previous address
(defrule address
	(object (is-a Evaluated-Value) (criteria address-verified) (cf ?value&:(< ?value 0.0) ))
	(object (is-a Abstracted-Value) (criteria abstracted-address) (value NO))
	=>
	(make-instance msg-address of Message-Abstraction (evaluated-criteria address-verified) (abstracted-criteria address)  (value "Applicant does not have a stable address"))
)

;Check whether special-circumstances is one of the cause
(defrule special-circumstances
	(object (is-a Evaluated-Value) (criteria address-verified) (cf ?value&:(< ?value 0.0) ))
	(object (is-a Abstracted-Value) (criteria special-circumstances) (value NO))
	=>
	(make-instance msg-special-circumstances of Message-Abstraction (evaluated-criteria address-verified) (abstracted-criteria special-circumstances)  (value "Neither does he/she work overseas"))
)

;Check whether impeccable-finances is one of the cause
(defrule impeccable-finances
	(object (is-a Evaluated-Value) (criteria address-verified) (cf ?value&:(< ?value 0.0) ))
	(object (is-a Abstracted-Value) (criteria impeccable-finances) (value NO))
	=>
	(make-instance msg-impeccable-finances of Message-Abstraction (evaluated-criteria address-verified) (abstracted-criteria impeccable-finances)  (value "Neither does he/she have high credit limit or earns a lot of money"))
)


;; ================================== SALARY ASPECTS =====================================

(defrule salary
	(declare (salience -998))
	(object (is-a Evaluated-Value) (criteria salary-aspects) (cf ?value&:(< ?value 0.0) ))
	=>	
	(make-instance msg-salary of Message-Evaluation (criteria salary-aspects) (value "Salary aspects is still insufficient to cover for the loan"))
	
)

(defrule meets-estimate
	(object (is-a Evaluated-Value) (criteria salary-aspects) (cf ?value&:(< ?value 0.0) ))
	(object (is-a Abstracted-Value) (criteria meets-estimate) (value NO))
	=>
	(make-instance msg-meets-estimate of Message-Abstraction (evaluated-criteria salary-aspects) (abstracted-criteria meets-estimate)  (value "Based on applicant's current salary, it is not adequate to cover the monthly repayment for the loan"))
)

(defrule sufficient-years
	(object (is-a Evaluated-Value) (criteria salary-aspects) (cf ?value&:(< ?value 0.0) ))
	(object (is-a Abstracted-Value) (criteria abstracted-sufficient-years) (value NO))
	=>
	(make-instance msg-sufficient-years of Message-Abstraction (evaluated-criteria salary-aspects) (abstracted-criteria sufficient-years)  (value "Applicant does not have sufficient years of employment"))
)

;; ================================== REPAYMENT ABILITY =====================================

(defrule repayment-ability
	(object (is-a Evaluated-Value) (criteria repayment-ability) (cf ?value&:(< ?value 0.0) ))
	=>
	(make-instance msg-repayment-ability of Message-Evaluation (criteria repayment-ability) (value "The applicant does not have a Full-Time employment"))
	
)


;; ================================== JOB STABILITY =====================================

(defrule job-stability
	(object (is-a Evaluated-Value) (criteria job-stability) (cf ?value&:(<= ?value 0.0) ))
	=>
	(make-instance msg-job-stability of Message-Evaluation (criteria job-stability) (value "The applicant has been changing job more than 3 times for the last 3 years, does not seem stable"))
	
)



;; ================================== FINANCIAL PERFORMANCE =====================================

(defrule financial-performance
	(object (is-a Evaluated-Value) 	(criteria financial-performance) (value LOW) )
	
	(object (is-a Abstracted-Value) (criteria credit-card) 	(value ?value1) )
	(object (is-a Abstracted-Value) (criteria cheque) 	(value ?value2) )
	(object (is-a Abstracted-Value) (criteria bank-history) (value ?value3) )
	(object (is-a Abstracted-Value) (criteria property) 	(value ?value4) )
	=>
	(bind ?msg "The Financial Performance is low")
	(make-instance msg-financial-performance of Message-Evaluation (criteria financial-performance) (value ?msg))		
)

(defrule credit-card
	(object (is-a Evaluated-Value) 	(criteria financial-performance) (value LOW) )
	(object (is-a Abstracted-Value) (criteria credit-card) 	(value NO) )
	=>
	(make-instance msg-credit-card of Message-Abstraction (evaluated-criteria financial-performance) (abstracted-criteria credit-card)  (value "Credit card requirement does not meet"))
)

(defrule cheque
	(object (is-a Evaluated-Value) 	(criteria financial-performance) (value LOW) )
	(object (is-a Abstracted-Value) (criteria cheque) 	(value NO) )
	=>
	(make-instance msg-cheque of Message-Abstraction (evaluated-criteria financial-performance) (abstracted-criteria cheque)  (value "No chequing account"))
)

(defrule bank-history
	(object (is-a Evaluated-Value) 	(criteria financial-performance) (value LOW) )
	(object (is-a Abstracted-Value) (criteria bank-history) (value BAD) )
	=>
	(make-instance msg-bank-history of Message-Abstraction (evaluated-criteria financial-performance) (abstracted-criteria bank-history)  (value "Bank history is not good"))
)


(defrule property
	(object (is-a Evaluated-Value) 	(criteria financial-performance) (value LOW) )
	(object (is-a Abstracted-Value) (criteria property) 	(value NO) )
	=>
	(make-instance msg-property of Message-Abstraction (evaluated-criteria financial-performance) (abstracted-criteria property)  (value "Property value is not promising"))
)

(defrule loan-not-approved
	(object (is-a Loan) (approved NO))
	=>
	(make-instance msg-financial-performance of Message-Evaluation (criteria loan-decision) (value "Loan was not approved"))		
)

;============================= PRINT OUT Message-Evaluation =========================

(deffunction Print-Only-Executive-Summary ()
	(printout t "=========== Executive Summary ==============" crlf crlf)
	(if (any-instancep ((?m Message-Evaluation)) (neq value nil) ) then
		(do-for-all-instances 	
			((?msg Message-Evaluation))
			(neq ?msg:value nil)
			(printout t "- " ?msg:value crlf)				
			
			(do-for-all-instances 	
				((?msg-abs Message-Abstraction)	)
				(and 	(neq ?msg-abs:value nil)
					(eq ?msg-abs:evaluated-criteria ?msg:criteria)
				)
				(printout t "       * " ?msg-abs:value crlf)													
			)
			
		)
	else
		(printout t "All the requirements are fulfilled" crlf)	
	)
	(printout t crlf "============================================" crlf)
)
