;;====================================
;; Function to clean up the system
;;====================================

(deffunction cleanup-all ()

	(cleanup-data-structures)
	(cleanup-obtain)
	(retract-simple Valid-NRIC)
	(retract-simple Customer)
	(retract-simple total-num-of-jobs)
)

;;===================================================
;; Initialises and starts the program
;;===================================================

(defrule init (declare (salience 600))
	=>
	(close username-password)
	(close username-customer)
	(close customer-info)
	(close IndexDB)
	(close RawDB)
	(close norm-from-db)
	(printout t 
		"======================================" crlf
		"=" crlf
		"=" crlf
		"= Welcome to the Loans Expert System" crlf
		"=" crlf
		"=" crlf
		"=" crlf
		"=======================================" crlf
		crlf
		crlf
		"Please login to begin" crlf
		crlf
		"If at any point you would like to quit, type q into the prompt and press enter" crlf
		crlf
	)
	(assert (invalid))

)



;;===========================================================
;; Checks on the user name and password
;;===========================================================

(defrule verify-username-password (declare (salience 600))
	(invalid)
	=>
	(bind ?username (ask-question-just-once "Username: "))
	(if (neq ?username nil) then
		(bind ?password (ask-question-just-once "Password: "))
	)
	(if (and 
		(neq ?username nil)
		(neq ?password nil)
		) then
		(open "DB/Admin/user-password.txt" username-password "r")
		(bind ?authenticated 0)
		(while (neq (bind ?username-password-line (readline username-password)) EOF)
			(bind ?username-password-from-db 
				(explode$ ?username-password-line))
			(bind ?username-in-db 
				(nth$ 1 ?username-password-from-db))
			(bind ?password-in-db
				(nth$ 2 ?username-password-from-db))
			(if 
				(and
					(eq ?username ?username-in-db) 
					(eq ?password ?password-in-db)		
				) then
				(bind ?authenticated 1)
				(break)
			)

		)
		(if (eq ?authenticated 0) then
			(printout t "Invalid username/password. Please try again" crlf)
			(reassert invalid)
		else
			(assert (username ?username))
			(assert (main-screen))
		)
		(close username-password)
	)
)

;;==========================================================
;; The screen after the login has been authenticated
;;==========================================================

(defrule main-screen (declare (salience 600))
	(main-screen)
	(username ?username)
	=>
	;; clean up all data

	(bind ?choice (one-to-n-p 3 
		"======================================================" crlf
		"=" crlf
		"=" crlf
		"= MAIN SCREEN" crlf
		"=" crlf
		"=" crlf
		"=======================================================" crlf
		"Hello " ?username crlf
		"What would you like to do today?" crlf
		"1) Review customer for their loan application" crlf
		"2) Check scheduled reviews" crlf
		"3) Exit" crlf
		"Ans: "
	))
	(cleanup-all)
	(if (neq ?choice nil) then
		(if (eq ?choice 1) then
			(reassert input-customer-ic-screen)
		)
		(if (eq ?choice 2) then
			(reassert view-scheduled-reviews-screen)
		)
		(if (eq ?choice 3) then
			(exit)
		)
	)
)

;;========================================================
;; Check on the schedule
;;========================================================

(deffunction check-schedule (?username)
	(open "DB/Admin/user-customer-list.txt" username-customer "r")
	(bind ?schedule-list nil)
	(while (neq (bind ?username-customer-line (readline username-customer)) EOF)
		(bind ?username-customer-from-db
			(explode$ ?username-customer-line))
		(bind ?username-in-db
			(nth$ 1 ?username-customer-from-db))
		(bind ?customer-in-db
			(nth$ 2 ?username-customer-from-db))
		(if (eq ?username-in-db ?username) then
			(if (eq ?schedule-list nil) then
				(bind ?schedule-list (create$ ?customer-in-db))
			else
				(bind ?schedule-list (create$ ?schedule-list ?customer-in-db))
			)
		)
	)
	(close username-customer)
	?schedule-list
)

;;===================================================
;; The scheduled reviews screen
;;===================================================

