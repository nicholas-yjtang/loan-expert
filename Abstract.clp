
; =================================== ABSTRACT ============================================ ;
; Abstract does the abstraction of raw data from the applicant and convert into KB format
; Input : raw data
; Output: data in KB format


;;=============================
;; AGE 
;; Criteria for AGE to be Valid
;;=============================


(defrule abstract-age (declare (salience 500))
	(object (is-a 	Applicant) 	(age ?age&:(> ?age 0)) )	
	=>	
	(make-instance abs-age of Abstracted-Value (criteria age) (value ?age) (cf 1.0))
)



;========================================
;Abstract if the customer has been employed long enough
;Either one of the employment must be > 2 years
;
;1. Present Employment
;2. Previous Employment 1
;3. Previous Employment 2
;
;If the present employment is <= 2 years, 
;system will ask for previous employment, re-evaluate, and so on.
;========================================

(defrule abstract-salary-sufficient-years-true (declare (salience 500))
	(object (is-a Employment) (no-of-years ?year&:(> ?year 0)))
	(object (is-a Norm-Value) (criteria sufficient-years) (value ?value&:(> ?year ?value)))
	=>
	(make-instance (sym-cat abs-sufficient-years-(gensym*)) of Abstracted-Value (criteria abstracted-sufficient-years) (value YES) (cf 0.9))
)

(defrule abstract-salary-sufficient-years-false (declare (salience 500))
	(object (is-a Employment) (no-of-years ?year&:(> ?year 0)))
	(object (is-a Norm-Value) (criteria sufficient-years) (value ?value&:(<= ?year ?value)))
	=>
	(make-instance (sym-cat abs-sufficient-years-(gensym*)) of Abstracted-Value (criteria abstracted-sufficient-years) (value NO) (cf 0.9) )
)


;;************************************************
;; FINANCIAL-PERFORMANCE
;; Abstractions to assist in financial performance
;;
;; Based on:
;; 1. Credit Card
;; 2. Chequing Account
;; 3. Bank History
;; 4. Property Value
;;************************************************

;================================================= 
;FINANCIAL - CREDIT CARD
;
;Abstract whether the applicant has credit card(s)
;This abstracted value will be used to evaluate financial performance
;=================================================

(defrule abstract-credit-card-yes (declare (salience 500))
	(object (is-a 	Financial) 	(credit-card ?cc&~nil) ) 
	(object (is-a Norm-Value) 	(criteria credit-card) (value ?value&:(eq ?cc ?value)))
	=>	
	(make-instance abs-credit-card of Abstracted-Value (criteria credit-card) (value YES)	(cf 1.0))
)

(defrule abstract-credit-card-no (declare (salience 500))
	(object (is-a 	Financial) 	(credit-card ?cc&~nil) ) 
	(object (is-a Norm-Value) 	(criteria credit-card) (value ?value&~?cc) )
	=>	
	(make-instance abs-credit-card of Abstracted-Value (criteria credit-card) (value NO)	(cf 1.0))
)


;=====================================================
;FINANCIAL - CHEQUEING ACCOUNT 
;
;Abstract whether the applicant has chequing account(s)
;This abstracted value will be used to evaluate financial performance
;======================================================

(defrule abstract-cheque-yes (declare (salience 500))
	(object (is-a 	Financial) 	(cheque ?cc&~nil) ) 
	(object (is-a Norm-Value) 	(criteria cheque) (value ?value&:(eq ?cc ?value)))
	=>	
	(make-instance abs-cheque of Abstracted-Value (criteria cheque) (value YES) (cf 1.0))
)

(defrule abstract-cheque-no (declare (salience 500))
	(object (is-a 	Financial) 	(cheque ?cc&~nil) ) 
	(object (is-a Norm-Value) 	(criteria cheque) (value ?value&~?cc))
	=>	
	(make-instance abs-cheque of Abstracted-Value (criteria cheque) (value NO) (cf 1.0))
)

;******************************************************* 
;FINANCIAL - BANK HISTORY 
;
;It is determined from no-of-transactions made in a month
;No-of-transactions has been pre-calculated by 
;total up no-of-deposits and no-of-withdrawals
;
;This abstracted value will be used to evaluate financial performance
;*******************************************************

;============================= 
;FINANCIAL - BANK INFO 
;
;No-of-transactions = no-of-deposits + no-of-withdrawals
;================================

