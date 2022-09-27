(deftemplate Valid-NRIC (slot nric) (slot dbfilename (default "default.txt")))

(deffunction Abstract-Str-Info (?Str)
	(bind ?index (str-index ":" ?Str))
	(if (neq ?index FALSE) then
		(return (sub-string (+ ?index 2) (str-length ?Str) ?Str))
	else
		(return -1)
	)
)

(deffunction Load-App-RawDB (?Filename)
	(bind ?can-open (open ?Filename RawDB "r"))
	(if ?can-open then
		(printout t "Customer information successfully loaded" crlf)
	else
		(printout t "Unable to load customer information" crlf)
	)
	(bind ?Nemploy 0)
	(while (neq (bind ?x (readline RawDB)) EOF)
		;====Applicant Information=====
		(if (neq (str-index "Name of client:" ?x) FALSE) then
			(send [app] put-app-name (Abstract-Str-Info ?x)))
		(if (neq (str-index "NRIC:" ?x) FALSE) then
			(send [app] put-nric (Abstract-Str-Info ?x)))
		(if (neq (str-index "Age:" ?x) FALSE) then
			(send [app] put-age (string-to-field (Abstract-Str-Info ?x))))

		;===== Present Employment =====
		(if (neq (str-index "Name of current employer:" ?x) FALSE) then
			(send [present-employment] put-emp-name (Abstract-Str-Info ?x))
			(bind ?Nemploy (+ ?Nemploy 1))
		)
		(if (neq (str-index "E1. Occupation:" ?x) FALSE) then
			(send [present-employment] put-occupation (Abstract-Str-Info ?x)))
		(if (neq (str-index "E1. Monthly Salary:" ?x) FALSE) then
			(send [present-employment] put-salary (string-to-field (Abstract-Str-Info ?x))))
		(if (neq (str-index "E1. Type of employment:" ?x) FALSE) then
			(send [present-employment] put-emp-type (string-to-field (Abstract-Str-Info ?x))))
		(if (neq (str-index "E1. Number of years in employment:" ?x) FALSE) then
			(send [present-employment] put-no-of-years (string-to-field (Abstract-Str-Info ?x))))
		;(if (neq (str-index "E1. Overseas Posting:" ?x) FALSE) then
		;	(send [present-employment] put-overseas-posting (string-to-field (Abstract-Str-Info ?x))))
		
		;===== Previous Employment1 =====

;		(if (neq (str-index "Name of previous employer 1:" ?x) FALSE) then
;			(send [previous-employment1] put-emp-name (Abstract-Str-Info ?x))
;			(bind ?Nemploy (+ ?Nemploy 1))
;		)
;		(if (neq (str-index "E2. Occupation:" ?x) FALSE) then
;			(send [previous-employment1] put-occupation (Abstract-Str-Info ?x)))
;		(if (neq (str-index "E2. Monthly Salary:" ?x) FALSE) then
;			(send [previous-employment1] put-salary (string-to-field (Abstract-Str-Info ?x))))
;		(if (neq (str-index "E2. Type of employment:" ?x) FALSE) then
;			(send [previous-employment1] put-emp-type (string-to-field (Abstract-Str-Info ?x))))
;		(if (neq (str-index "E2. Number of years in employment:" ?x) FALSE) then
;			(send [previous-employment1] put-no-of-years (string-to-field (Abstract-Str-Info ?x))))
;		(if (neq (str-index "E2. Overseas Posting:" ?x) FALSE) then
;			(send [previous-employment1] put-overseas-posting (string-to-field (Abstract-Str-Info ?x))))

		;===== Previous Employment2 =====
;		(if (neq (str-index "Name of previous employer 2:" ?x) FALSE) then
;			(send [previous-employment2] put-emp-name (Abstract-Str-Info ?x))
;			(bind ?Nemploy (+ ?Nemploy 1))
;		)
;		(if (neq (str-index "E3. Occupation:" ?x) FALSE) then
;			(send [previous-employment2] put-occupation (Abstract-Str-Info ?x)))
;		(if (neq (str-index "E3. Monthly Salary:" ?x) FALSE) then
;			(send [previous-employment2] put-salary (string-to-field (Abstract-Str-Info ?x))))
;		(if (neq (str-index "E3. Type of employment:" ?x) FALSE) then
;			(send [previous-employment2] put-emp-type (string-to-field (Abstract-Str-Info ?x))))
;		(if (neq (str-index "E3. Number of years in employment:" ?x) FALSE) then
;			(send [previous-employment2] put-no-of-years (string-to-field (Abstract-Str-Info ?x))))
;		(if (neq (str-index "E3. Overseas Posting:" ?x) FALSE) then
;			(send [previous-employment2] put-overseas-posting (string-to-field (Abstract-Str-Info ?x))))
	
		;======= Current Address =======
		(if (neq (str-index "Current Address:" ?x) FALSE) then
			(send [present-address] put-address (Abstract-Str-Info ?x)))
		(if (neq (str-index "A1. Number of years at address:" ?x) FALSE) then
			(send [present-address] put-no-of-years (string-to-field (Abstract-Str-Info ?x))))

		;======= Previous Address =======
;		(if (neq (str-index "Previous Address:" ?x) FALSE) then
;			(send [previous-address] put-address (Abstract-Str-Info ?x)))
;		(if (neq (str-index "A2. Number of years at address:" ?x) FALSE) then
;			(send [previous-address] put-no-of-years (string-to-field (Abstract-Str-Info ?x))))
		
		;======== BANK HISTORY ==========
		(if (neq (str-index "Number of deposit per month:" ?x) FALSE) then
			(send [bank-history-info] put-no-of-deposit (string-to-field (Abstract-Str-Info ?x))))	
		(if (neq (str-index "Number of withdrawal per month:" ?x) FALSE) then
			(send [bank-history-info] put-no-of-withdrawals (string-to-field (Abstract-Str-Info ?x))))
		

		;======== FINANCIAL ==========
		;(if (neq (str-index "Number of bank transaction per month:" ?x) FALSE) then
		;	(send [financial-records] put-no-of-transactions (string-to-field (Abstract-Str-Info ?x))))	
		(if (neq (str-index "Total value of properties:" ?x) FALSE) then
			(send [financial-records] put-property-value (string-to-field (Abstract-Str-Info ?x))))
		(if (neq (str-index "Credit limit:" ?x) FALSE) then
			(send [financial-records] put-credit-limit (string-to-field (Abstract-Str-Info ?x))))
		(if (neq (str-index "Credit cards:" ?x) FALSE) then
			(send [financial-records] put-credit-card (string-to-field (Abstract-Str-Info ?x))))
		(if (neq (str-index "Chequing account:" ?x) FALSE) then
			(send [financial-records] put-cheque (string-to-field (Abstract-Str-Info ?x))))
		
		;======== Loan Information ==========
		(if (neq (str-index "Loan Amount:" ?x) FALSE) then
			(send [loan-info] put-amount (string-to-field (Abstract-Str-Info ?x))))	
		(if (neq (str-index "loan Term (yrs):" ?x) FALSE) then
			(send [loan-info] put-period (string-to-field (Abstract-Str-Info ?x))))

	)
	;(send [app] put-total-jobs ?Nemploy)
	;(send [app] put-worked-overseas (send [present-employment] get-overseas-posting))
	(close RawDB)
	?can-open
)

