;;================================================
;; The rules involving the task of re-evaluation
;;================================================

(deffunction cleanup-obtain ()
	(retract-simple obtain-employment-history2)
	(retract-simple obtain-employment-history1)
	(retract-simple obtain-commitments)
	(retract-simple obtain-monthly-expenses)	
	(retract-simple obtain-address)
	(retract-simple obtain-special-circumstance)
	(retract-simple obtain-number-of-previous-jobs)
	(retract-simple terminate-early)
	nil
)

; ===================================
; Special class for compare norms values
; ===================================

(defclass Additional-Data-Norm-Value (is-a USER)
	(role concrete)
	(multislot evaluated-criteria	(create-accessor read-write) (type SYMBOL))
	(multislot evaluated-value	(create-accessor read-write) (type SYMBOL FLOAT))
	(multislot abstracted-criteria (create-accessor read-write) (type SYMBOL) (default nil))
	(multislot abstracted-value	(create-accessor read-write) (type SYMBOL FLOAT) (default nil))
	(slot fact-to-assert (create-accessor read-write) (type SYMBOL))
)

;;****************************************************
;; We specify what sort of situations we will need to
;; call for a re-evaluation by obtain more data
;;****************************************************

(definstances specify-additional-data-norm

	;; if age does not meet requirement, we terminate early
	(additional-data-norm-age of Additional-Data-Norm-Value 
		(evaluated-criteria age) (evaluated-value NO) 
		(fact-to-assert terminate-early)) 

	;; we now look at the whether or not the person is in full time employement
	;; if he is not, we will terminate early
	;; otherwise we will now try to obtain more information on his commitments and expenses
	((sym-cat additional-data-norm-repayment-ability-(gensym*)) of Additional-Data-Norm-Value 
		(evaluated-criteria repayment-ability) (evaluated-value NO) 
		(fact-to-assert terminate-early)) 
	((sym-cat additional-data-norm-repayment-ability-(gensym*)) of Additional-Data-Norm-Value 
		(evaluated-criteria repayment-ability) (evaluated-value YES)
		(fact-to-assert obtain-commitments) )	
	((sym-cat additional-data-norm-repayment-ability-(gensym*)) of Additional-Data-Norm-Value 
		(evaluated-criteria repayment-ability) (evaluated-value YES)
		(fact-to-assert obtain-monthly-expenses))
	((sym-cat additional-data-norm-repayment-ability-(gensym*)) of Additional-Data-Norm-Value 
		(evaluated-criteria repayment-ability) (evaluated-value YES)
		(fact-to-assert obtain-monthly-expenses))

	;; when we get financial performance to be high or medium
	;; we will then ask for job stability
	;; will terminate early when financial performance is low
	;; no need to terminate at job stability, the CF should take care of it

	((sym-cat additional-data-norm-financial-performance-(gensym*)) of Additional-Data-Norm-Value 
		(evaluated-criteria financial-performance) (evaluated-value LOW)
		(fact-to-assert terminate-early))
	((sym-cat additional-data-norm-financial-performance-(gensym*)) of Additional-Data-Norm-Value 
		(evaluated-criteria financial-performance) (evaluated-value HIGH)
		(fact-to-assert obtain-number-of-previous-jobs))
	((sym-cat additional-data-norm-financial-performance-(gensym*)) of Additional-Data-Norm-Value 
		(evaluated-criteria financial-performance) (evaluated-value MEDIUM)
		(fact-to-assert obtain-number-of-previous-jobs))

	;; when we are unable to verify the address, we look for additional
	;; addresses and special circumstances, if needed
	;; if even special circumstances are a no, we terminate early
	((sym-cat additional-data-norm-add-ver-(gensym*)) of Additional-Data-Norm-Value 
		(evaluated-criteria address-verified) (evaluated-value NO) 	
		(abstracted-criteria abstracted-address abstracted-address special-circumstances) (abstracted-value NO NO NO)
		(fact-to-assert terminate-early))
	((sym-cat additional-data-norm-add-ver-(gensym*)) of Additional-Data-Norm-Value 
		(evaluated-criteria address-verified) (evaluated-value NO) 	
		(abstracted-criteria abstracted-address abstracted-address) (abstracted-value NO NO)
		(fact-to-assert obtain-special-circumstance))
	((sym-cat additional-data-norm-add-ver-(gensym*)) of Additional-Data-Norm-Value 
		(evaluated-criteria address-verified) (evaluated-value NO) 	
		(abstracted-criteria abstracted-address) (abstracted-value NO)
		(fact-to-assert obtain-address))

	;; we look at the salary aspects, and ask for more information regarding his employment
	;; if the number of years of employment is the only thing that failed
	;; we will terminate early if he doesn't meet criteria
	((sym-cat additional-data-norm-salary-aspects-(gensym*)) of Additional-Data-Norm-Value 
		(evaluated-criteria  salary-aspects) (evaluated-value NO) 
		(abstracted-criteria abstracted-sufficient-years) (abstracted-value NO)
		(fact-to-assert obtain-employment-history1))
	((sym-cat additional-data-norm-salary-aspects-(gensym*)) of Additional-Data-Norm-Value 
		(evaluated-criteria  salary-aspects) (evaluated-value NO) 
		(abstracted-criteria abstracted-sufficient-years) (abstracted-value NO)
		(fact-to-assert obtain-employment-history2))
	((sym-cat additional-data-norm-salary-aspects-(gensym*)) of Additional-Data-Norm-Value 
		(evaluated-criteria salary-aspects) (evaluated-value NO) 
		(abstracted-criteria meets-estimate) (abstracted-value NO)
		(fact-to-assert terminate-early))
	((sym-cat additional-data-norm-salary-aspects-(gensym*)) of Additional-Data-Norm-Value 
		(evaluated-criteria salary-aspects) (evaluated-value NO) 
		(abstracted-criteria abstracted-sufficient-years abstracted-sufficient-years abstracted-sufficient-years) (abstracted-value NO NO NO)
		(fact-to-assert terminate-early))


)