(defrule abstract-bank-info (declare (salience 500))
	?ins <- (object (is-a Financial)  (no-of-transactions 	nil)	)	
	=>
	(bind ?total 0)
	(do-for-instance 	((?info Bank-Info))
				(and 	(neq ?info:no-of-deposit nil)
					(neq ?info:no-of-withdrawals nil)
				)
				(bind ?total (+ ?total ?info:no-of-deposit ?info:no-of-withdrawals))
	)
	(send ?ins put-no-of-transactions ?total)
	(make-instance abs-no-of-transactions of Abstracted-Value (criteria no-of-transactions) (value ?total) (cf 1.0))
)

(defrule abstract-bank-history-good (declare (salience 500))
	(object (is-a Financial)  (no-of-transactions 	?trans&~nil	)	)	
	(object (is-a Norm-Value) (criteria no-of-transactions) (value ?value&:(> ?trans ?value)))
	=>
	(make-instance bank-history of Abstracted-Value (criteria bank-history) (value GOOD)  (cf 0.8))
)

(defrule abstract-bank-history-bad (declare (salience 500))
	(object (is-a Financial)  (no-of-transactions 	?trans&~nil)	)	
	(object (is-a Norm-Value) (criteria no-of-transactions) (value ?value&:(<= ?trans ?value)))
	=>
	(make-instance bank-history of Abstracted-Value (criteria bank-history) (value BAD)  (cf 0.8))
)

;===================================================== 
;FINANCIAL - PROPERTY 
;
;Abstract whether the applicant has property, 
;and how much is the value of the property
;
;This abstracted value will be used to evaluate financial performance
;=====================================================

(defrule abstract-property-yes (declare (salience 500))
	(object (is-a Financial)  (property-value 	?trans&~nil)	)	
	(object (is-a Norm-Value) (criteria property-value) (value ?value&:(> ?trans ?value)))	
	=>
	(make-instance property of Abstracted-Value (criteria property) (value YES) (cf 0.8))
)

(defrule abstract-property-no (declare (salience 500))
	(object (is-a Financial)  (property-value 	?trans&~nil)	)	
	(object (is-a Norm-Value) (criteria property-value) (value ?value&:(<= ?trans ?value)))
	=>
	(make-instance property of Abstracted-Value (criteria property) (value NO) (cf 0.8))
)


;;******************************************************************
;; ADDRESS-VERIFIED
;;
;;Abstractions to verify the physical address
;;
;;1. Present Address
;;2. Previous Address (If present address is not valid)
;;3. Special Circumstances (If previous address is not valid too)
;;4. Impeccable Finances (If all the above 3 criterion are not valid)
;;*******************************************************************


(defrule abstract-address-true (declare (salience 500))
	(object (is-a Address) 		(no-of-years ?value))
	(object (is-a Norm-Value) 	(criteria address) (value ?value2&:(> ?value ?value2)))
	=>
	(make-instance (sym-cat abs-address- (gensym*)) of Abstracted-Value (criteria abstracted-address) (value YES) (cf 0.8 ))
)

(defrule abstract-address-false (declare (salience 500))
	(object (is-a Address) (no-of-years ?value))
	(object (is-a Norm-Value) 	(criteria address) (value ?value2&:(<= ?value ?value2)))
	=>	
	(make-instance (sym-cat abs-address- (gensym*)) of Abstracted-Value (criteria abstracted-address) (value NO) (cf 0.8))
)


;===========================================
;FINANCIAL - CREDIT LIMIT 
;
;This is to measure the Impeccable Finances, 
;when address verified is NO
;===========================================

(defrule abstract-credit-limit-yes (declare (salience 500))
	(object (is-a 	Financial) 	(credit-limit ?cc&~nil) ) 
	(object (is-a Norm-Value) 	(criteria credit-limit) (value ?value&:(> ?cc ?value)))
	=>	
	(make-instance abs-credit-limit of Abstracted-Value (criteria high-credit-limit) (value YES) (cf 0.8))
)

(defrule abstract-credit-limit-no (declare (salience 500))
	(object (is-a 	Financial) 	(credit-limit ?cc&~nil) ) 
	(object (is-a Norm-Value) 	(criteria credit-limit) (value ?value&:(<= ?cc ?value)))
	=>	
	(make-instance abs-credit-limit of Abstracted-Value (criteria high-credit-limit) (value NO) (cf 0.8))
)