(defrule view-scheduled-reviews-screen (declare (salience 600))
	(view-scheduled-reviews-screen)
	(username ?username)
	=>
	(bind ?list (check-schedule ?username))
	(if (eq ?list nil) then
		(printout t "You do not have any customers scheduled" crlf)
		(reassert main-screen)
	else
		(printout t "The following are customers assigned to you." crlf
			"Please select a customer to begin the loan verification process" crlf)
		(bind ?choice (choice-1-to-n-with-back ?list))
		(if (neq ?choice nil) then
			(if (or (eq ?choice b)
				(eq ?choice back)) then
				(retract-simple view-scheduled-reviews-screen)
				(reassert main-screen)
			else
					(assert (Customer (nth$ ?choice ?list)))
			)
		)

	)
)

;;====================================================
;; The screen to input the customer IC number directly
;;====================================================

(defrule input-customer-ic-screen (declare (salience 600))
	(input-customer-ic-screen)
	=>
	(bind ?customer-ic (ask-question-just-once "Customer IC Number [type b or back to go back]: " crlf))
	(if (neq ?customer-ic nil) then
		(if (check-back ?customer-ic) then
			(reassert main-screen)
		else
			(assert (Customer ?customer-ic))
		)

	)
)

;;===================================================
;; calling the DB function
;;===================================================

(defrule verify-customer (declare (salience 599))
	?p<- (Customer ?customer-ic)
	=>
	(bind ?FileName (Check-Valid-NRIC ?customer-ic))
	(if (eq ?FileName "default.txt") then
		(printout t "The NRIC number was not found in the database" crlf)
		(retract ?p)
		(reassert input-customer-ic-screen)
	else
		(bind ?can-open (open (str-cat "DB/Customer/" ?FileName) RawDB "r"))
		(if ?can-open then
			(assert (Valid-NRIC (nric ?customer-ic) (dbfilename ?FileName)))
			(reassert ready-to-evaluate-screen)
		else
			(printout t "can open is " ?can-open crlf)
			(reassert main-screen)
		)
		(close RawDB)
	)
)

;;================================================
;; The evaluation screen
;; This screen will appear when everything 
;;================================================

(defrule ready-to-evaluate-screen (declare (salience 600))
	(ready-to-evaluate-screen)
	(Valid-NRIC (nric ?nric_val) (dbfilename ?dbfilename_val))
	=>
	(bind ?choice (one-to-n-p 3
		"This customer has not been verified for their loan application" crlf
		"What would you like to do now?" crlf
		"1) Proceed with evaluating this customer" crlf
		"2) View the customer's information" crlf
		"3) Return to the main screen to pick a new customer" crlf
		"Ans: "
	))
	(cleanup-data-structures)
	(cleanup-obtain)
	(retract-simple Customer)
	(retract-simple total-num-of-jobs)
	(bind ?can-open (load-customer-rule-function ?nric_val ?dbfilename_val))
	(if (eq ?can-open FALSE) then
		(bind ?choice 3)
	)
	(if (neq ?choice nil) then
		(if (eq ?choice 1) then
			(reassert evaluation-screen)
		else
			(if (eq ?choice 2) then
				(reassert print-report)
				(reassert ready-to-evaluate-screen)
			else
				(reassert main-screen)
				(retract-simple Customer)
				(retract-simple Valid-NRIC)
			)
		)
	)
)


;;================================================
;; The special screen that will appear everytime a
;; an execution on the evaluation has run
;; Should alway be the last rule to run
;;================================================

(defrule evaluation-screen (declare (salience -1000))
	(evaluation-screen)
	=>
	(bind ?choice (one-to-n-p 4
		"What would you like to do now?" crlf
		"1) View the executive summary" crlf
		"2) View the customer's inference information" crlf
		"3) View the customer's information" crlf
		"4) Re-evaluate the customer's loan application" crlf
		"5) Return to the main screen to pick a new customer" crlf
		"Ans: "
	))
	(if (neq ?choice nil) then
		(if (eq ?choice 2) then
			(Print-All-Info)
			(reassert evaluation-screen)
		else
			(if (eq ?choice 3) then
				(Print-Only-Customer-Info)
				(reassert evaluation-screen)
			else
				(if (eq ?choice 1) then
					(Print-Only-Executive-Summary)					
					(reassert evaluation-screen)
				else
					(if (eq ?choice 4) then
						(reassert ready-to-evaluate-screen)					else
						(reassert main-screen)
					)
				)
			)
		)

	)

)


(defrule approval-screen1
	(object (is-a Loan) (approved YES))
	=>
	(printout t "The loan has been approved" crlf)

)

(defrule approval-screen2
	(object (is-a Loan) (approved NO))
	=>
	(printout t "The loan has not been approved" crlf)

)


