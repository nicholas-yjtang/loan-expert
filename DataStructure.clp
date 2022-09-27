; ============================================================
; Superclass to store the CF of abstracted and evaluated value
; ============================================================
(defclass CF (is-a USER)
	(role concrete)
	
	(slot cf		(create-accessor read-write) (type FLOAT) (default 1.0))
)

; =====================================
; Store Applicant's Generic Information
; =====================================
(defclass Applicant (is-a USER)
	(role concrete)
	
	(slot app-name		(create-accessor read-write) (type STRING))
	(slot nric 		(create-accessor read-write) (type STRING))
	(slot age		(create-accessor read-write) (type FLOAT))
)

; ========================================
; Store Applicant's employment information
;
; There will be multiple instances, such as
; Present employment
; Previous employment
; Previous previous employment
; ========================================
(defclass Employment (is-a USER)
	(role concrete)
	
	(slot emp-name		(create-accessor read-write) (type STRING))
	(slot occupation 	(create-accessor read-write) (type STRING))
	(slot salary		(create-accessor read-write) (type FLOAT))
	(slot emp-type		(create-accessor read-write) (type SYMBOL))
	(slot no-of-years	(create-accessor read-write) (type FLOAT))
)

; ========================================
; Store Applicant's residential information
;
; There will be multiple instances, such as
; Present address
; Previous address
; ========================================
(defclass Address (is-a USER)
	(role concrete)
	
	(slot address		(create-accessor read-write) (type STRING))
	(slot no-of-years	(create-accessor read-write) (type FLOAT))
)

; ========================================
; Bank-Info is a class on its own to cater for multiple accounts under 1 Applicant.
; ========================================
(defclass Bank-Info (is-a USER)
	(role concrete)
	
	(slot no-of-deposit	(create-accessor read-write) (type INTEGER))
	(slot no-of-withdrawals	(create-accessor read-write) (type INTEGER))
)

; =====================================
; Store Applicant's Financial Information
; =====================================
(defclass Financial (is-a USER)
	(role concrete)
	
	(slot no-of-transactions	(create-accessor read-write) (type SYMBOL INTEGER))
	(slot property-value		(create-accessor read-write) (type SYMBOL FLOAT))
	(slot credit-limit		(create-accessor read-write) (type SYMBOL FLOAT))
	(slot credit-card		(create-accessor read-write) (type SYMBOL))
	(slot cheque			(create-accessor read-write) (type SYMBOL))
	
)

; =====================================
; Store Applicant's Additional Information
; =====================================
(defclass Additional-Info (is-a USER)
	(role concrete)
	
	(slot worked-overseas	(create-accessor read-write) (type SYMBOL)	)
	(slot total-jobs	(create-accessor read-write) (type SYMBOL INTEGER))
	(slot monthly-expenses	(create-accessor read-write) (type FLOAT)	 (default -1.0))
	(slot commitments	(create-accessor read-write) (type FLOAT)	 (default -1.0))
)

; =====================================
; Store Applicant's Loan Information
; =====================================
(defclass Loan (is-a USER)
	(role concrete)
	
	(slot amount				(create-accessor read-write) (type FLOAT)	)
	(slot period				(create-accessor read-write) (type FLOAT)	)
	(slot interest-rate			(create-accessor read-write) (type FLOAT)	)
	(slot monthly-repayment			(create-accessor read-write) (type FLOAT)	)
	(slot monthly-repayment-with-interest	(create-accessor read-write) (type FLOAT)	)
	(slot approved				(create-accessor read-write) (type SYMBOL)	)	
)



; =============================
; Store all the abstrated cases
; =============================
(defclass Abstracted-Value (is-a CF)
	(role concrete)
	
	(slot criteria	(create-accessor read-write) (type SYMBOL))
	(slot value	(create-accessor read-write) (type SYMBOL FLOAT))
	
)

; ===================================
; Store all the Knowledge / Criterion
; ===================================
(defclass Norm-Value (is-a CF)
	(role concrete)
	
	(slot criteria		(create-accessor read-write) 	(type SYMBOL))
	(multislot value	(create-accessor read-write) 	(type SYMBOL FLOAT))
)



; ==============================================================
; Store all the evaluation results (Refer to Chapter 6 Page 135)
; Evaluation results += norm-value
; ==============================================================

(defclass Evaluated-Value (is-a CF)
	(role concrete)
	
	(slot criteria	(create-accessor read-write) (type SYMBOL))
	(slot value	(create-accessor read-write) (type SYMBOL))
)



;==========================================================
;Structure for Financial Performance Rules
;Purpose : To represent the rules for financial performance
;	 : (HIGH / MEDIUM / LOW)
;==========================================================
(defclass Financial-Criteria (is-a USER)
	(role concrete)
	
	(multislot credit-card		(create-accessor read-write) (type SYMBOL FLOAT))
	(multislot cheque		(create-accessor read-write) (type SYMBOL FLOAT))
	(multislot bank-history		(create-accessor read-write) (type SYMBOL FLOAT))
	(multislot property		(create-accessor read-write) (type SYMBOL FLOAT))
	(multislot financial-value	(create-accessor read-write) (type SYMBOL FLOAT))
)

;=====================================================
;Structure for Executive Summary Messages
;Purpose : To store the explanations on rejected loans
;
;Capture the evaluated criteria that has CF < 0
;======================================================
(defclass Message-Evaluation (is-a USER)
	(role concrete)
	
	(slot criteria	(create-accessor read-write) (type STRING))
	(slot value	(create-accessor read-write) (type STRING))
)

;=====================================================
;Structure for Executive Summary Messages
;Purpose : To store the explanations on rejected loans
;
;Capture the abstracted criteria that has CF < 0
;This is only for evaluated criteria that has few criterion under it,
;such as financial performance, address, employment, etc
;======================================================
(defclass Message-Abstraction (is-a USER)
	(role concrete)
	
	(slot evaluated-criteria	(create-accessor read-write) (type STRING))
	(slot abstracted-criteria	(create-accessor read-write) (type STRING))
	(slot value			(create-accessor read-write) (type STRING))
)


;;===================================================
;; Function to clean up dynamic data, not
;; static data that might be needed again
;;===================================================

(deffunction cleanup-data-structures ()
	(do-for-all-instances ((?class Evaluated-Value)) TRUE
		(send ?class delete)
	)
	(do-for-all-instances ((?class Abstracted-Value)) TRUE
		(send ?class delete)
	)


	(do-for-all-instances ((?class Applicant)) TRUE
		(send ?class delete)
	)
	(do-for-all-instances ((?class Employment)) TRUE
		(send ?class delete)
	)
	(do-for-all-instances ((?class Address)) TRUE
		(send ?class delete)
	)
	(do-for-all-instances ((?class Bank-Info)) TRUE
		(send ?class delete)
	)
	(do-for-all-instances ((?class Additional-Info)) TRUE
		(send ?class delete)
	)
	(do-for-all-instances ((?class Loan)) TRUE
		(send ?class delete)
	)
	(do-for-all-instances ((?class Financial)) TRUE
		(send ?class delete)
	)
	(do-for-all-instances ((?class Message-Evaluation)) TRUE
		(send ?class delete)
	)
	(do-for-all-instances ((?class Message-Abstraction)) TRUE
		(send ?class delete)
	)
	nil
)