;================================= 
;PAID A LOT OF MONEY 
;
;This is to measure the Impeccable Finances, 
;when address verified is NO
;==================================

(defrule abstract-paid-a-lot-of-money-yes (declare (salience 500))
	(object (is-a 	Employment) 	(salary ?cc&:(> ?cc 0)) ) 
	(object (is-a 	Norm-Value) 	(criteria paid-a-lot-of-money) (value ?value&:(> ?cc ?value)))
	=>	
	(make-instance abs-paid-a-lot-of-money of Abstracted-Value (criteria paid-a-lot-of-money) (value YES) (cf 0.8))
)

(defrule abstract-paid-a-lot-of-money-no (declare (salience 500))
	(object (is-a 	Employment) 	(salary ?cc&:(> ?cc 0)) ) 
	(object (is-a 	Norm-Value) 	(criteria paid-a-lot-of-money) (value ?value&:(<= ?cc ?value)))
	=>	
	(make-instance abs-paid-a-lot-of-money of Abstracted-Value (criteria paid-a-lot-of-money) (value NO) (cf 0.8))
)

;=======================================
;SPECIAL CIRCUMSTANCES
;
;This is one of the criterion for 
;determining safe address (Address Verified)
;=======================================

(defrule abstract-special-circumstances-yes (declare (salience 500))
	(object (is-a 	Additional-Info) 	(worked-overseas ?cc&~nil) ) 
	(object (is-a 	Norm-Value) 		(criteria worked-overseas) (value ?value&:(eq ?cc ?value)))
	=>	
	(make-instance abs-special-circumstances of Abstracted-Value (criteria special-circumstances) (value YES)  (cf 1.0))
)

(defrule abstract-special-circumstances-no (declare (salience 500))	
	(object (is-a 	Additional-Info) 	(worked-overseas ?cc&~nil) ) 
	(object (is-a 	Norm-Value) 		(criteria worked-overseas) (value ?cc1&:(neq ?cc ?cc1)) )
	(test (neq ?cc ?cc1))	
	=>	
	(make-instance abs-special-circumstances of Abstracted-Value (criteria special-circumstances) (value NO) (cf 1.0))
)


;============================================ 
;IMPECCABLE FINANCES 
;
;This is one of the criterion for 
;determining safe address (Address Verified)
;
;For the case when high-credit-limit and 
;paid-a-lot-of-money is yes yes or no no
;============================================

(defrule abstract-impeccable-finances1 (declare (salience 500))
	(object (is-a Abstracted-Value) (criteria high-credit-limit) (value ?m) (cf ?cf1))
	(object (is-a Abstracted-Value) (criteria paid-a-lot-of-money) (value ?n) (cf ?cf2))
	(test (eq ?m ?n))
	=>	
	(make-instance abs-impeccable-finances of Abstracted-Value 
		(criteria impeccable-finances) 
		(value ?m) 
		(cf (* (min ?cf1 ?cf2) 1.0) )
	)	
)

(defrule abstract-impeccable-finances2 (declare (salience 500))
	(object (is-a Abstracted-Value) (criteria high-credit-limit) (value YES) (cf ?cf1))
	(object (is-a Abstracted-Value) (criteria paid-a-lot-of-money) (value NO) (cf ?cf2))
	=>	
	(make-instance abs-impeccable-finances of Abstracted-Value 
		(criteria impeccable-finances) 
		(value NO) 
		(cf (* ?cf2 1.0) )
	)	
)

(defrule abstract-impeccable-finances3 (declare (salience 500))
	(object (is-a Abstracted-Value) (criteria high-credit-limit) (value NO) (cf ?cf1))
	(object (is-a Abstracted-Value) (criteria paid-a-lot-of-money) (value YES) (cf ?cf2))
	=>	
	(make-instance abs-impeccable-finances of Abstracted-Value 
		(criteria impeccable-finances) 
		(value YES) 
		(cf (* ?cf1 1.0) )
	)	
)

;;==============================================
;; REPAYMENT-ABILITY
;;
;; Abstractions for evaluating repayment ability
;;==============================================

;====================================
;EMPLOYMENT TYPE 
;Abstract from the type of employment
;To whether it is full-time as opposed to
;part-time or contract etc
;=====================================