;;****************************************************
;; The rules involving evaluate
;;****************************************************

;;======================================================
;; Rules for evaluate 
;;======================================================

;;===============================================================
;; If we find an evaluated value that has cf <= 0, 
;; and we have a norm that says no
;; we will assert the obtain fact to find either additional information
;; or we terminate early
;;===============================================================

(defrule obtain-evaluate1a (declare (salience 300))
	(object (is-a Additional-Data-Norm-Value) 
		(evaluated-criteria ?m) (evaluated-value NO)
		(abstracted-criteria nil) (abstracted-value nil)
		(fact-to-assert ?q))
	(object (is-a Evaluated-Value) (criteria ?m) (cf ?cf&:(<= ?cf 0)))
	(object (is-a Loan) (approved nil))
	=>
	(eval (str-cat "(assert (" ?q "))"))

)

(defrule obtain-evaluate1b (declare (salience 301))
	(object (is-a Additional-Data-Norm-Value) 
		(evaluated-criteria ?m) (evaluated-value NO)
		(abstracted-criteria nil) (abstracted-value nil)
		(fact-to-assert terminate-early))
	(object (is-a Evaluated-Value) (criteria ?m) (cf ?cf&:(<= ?cf 0)))
	(object (is-a Loan) (approved nil))
	=>
	(assert (terminate-early))

)

;;===============================================================
;; If we find an evaluated value that has cf < 0, 
;; and we have a norm that says yes
;; we will assert the obtain fact to find either additional information
;; or we terminate early
;;===============================================================

(defrule obtain-evaluate2a (declare (salience 300))
	(object (is-a Additional-Data-Norm-Value) 
		(evaluated-criteria ?m) (evaluated-value YES)
		(abstracted-criteria nil) (abstracted-value nil)
		(fact-to-assert ?q))
	(object (is-a Evaluated-Value) (criteria ?m) (cf ?cf&:(> ?cf 0)))
	(object (is-a Loan) (approved nil))
	=>
	(eval (str-cat "(assert (" ?q "))"))

)

(defrule obtain-evaluate2b (declare (salience 301))
	(object (is-a Additional-Data-Norm-Value) 
		(evaluated-criteria ?m) (evaluated-value YES)
		(abstracted-criteria nil) (abstracted-value nil)
		(fact-to-assert terminate-early))
	(object (is-a Evaluated-Value) (criteria ?m) (cf ?cf&:(> ?cf 0)))
	(object (is-a Loan) (approved nil))
	=>
	(assert (terminate-early))
)

