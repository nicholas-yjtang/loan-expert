(defglobal ?*addr_count* = 1)
(defglobal ?*emp_count* = 1)

(deffunction Print-App-Info ()
	(printout t "== General Particular ===========" crlf)
	(do-for-instance ((?app Applicant)) (neq ?app:app-name nil)
		(printout t "Name of client: " ?app:app-name crlf
				"NRIC: " ?app:nric crlf
				"Age: " ?app:age crlf)
	) 
	(printout t crlf)
)

(deffunction Print-Address-Info ()
	(printout t "== Address Details ==============" crlf)
	(do-for-all-instances ((?addr Address)) (neq 0 (str-length ?addr:address))
		(printout t "Address: " ?addr:address crlf
				"Number of years at address: " ?addr:no-of-years crlf)
	) 
	(printout t crlf)
)

(deffunction Printout-Pre-Address (?no-of-yrs)
	(printout t "== Previous Address " ?*addr_count* " ==" crlf)
	(printout t "Number of years at this address: " ?no-of-yrs crlf crlf)
	(bind ?*addr_count* (+ ?*addr_count* 1))
)

(deffunction Print-Pre-Address-Info ()
	(do-for-all-instances ((?addr Address)) (and (neq ?addr:no-of-years 0) (eq 0 (str-length ?addr:address)))
		(Printout-Pre-Address ?addr:no-of-years)
	) 
	(printout t crlf)
)



(deffunction Print-Employment-Info ()
	(printout t "== Employment Details ===========" crlf)
	(do-for-all-instances ((?emp Employment)) (neq ?emp:emp-type nil)
		(printout t "Name of employer: " ?emp:emp-name crlf
				"Occupation: " ?emp:occupation crlf
				"Monthly Salary: " ?emp:salary crlf
				"Type of employment: " ?emp:emp-type crlf
				"Number of years in employment: " ?emp:no-of-years crlf)
	) 
	(printout t crlf)
)

(deffunction Printout-Pre-Employment (?no-of-yrs)
	(printout t "== Previous Employment " ?*emp_count* " ==" crlf)
	(printout t "Years of stay at this Employment: " ?no-of-yrs crlf crlf)
	(bind ?*emp_count* (+ ?*emp_count* 1))
)

(deffunction Print-Pre-Employment-Info ()
	(do-for-all-instances ((?emp Employment)) (and (neq ?emp:no-of-years 0) (eq ?emp:emp-type nil))
		(Printout-Pre-Employment ?emp:no-of-years)
	) 
	(printout t crlf)
)



(deffunction Print-Bank-Info ()
	(printout t "== Bank Account History =========" crlf)
	(do-for-instance ((?bank Bank-Info)) TRUE
		(printout t "Number of Deposits: " ?bank:no-of-deposit crlf
				"Number of Withdrawals: " ?bank:no-of-withdrawals crlf)
	) 
	(printout t crlf)
)

(deffunction Print-Financial-Info ()
	(printout t "== Financial History ============" crlf)
	(do-for-instance ((?fin Financial)) TRUE
		(printout t "Number of bank transaction per month: " ?fin:no-of-transactions crlf
				"Credit cards: " ?fin:credit-card crlf 
				"Credit limit: " ?fin:credit-limit crlf
				"Total value of properties: " ?fin:property-value crlf 
				"Chequing account: " ?fin:cheque crlf)
	) 
	(printout t crlf)
)

(deffunction Print-Additional-Info ()
	(printout t "== Additional Information =======" crlf)
	(do-for-instance ((?add Additional-Info)) TRUE
		(printout t "Worked overseas: " ?add:worked-overseas crlf
				"Total number of jobs: " ?add:total-jobs crlf 
				"Monthly Expenses: " ?add:monthly-expenses crlf
				"Commitments: " ?add:commitments crlf)
	) 
	(printout t crlf)
)

(deffunction Print-Loan-Info ()
	(printout t "== Loan Details =================" crlf)
	(do-for-instance ((?loan Loan)) TRUE
		(printout t "Amount: " ?loan:amount crlf
				"Term: " ?loan:period crlf 
				"Interest rate: " ?loan:interest-rate crlf
				"Monthly Repayment: " ?loan:monthly-repayment crlf
				"Monthly Repayment with interest: " ?loan:monthly-repayment-with-interest crlf
				"Approval Status: " ?loan:approved crlf)
	) 
	(printout t crlf)
)

(deffunction Print-Loan-Amount-Info ()
	(printout t "== Loan Details =================" crlf)
	(do-for-instance ((?loan Loan)) TRUE
		(printout t "Amount: " ?loan:amount crlf
				"Term: " ?loan:period crlf)
	) 
	(printout t crlf)
)

(deffunction Print-Inference-Value (?class ?title)
	(printout t ?title crlf)
	(do-for-all-instances ((?abs ?class)) TRUE
		(printout t "Criteria: " ?abs:criteria ";  "
				"Value: " ?abs:value ";  "
				"CF: " ?abs:cf crlf)
	) 
	(printout t crlf)
)

(deffunction Print-Norm-Value (?class ?title)
	(printout t ?title crlf)
	(do-for-all-instances ((?class Norm-Value)) TRUE
		(printout t "Criteria: " ?class:criteria ";  "
				"Value: " ?class:value crlf)
	) 
	(printout t crlf)
)


(deffunction Print-All-Info ()
	(bind ?*emp_count* 1)
	(bind ?*addr_count* 1)
	;(printout t crlf "******* Final Report of Loan Application ****************" crlf crlf);
	;(Print-App-Info)
	;(Print-Address-Info)
	;(Print-Pre-Address-Info)
	;(Print-Employment-Info)
	;(Print-Pre-Employment-Info)
	;(Print-Bank-Info)
	;(Print-Financial-Info)
	;(Print-Additional-Info)
	;(Print-Loan-Info)
	(printout t crlf "******* Inference Process and Stage Report **************" crlf crlf)
	(Print-Inference-Value Abstracted-Value "====== Abstracted Criteria & Values ======")
	;(Print-Norm-Value Norm-Value "========== Norm Criteria & Values ========")
	;(Print-Norm-Value Compare-Norm-Value "====== Compare Norm Criteria & Values ====")
	(Print-Inference-Value Evaluated-Value "====== Evaluated Criteria & Values =======")
	
)

(deffunction Print-Only-Customer-Info ()
	(bind ?*emp_count* 1)
	(bind ?*addr_count* 1)
	(printout t crlf "*************** Customer Details ****************" crlf crlf);
	(Print-App-Info)
	(Print-Address-Info)
	(Print-Pre-Address-Info)
	(Print-Employment-Info)
	(Print-Pre-Employment-Info)
	;(Print-Bank-Info)
	(Print-Financial-Info)
	;(Print-Additional-Info)
	(Print-Loan-Amount-Info)	
)

(defrule print-report (declare (salience 601))
	(print-report)
=>
	;Don't print everything
	;(Print-All-Info)
	(Print-Only-Customer-Info)
	
)