(defrule abstract-employment-type-yes (declare (salience 500))
	(object (is-a Employment) (emp-type ?emp-type&~nil))
	(object (is-a Norm-Value) (criteria emp-type) 		(value ?emp-type1&:(eq ?emp-type ?emp-type1))	)
	=>
	(make-instance abs-full-time of Abstracted-Value (criteria full-time) (value YES) (cf 1.0) )
)

(defrule abstract-employment-type-no (declare (salience 500))
	(object (is-a Employment) (emp-type ?emp-type&~nil))
	(object (is-a Norm-Value) 	(criteria emp-type) 		(value ?emp-type1&:(neq ?emp-type ?emp-type1))	)
	=>
	(make-instance abs-full-time of Abstracted-Value (criteria full-time) (value NO) (cf 1.0) )
)

;================================ 
;MORE INFORMATION - JOB STABILITY 
;;
;; special abstraction, if we find that the user 
;; has been with his current job for more than sufficient years we will
;; automatically make the necessary instance for job stability

;; check on the employment fact
;; if job stability has not been decided yet
;; we will go ahead and start adding up employment history as they come in
;================================

;; this particular rule is for the first instance

(defrule abstract-job-stability1 (declare (salience 501))
	(object (is-a Employment) (no-of-years ?year&:(> ?year 0)))
	(not (object (is-a Abstracted-Value) (criteria job-stability)))
	=>
	(assert (total-num-of-jobs (gensym*) 1 ?year))
)

;; rule that adds up total-num-of-jobs found

(defrule abstract-job-stability2 (declare (salience 501))
	?p <- (total-num-of-jobs ?instance-num1 ?num-of-jobs1 ?num-of-years1)
	?q <- (total-num-of-jobs ?instance-num2 ?num-of-jobs2 ?num-of-years2)
	(test (neq ?p ?q))
	(not (object (is-a Abstracted-Value) (criteria job-stability)))
	=>
	(retract ?p)
	(retract ?q)
	(assert (total-num-of-jobs (gensym*) (+ ?num-of-jobs1 ?num-of-jobs2) (+ ?num-of-years1 ?num-of-years2)))
)


;; if we find that we have just exceeded the number of years for total-num-of-jobs
;; we check if the number of jobs is less than the criteria
;; we will add the instance job-stability is true

(defrule abstract-job-stability3 (declare (salience 501))
	(object (is-a Norm-Value) (criteria total-jobs) (value ?value1 ?value2))
	(total-num-of-jobs ? ?num-of-jobs&:(<= ?num-of-jobs ?value1) ?num-of-years&:(>= ?num-of-years ?value2))
	(not (object (is-a Abstracted-Value) (criteria job-stability)))
	=>
	(make-instance abs-job-stability of Abstracted-Value (criteria job-stability) (value YES) (cf 0.9) )
)

;; if we find that we have just exceeded the number of years for total-num-of-jobs
;; we check if the number of jobs is more than the criteria
;; we will add the instance job-stability is not true

(defrule abstract-job-stability4 (declare (salience 501))
	(object (is-a Norm-Value) (criteria total-jobs) (value ?value1 ?value2))
	(total-num-of-jobs ? ?num-of-jobs&:(> ?num-of-jobs ?value1) ?num-of-years&:(>= ?num-of-years ?value2))
	(not (object (is-a Abstracted-Value) (criteria job-stability)))
	=>
	(make-instance abs-job-stability of Abstracted-Value (criteria job-stability) (value NO) (cf 0.9) )
)

;Total Jobs must not exceeds 3 jobs within 3 years
;in order to be considered stable
(defrule abstract-job-stability-yes (declare (salience 500))
	(object (is-a 	Additional-Info) 	(total-jobs ?cc&~nil) ) 
	(object (is-a 	Norm-Value) 		(criteria total-jobs) (value ?value1&:(<= ?cc ?value1) ?) )
	=>	
	(make-instance abs-job-stability of Abstracted-Value (criteria job-stability) (value YES) (cf 0.9) )
)

(defrule abstract-job-stability-no (declare (salience 500))
	(object (is-a 	Additional-Info) 	(total-jobs ?cc&~nil) ) 
	(object (is-a 	Norm-Value) 		(criteria total-jobs) (value ?value1&:(> ?cc ?value1) ?) )
	=>	
	(make-instance abs-job-stability of Abstracted-Value (criteria job-stability) (value NO) (cf 0.9) )
)