;;===============================================================
;; If we find an evaluated value is neither yes or no
;; and we have a norm that is similar
;; we will assert the obtain fact to find either additional information
;; or we terminate early
;;===============================================================

(defrule obtain-evaluate7a (declare (salience 300))
	(object (is-a Additional-Data-Norm-Value) 
		(evaluated-criteria ?m) (evaluated-value ?n&~YES|~NO)
		(abstracted-criteria nil) (abstracted-value nil)
		(fact-to-assert ?q))
	(object (is-a Evaluated-Value) (criteria ?m) (value ?n))
	(object (is-a Loan) (approved nil))
	=>
	(eval (str-cat "(assert (" ?q "))"))

)

(defrule obtain-evaluate7b (declare (salience 301))
	(object (is-a Additional-Data-Norm-Value) 
		(evaluated-criteria ?m) (evaluated-value ?n&~YES|~NO)
		(abstracted-criteria nil) (abstracted-value nil)
		(fact-to-assert terminate-early))
	(object (is-a Evaluated-Value) (criteria ?m) (cf ?cf&:(<= ?cf 0)))
	(object (is-a Loan) (approved nil))
	=>
	(assert (terminate-early))

)

;;===============================================================
;; If we find an evaluated value that has cf <= 0, 
;; and we have a norm that says no
;; and we have abstracted-values for comparison
;; we will assert the obtain fact to find either additional information
;; or we terminate early
;;===============================================================


(defrule obtain-evaluate3a (declare (salience 300))
	(object (is-a Additional-Data-Norm-Value) 
		(evaluated-criteria ?m) (evaluated-value NO)
		(abstracted-criteria ?r) (abstracted-value ?s)
		(fact-to-assert ?q))
	(object (is-a Evaluated-Value) (criteria ?m) (cf ?cf&:(<= ?cf 0)))
	(object (is-a Abstracted-Value) (criteria ?r) (value ?s))
	(object (is-a Loan) (approved nil))
	=>
	(eval (str-cat "(assert (" ?q "))"))

)

(defrule obtain-evaluate3b (declare (salience 301))
	(object (is-a Additional-Data-Norm-Value) 
		(evaluated-criteria ?m) (evaluated-value NO)
		(abstracted-criteria ?r) (abstracted-value ?s)
		(fact-to-assert terminate-early))
	(object (is-a Evaluated-Value) (criteria ?m) (cf ?cf&:(<= ?cf 0)))
	(object (is-a Abstracted-Value) (criteria ?r) (value ?s))
	(object (is-a Loan) (approved nil))
	=>
	(assert (terminate-early))

)
;;===============================================================
;; If we find an evaluated value that has cf > 0, 
;; and we have a norm that says yes
;; and we have abstracted-values for comparison
;; we will assert the obtain fact to find either additional information
;; or we terminate early
;;===============================================================
 
(defrule obtain-evaluate4a (declare (salience 300))
	(object (is-a Additional-Data-Norm-Value) 
		(evaluated-criteria ?m) (evaluated-value YES)
		(abstracted-criteria ?r) (abstracted-value ?s)
		(fact-to-assert ?q))
	(object (is-a Evaluated-Value) (criteria ?m) (cf ?cf&:(> ?cf 0)))
	(object (is-a Abstracted-Value) (criteria ?r) (value ?s))
	(object (is-a Loan) (approved nil))
	=>
	(eval (str-cat "(assert (" ?q "))"))

)

(defrule obtain-evaluate4b (declare (salience 301))
	(object (is-a Additional-Data-Norm-Value) 
		(evaluated-criteria ?m) (evaluated-value YES)
		(abstracted-criteria ?r) (abstracted-value ?s)
		(fact-to-assert terminate-early))
	(object (is-a Evaluated-Value) (criteria ?m) (cf ?cf&:(> ?cf 0)))
	(object (is-a Abstracted-Value) (criteria ?r) (value ?s))
	(object (is-a Loan) (approved nil))
	=>
	(assert (terminate-early))
)
;;===============================================================
;; If we find an evaluated value that has cf <= 0, 
;; and we have a norm that says no
;; and we have two abstracted-values for comparison
;; we will assert the obtain fact to find either additional information
;; or we terminate early
;;===============================================================


