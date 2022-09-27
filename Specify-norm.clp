;;==================================================
;; We specify all the norms here
;;==================================================

;;*************************************************
;; Evalation Norms
;;*************************************************

;===============================================================
; Evaluation Norms to determine the basic evaluations
;===============================================================

;Dynamic make-instance - Take knowledge from DB
(deffunction load-norm-knowledge ()
	(open "DB/Knowledge/norm.txt" norm-from-db "r")
	(while (neq (bind ?norm-line (readline norm-from-db)) EOF)
		(bind ?norm-line-from-db
			(explode$ ?norm-line))
		(bind ?criteria-val
			(first$ ?norm-line-from-db))
		(bind ?cf-norm-value
			(rest$ ?norm-line-from-db))
		(bind ?cf-value
			(first$ ?cf-norm-value))
		(bind ?norm-value
			(rest$ ?cf-norm-value))
		(first$ ?cf-norm-value)
		;(println ?norm-line-from-db)
		;(println ?criteria-val)
		;(println ?norm-value)
		;(println ?cf-value)
		(make-instance (sym-cat norm-(gensym*)) of Norm-Value (criteria ?criteria-val) 
					(value ?norm-value) (cf ?cf-value))
		;(println "done")
		
	)
	(close norm-from-db)
)

(defrule load-norm-knowledge-startup (declare (salience 700))
=>
	;======= Create NORM Instances =======
	(load-norm-knowledge)
)


;Statics definstance - Not taking knowledge from DB
;(definstances evaluation-norms-basic

;	;; to evaluate the age
;	(norm-age of Norm-Value (criteria age) (value 18))
;	
;
;	;;in order to evaluate the salary, the following must be abstracted
;	(norm-emp-year 	of Norm-Value (criteria sufficient-years) 	(value 2))
;	(norm-salary 	of Norm-Value (criteria salary) 		(value 2000))
;
;	;;in evalaute repayment-ability
;	(norm-emp-type of Norm-Value (criteria emp-type) (value Full-Time))
;
;	;;to evaluate address verified
;	(norm-address of Norm-Value (criteria address) (value 3))
;	(norm-salary of Norm-Value (criteria paid-a-lot-of-money) (value 5000))
;	(norm-worked-overseas of Norm-Value (criteria worked-overseas) (value YES))
;
;	;;to evaluate financial performance
;	(norm-bank-history of Norm-Value (criteria no-of-transactions) (value 10))
;	(norm-property of Norm-Value (criteria property-value) (value 300000))
;	(norm-credit-limit of Norm-Value (criteria credit-limit) (value 5000))
;	(norm-credit-card of Norm-Value (criteria credit-card) (value YES))
;	(norm-cheque of Norm-Value (criteria cheque) (value YES))
;
;
;	;;misc job stability
;	(norm-total-jobs of Norm-Value (criteria total-jobs) (value 3 3))
;	
;
;)

;====================================================
;Evaluation Norms to determine the value of Financial-Performance
;====================================================

(definstances evaluation-norms-financial-criteria
	(fact-1 of Financial-Criteria 	(credit-card 		YES	) 
					(cheque 		YES	)
					(bank-history		GOOD	)
					(property		YES	)
					(financial-value	HIGH	)
	)
	(fact-2 of Financial-Criteria 	(credit-card 		NO	) 
					(cheque 		YES	)
					(bank-history		GOOD	)
					(property		YES	)
					(financial-value	HIGH	)
	)
	(fact-3 of Financial-Criteria 	(credit-card 		YES	) 
					(cheque 		NO	)
					(bank-history		GOOD	)
					(property		YES	)
					(financial-value	HIGH	)
	)
	(fact-4 of Financial-Criteria 	(credit-card 		NO	) 
					(cheque 		NO	)
					(bank-history		GOOD	)
					(property		YES	)
					(financial-value	MEDIUM	)
	)
	(fact-5 of Financial-Criteria 	(credit-card 		YES	) 
					(cheque 		YES	)
					(bank-history		BAD	)
					(property		YES	)
					(financial-value	MEDIUM	)
	)
	(fact-6 of Financial-Criteria 	(credit-card 		YES	) 
					(cheque 		NO	)
					(bank-history		BAD	)
					(property		YES	)
					(financial-value	MEDIUM	)
	)
	(fact-7 of Financial-Criteria 	(credit-card 		NO	) 
					(cheque 		YES	)
					(bank-history		BAD	)
					(property		YES	)
					(financial-value	MEDIUM	)
	)
	(fact-8 of Financial-Criteria 	(credit-card 		NO	) 
					(cheque 		NO	)
					(bank-history		BAD	)
					(property		YES	)
					(financial-value	MEDIUM	)
	)
	(fact-9 of Financial-Criteria 	(credit-card 		YES	) 
					(cheque 		YES	)
					(bank-history		GOOD	)
					(property		NO	)
					(financial-value	MEDIUM	)
	)
	(fact-10 of Financial-Criteria 	(credit-card 		YES	) 
					(cheque 		NO	)
					(bank-history		GOOD	)
					(property		NO	)
					(financial-value	MEDIUM	)
	)
	(fact-11 of Financial-Criteria 	(credit-card 		NO	) 
					(cheque 		YES	)
					(bank-history		GOOD	)
					(property		NO	)
					(financial-value	MEDIUM	)
	)
	(fact-12 of Financial-Criteria 	(credit-card 		NO	) 
					(cheque 		NO	)
					(bank-history		GOOD	)
					(property		NO	)
					(financial-value	LOW	)
	)
	(fact-13 of Financial-Criteria 	(credit-card 		YES	) 
					(cheque 		YES	)
					(bank-history		BAD	)
					(property		NO	)
					(financial-value	LOW	)
	)
	(fact-14 of Financial-Criteria 	(credit-card 		YES	) 
					(cheque 		NO	)
					(bank-history		BAD	)
					(property		NO	)
					(financial-value	LOW	)
	)
	(fact-15 of Financial-Criteria 	(credit-card 		NO	) 
					(cheque 		YES	)
					(bank-history		BAD	)
					(property		NO	)
					(financial-value	LOW	)
	)
	(fact-16 of Financial-Criteria 	(credit-card 		NO	) 
					(cheque 		NO	)
					(bank-history		BAD	)
					(property		NO	)
					(financial-value	LOW	)
	)
	
)