(deffunction Check-Valid-NRIC (?NRIC)
	(open "DB/Customer/Index.txt" IndexDB "r")
	(bind ?Ret-FileName "default.txt")
	(bind ?NRIC (lowcase (str-cat "" ?NRIC)))
	(while (neq (bind ?x (readline IndexDB)) EOF)
		(bind ?IndexDBStr (explode$ ?x))
		(bind ?Index-NRIC (lowcase (str-cat "" (nth$ 1 ?IndexDBStr))))
		(bind ?Index-FileName (nth$ 2 ?IndexDBStr))
		(if (eq 0 (str-compare ?NRIC ?Index-NRIC)) then
			(bind ?Ret-FileName ?Index-FileName)
		)
	)
	(close IndexDB)
	(return ?Ret-FileName)
)

(deffunction load-customer-rule-function (?nric_val ?dbfilename_val)

	;======= Create Instances =======
	(make-instance app of Applicant)
	(make-instance present-employment of Employment)
	;(make-instance previous-employment1 of Employment)
	;(make-instance previous-employment2 of Employment)
	(make-instance present-address of Address)
	;(make-instance previous-address of Address)
	(make-instance bank-history-info of Bank-Info)
	(make-instance financial-records of Financial)
	(make-instance additional-info of Additional-Info)
	(make-instance loan-info of Loan)
	(bind ?can-open (Load-App-RawDB (str-cat "DB/Customer/" ?dbfilename_val)))
	(return ?can-open)
)