(defrule obtain-evaluate5a (declare (salience 300))
		(object (is-a Additional-Data-Norm-Value) 
		(evaluated-criteria ?m) (evaluated-value NO)
		(abstracted-criteria ?r ?t) (abstracted-value ?s ?u)
		(fact-to-assert ?q))
	(object (is-a Evaluated-Value) (criteria ?m) (cf ?cf&:(<= ?cf 0)))
	?obj1 <- (object (is-a Abstracted-Value) (criteria ?r) (value ?s))
	?obj2 <- (object (is-a Abstracted-Value) (criteria ?t) (value ?u))
	(test (neq ?obj1 ?obj2))
	(object (is-a Loan) (approved nil))
	=>
	(eval (str-cat "(assert (" ?q "))"))

)

(defrule obtain-evaluate5b (declare (salience 301))
		(object (is-a Additional-Data-Norm-Value) 
		(evaluated-criteria ?m) (evaluated-value NO)
		(abstracted-criteria ?r ?t) (abstracted-value ?s ?u)
		(fact-to-assert terminate-early))
	(object (is-a Evaluated-Value) (criteria ?m) (cf ?cf&:(<= ?cf 0)))
	?obj1 <- (object (is-a Abstracted-Value) (criteria ?r) (value ?s))
	?obj2 <- (object (is-a Abstracted-Value) (criteria ?t) (value ?u))
	(test (neq ?obj1 ?obj2))
	(object (is-a Loan) (approved nil))
	=>
	(assert (terminate-early))

)

;;===============================================================
;; If we find an evaluated value that has cf > 0, 
;; and we have a norm that says yes
;; and we have two abstracted-values for comparison
;; we will assert the obtain fact to find either additional information
;; or we terminate early
;;===============================================================

(defrule obtain-evaluate6a (declare (salience 300))
	(object (is-a Additional-Data-Norm-Value) 
		(evaluated-criteria ?m) (evaluated-value YES)
		(abstracted-criteria ?r ?t) (abstracted-value ?s ?u)
		(fact-to-assert ?q))
	(object (is-a Evaluated-Value) (criteria ?m) (cf ?cf&:(> ?cf 0)))
	?obj1 <- (object (is-a Abstracted-Value) (criteria ?r) (value ?s))
	?obj2 <- (object (is-a Abstracted-Value) (criteria ?t) (value ?u))
	(test (neq ?obj1 ?obj2))
	(object (is-a Loan) (approved nil))
	=>
	(eval (str-cat "(assert (" ?q "))"))

)

(defrule obtain-evaluate6b (declare (salience 301))
	(object (is-a Additional-Data-Norm-Value) 
		(evaluated-criteria ?m) (evaluated-value YES)
		(abstracted-criteria ?r ?t) (abstracted-value ?s ?u)
		(fact-to-assert terminate-early))
	(object (is-a Evaluated-Value) (criteria ?m) (cf ?cf&:(> ?cf 0)))
	?obj1 <- (object (is-a Abstracted-Value) (criteria ?r) (value ?s))
	?obj2 <- (object (is-a Abstracted-Value) (criteria ?t) (value ?u))
	(test (neq ?obj1 ?obj2))
	(object (is-a Loan) (approved nil))
	=>
	(assert (terminate-early))
)

;;===============================================================
;; If we find an evaluated value that has cf > 0, 
;; and we have a norm that says yes
;; and we have three abstracted-values for comparison
;; we will assert the obtain fact to find either additional information
;; or we terminate early
;;===============================================================

(defrule obtain-evaluate8a (declare (salience 300))
	(object (is-a Additional-Data-Norm-Value) 
		(evaluated-criteria ?m) (evaluated-value YES)
		(abstracted-criteria ?r ?t ?x) (abstracted-value ?s ?u ?y)
		(fact-to-assert ?q))
	(object (is-a Evaluated-Value) (criteria ?m) (cf ?cf&:(> ?cf 0)))
	?obj1 <- (object (is-a Abstracted-Value) (criteria ?r) (value ?s))
	?obj2 <- (object (is-a Abstracted-Value) (criteria ?t) (value ?u))
	?obj3 <- (object (is-a Abstracted-Value) (criteria ?x) (value ?y))
	(test 
		(and 
			(neq ?obj1 ?obj2)
 			(neq ?obj2 ?obj3)
			(neq ?obj1 ?obj3)
		)
	)
	(object (is-a Loan) (approved nil))
	=>
	(eval (str-cat "(assert (" ?q "))"))

)

(defrule obtain-evaluate8b (declare (salience 301))
	(object (is-a Additional-Data-Norm-Value) 
		(evaluated-criteria ?m) (evaluated-value YES)
		(abstracted-criteria ?r ?t ?x) (abstracted-value ?s ?u ?y)
		(fact-to-assert terminate-early))
	(object (is-a Evaluated-Value) (criteria ?m) (cf ?cf&:(> ?cf 0)))
	?obj1 <- (object (is-a Abstracted-Value) (criteria ?r) (value ?s))
	?obj2 <- (object (is-a Abstracted-Value) (criteria ?t) (value ?u))
	?obj3 <- (object (is-a Abstracted-Value) (criteria ?x) (value ?y))
	(test 
		(and 
			(neq ?obj1 ?obj2)
 			(neq ?obj2 ?obj3)
			(neq ?obj1 ?obj3)
		)
	)
	(object (is-a Loan) (approved nil))
	=>
	(assert (terminate-early))
)

;;===============================================================
;; If we find an evaluated value that has cf < 0, 
;; and we have a norm that says no
;; and we have three abstracted-values for comparison
;; we will assert the obtain fact to find either additional information
;; or we terminate early
;;===============================================================

(defrule obtain-evaluate9a (declare (salience 300))
	(object (is-a Additional-Data-Norm-Value) 
		(evaluated-criteria ?m) (evaluated-value NO)
		(abstracted-criteria ?r ?t ?x) (abstracted-value ?s ?u ?y)
		(fact-to-assert ?q))
	(object (is-a Evaluated-Value) (criteria ?m) (cf ?cf&:(<= ?cf 0)))
	?obj1 <- (object (is-a Abstracted-Value) (criteria ?r) (value ?s))
	?obj2 <- (object (is-a Abstracted-Value) (criteria ?t) (value ?u))
	?obj3 <- (object (is-a Abstracted-Value) (criteria ?x) (value ?y))
	(test 
		(and 
			(neq ?obj1 ?obj2)
 			(neq ?obj2 ?obj3)
			(neq ?obj1 ?obj3)
		)
	)
	(object (is-a Loan) (approved nil))
	=>
	(eval (str-cat "(assert (" ?q "))"))

)

(defrule obtain-evaluate9b (declare (salience 301))
	(object (is-a Additional-Data-Norm-Value) 
		(evaluated-criteria ?m) (evaluated-value NO)
		(abstracted-criteria ?r ?t ?x) (abstracted-value ?s ?u ?y)
		(fact-to-assert terminate-early))
	(object (is-a Evaluated-Value) (criteria ?m) (cf ?cf&:(<= ?cf 0)))
	?obj1 <- (object (is-a Abstracted-Value) (criteria ?r) (value ?s))
	?obj2 <- (object (is-a Abstracted-Value) (criteria ?t) (value ?u))
	?obj3 <- (object (is-a Abstracted-Value) (criteria ?x) (value ?y))
	(test 
		(and 
			(neq ?obj1 ?obj2)
 			(neq ?obj2 ?obj3)
			(neq ?obj1 ?obj3)
		)
	)
	(object (is-a Loan) (approved nil))
	=>
	(assert (terminate-early))
)

;;****************************************************
;; Obtain, to obtain the relevant information that has been proven insufficient
;;****************************************************

;;==========================================================
;; Obtain more information to verify the address. Checking out
;; for another residence
;;==========================================================

(defrule obtain-address (declare (salience 550))
	(obtain-address)

	=>
	(bind ?num-of-years (positive-number-p
		"In your previous residency, how many years did you live there? [Decimal numbers eg 1.5]" crlf))
	(if (neq ?num-of-years nil) then
		(make-instance (sym-cat address-(gensym*)) of Address (no-of-years ?num-of-years))
	else
		(retract-simple obtain-address)
	)
)

;;====================================================================
;; To obtain more information to verify the address. Checking out
;; for special circumstance
;;====================================================================

(defrule obtain-special-circumstance  (declare (salience 550))
	(obtain-special-circumstance)
	=>
	(bind ?yes-no (yes-or-no-p-special
		"During the last couple of years, did you work overseas or did your work require you to travel often? [Y or N]" crlf
	))
	(if (neq ?yes-no nil) then
		(if (eq ?yes-no TRUE) then
			(modify-instance [additional-info] (worked-overseas YES))
		else
			(modify-instance [additional-info] (worked-overseas NO))
		)
	else
		(retract-simple obtain-special-circumstance)
	)

)

;;=======================================================
;; Obtain more regarding job stability
;; which can be found through the number of previous jobs
;; Due to a change, the number of years have been made
;; variable
;;=======================================================

(defrule obtain-number-of-previous-jobs (declare (salience 550))
	(obtain-number-of-previous-jobs)
	(object (is-a Norm-Value) (criteria total-jobs) (value ? ?value2))
	(not (object (is-a Abstracted-Value) (criteria job-stability)))
	=>
	(bind ?num-of-previous-jobs (positive-integer-more-than-one-p 
		"What is the number of previous jobs you have had in the last " ?value2 " years? " crlf 
		"Please include the current job into the count. [Whole numbers, eg 2]" crlf))
	(if (neq ?num-of-previous-jobs nil) then
		(modify-instance [additional-info] (total-jobs ?num-of-previous-jobs))
	else
		(retract-simple obtain-number-of-previous-jobs)
	)
)

;;=======================================================
;; Obtain the monthly expenses 
;;=======================================================

(defrule obtain-monthly-expenses  (declare (salience 550))
	(obtain-monthly-expenses)
	=>
	(bind ?monthly-expenses (positive-number-p "What is your current monthly expenses? [Decimal numbers, eg 1.5]" crlf))
	(if (neq ?monthly-expenses nil) then	
		(modify-instance [additional-info] (monthly-expenses ?monthly-expenses))
	else
		(retract-simple obtain-monthly-expenses)
	)
)

;;=======================================================
;; Obtain the monthly commitments
;;=======================================================

(defrule obtain-commitments  (declare (salience 550))

	(obtain-commitments)
	=>
	(bind ?yes-no (yes-or-no-p-special "Do you have any monthly commitments, like for example another loan? [Y or N]" crlf))
	(if (neq ?yes-no nil) then
		(if ?yes-no then	

			(bind ?commitments (positive-number-p "What is this monthly commitment? [Decimal numbers, eg 1.5]?" crlf))
			(if (neq ?commitments nil) then	
				(modify-instance [additional-info] (commitments ?commitments))
			)
		else
			(modify-instance [additional-info] (commitments 0))
			
		)
	else
		(retract-simple obtain-commitments)
	)
)

;;========================================================
;; Obtain the previous employment history
;; Get the number of years
;;========================================================

(defrule obtain-employment-history1  (declare (salience 550))
	(obtain-employment-history1)
	=>
	(bind ?prev-emp-num-of-years (positive-number-p "How many years were you with your previous company? [Decimal numbers, eg 1.5]" crlf))
	(if (neq ?prev-emp-num-of-years nil) then	
		(make-instance prev1-employment of Employment (no-of-years  ?prev-emp-num-of-years))
	else
		(retract-simple obtain-employment-history1)
	)
)

;;========================================================
;; Obtain the previous previous employment history
;; Get the number of years
;;========================================================

(defrule obtain-employment-history2  (declare (salience 550))
	(obtain-employment-history2)
	=>
	(bind ?prev-emp-num-of-years (positive-number-p "How many years were you with your previous previous company? [Decimal numbers, eg 1.5]" crlf))
	(if (neq ?prev-emp-num-of-years nil) then	
		(make-instance prev2-employment of Employment (no-of-years  ?prev-emp-num-of-years))
	else
		(retract-simple obtain-employment-history2)
	)
)
