;;*************************************
;; Template for data
;;*************************************

(deftemplate data
	(slot data)
	(slot certainty-factor)
)

(deftemplate cf-range
	(slot data)
	(slot lower-bound)
	(slot upper-bound)
	(slot certainty-factor)
)

;;*****************************************
;; special function to reassert a fact
;;******************************************

(deffunction reassert ($?fact)
	;; assuming the first incoming is always the name of the fact
	;;(printout t "first is " (first$ ?fact))
	(do-for-fact
		((?p (first$ ?fact)))
		(retract ?p)
	)
	(bind ?factstring (implode$ ?fact))
	(bind ?assertstring (str-cat "(assert (" ?factstring "))"))
	(eval ?assertstring)
	;;(printout t "going to assert new fact" $?fact)
	(return TRUE)
)


;;**************************************
;; General functions for
;; input validation
;;**************************************

(deffunction special-print ($?question)
	(printout t 
		;; "[Q or QUIT to quit]" crlf
		$?question
		;; "Answer: "
	)
)

;;*****************************************
;; Gives a rating for the CF
;;*****************************************

(deffunction rate-cf (?cf)
	(if (> ?cf 0.8) then
		(return "Very Good")
	)
	(if (and (> ?cf 0.5) (<= ?cf 0.8)) then
		(return "Good")
	)
	(if (and (> ?cf -0.5) (<= ?cf 0.5)) then
		(return "Neutral")
	)
	(if (and (> ?cf -0.8) (<= ?cf -0.5)) then
		(return "Bad")
	)
	(if (and (>= ?cf -1) (<= ?cf -0.8)) then
		(return "Very Bad")
	)
)

;;*****************************************
;; Checks on the quit
;;*****************************************

(deffunction check-quit (?answer)
	(if (lexemep ?answer) then
		(bind ?answer (lowcase ?answer))
		(if (or (eq ?answer q) (eq ?answer quit)) then

			(while TRUE do
				(printout t "Are you sure you want to quit? [Y or N]" crlf)
				(bind ?answer (read))
				(if (lexemep ?answer) then
					(bind ?answer (lowcase ?answer))
				)
				(if (or (eq ?answer y) (eq ?answer yes)) then
					(halt)
					(return TRUE)
				)
				(if (or (eq ?answer n) (eq ?answer no)) then
					(return FALSE)
				)
				(printout t "Please enter Y or N" crlf)
			)
		)
	)
	(return FALSE)

)

;;*****************************************
;; Checks on the stop
;;*****************************************

(deffunction check-stop (?answer)
	(if (lexemep ?answer) then
		(bind ?answer (lowcase ?answer))
		(if (or (eq ?answer s) (eq ?answer stop)) then

			(while TRUE do
				(printout t "Are you sure you want to stop? You will return to the main screen [Y or N]" crlf)
				(bind ?answer (read))
				(if (lexemep ?answer) then
					(bind ?answer (lowcase ?answer))
				)
				(if (or (eq ?answer y) (eq ?answer yes)) then
					(reassert main-screen)
					(return TRUE)
				)
				(if (or (eq ?answer n) (eq ?answer no)) then
					(return FALSE)
				)
				(printout t "Please enter Y or N" crlf)
			)
		)
	)
	(return FALSE)

)

;;*****************************************
;; Checks on the restart
;;*****************************************

(deffunction check-restart (?answer)
	(if (lexemep ?answer) then
		(bind ?answer (lowcase ?answer))
		(if (or (eq ?answer r) (eq ?answer restart)) then

			(while TRUE do
				(printout t "Are you sure you want to restart the inferencing?" crlf 
					"All prior inferences you have made will be lost [Y or N]" crlf)
				(bind ?answer (read))
				(if (lexemep ?answer) then
					(bind ?answer (lowcase ?answer))
				)
				(if (or (eq ?answer y) (eq ?answer yes)) then
					(reassert ready-to-evaluate-screen)
					(return TRUE)
				)
				(if (or (eq ?answer n) (eq ?answer no)) then
					(return FALSE)
				)
				(printout t "Please enter Y or N" crlf)
			)
		)
	)
	(return FALSE)

)

;;*******************************************
;; checks and prints out the inferences
;;*******************************************

(deffunction check-print (?answer)
	(if (lexemep ?answer) then
		(bind ?answer (lowcase ?answer))
		(if (or (eq ?answer p) (eq ?answer print)) then
			(Print-Inference-Value Abstracted-Value "====== Abstracted Criteria & Values ======")
			(Print-Inference-Value Evaluated-Value "====== Evaluated Criteria & Values =======")
			(return TRUE)
		)
	)
	(return FALSE)

)

;;*******************************************
;; checks and prints out the help
;;*******************************************

(deffunction check-help (?answer)
	(if (lexemep ?answer) then
		(bind ?answer (lowcase ?answer))
		(if (or (eq ?answer h) (eq ?answer help)) then
			(printout t 
			"===================================================" crlf
			"=		HELP INFORMATION" crlf
			"=" crlf
			"= Type h or help to print this help information" crlf
			"= Type p or print to print the inference information of the customer" crlf
			"= Type s or stop to stop the reference and return to the main screen" crlf
			"= Type r or restart to restart the current inference" crlf
			"= Type q or quit to quit the program" crlf
			"===================================================" crlf

			)
			(return TRUE)
		)
	)
	(return FALSE)
)
;;*****************************************
;; Checks if the user typed in back
;;*****************************************

(deffunction check-back (?answer)
	(if (lexemep ?answer) then
		(bind ?answer (lowcase ?answer))
		(if (or (eq ?answer b) (eq ?answer back)) then
			(return TRUE)
		)
	)
	(return FALSE)
)

;;===========================================================================
;; To ask the question just once, without regard
;; to validation
;; @param question The question that will be asked to the user of the system
;; @return the value that was typed in by the user. 
;;	nil if he pressed quit
;;	back if he pressed back
;;===========================================================================

(deffunction ask-question-just-once ($?question)
	(special-print ?question)
	(bind ?answer (read))
	(if (lexemep ?answer) then 
		(bind ?answer (lowcase ?answer))
		(if (check-quit ?answer) then
			(return nil)
		)
	)
	?answer
)

;;================================================
;; To ask the question just once, without regard
;; to validation
;;================================================

(deffunction ask-question (?question $?allowed-values)
	(special-print $?question)
	(bind ?answer (read))
	(if (lexemep ?answer) then 
		(bind ?answer (lowcase ?answer))
		(if (check-quit ?answer) then
			(return nil)
		)
	)
	(while (not (member$ ?answer ?allowed-values)) do
		(printout t "You have typed in an erroneous input." crlf)
		(special-print $?question)
		(bind ?answer (read))
		(if (lexemep ?answer) then 
			(bind ?answer (lowcase ?answer))
			(if (check-quit ?answer) then
				(return nil)
			)
		)
	)
	?answer
)

;;============================================================
;; specifically for yes/no answers
;;============================================================

(deffunction yes-or-no-p ($?question)
	(bind ?response (ask-question ?question yes no y n))
	(if (or (eq ?response yes) (eq ?response y)) then 
		(return TRUE)
	else
		(if (eq ?response nil) then
			(return nil)
		else
			(return FALSE)
		)
	)
)



;;============================================================
;; specifically for yes/no answers with print or help functions
;;============================================================

(deffunction yes-or-no-p-special ($?question)
	(bind ?response (ask-question ?question yes no y n h help p print s stop r restart))
	(if (or (eq ?response yes) (eq ?response y)) then 
		(return TRUE)
	else
		(if (eq ?response nil) then
			(return nil)
		else
			(if (or (eq ?response h) (eq ?response help)) then
				(check-help ?response)			
				(return (yes-or-no-p-special $?question ))
			else

				(if (or (eq ?response p) (eq ?response print)) then
					(check-print ?response)
					(return (yes-or-no-p-special $?question))
				else
					(if (or (eq ?response s) (eq ?response stop)) then
						(check-stop ?response)
						(return nil)
					else
						(if (or (eq ?response r) (eq ?response restart)) then
							(check-restart ?response)
							(return nil)
						else
							(return FALSE)
						)
					)
				)
			)

		)
	)
)

(deffunction create-numbers-1-to-n (?n)
	(bind ?count 1)
	(bind ?list 1)
	(while (< ?count ?n)
		(bind ?count (+ ?count 1))
		(bind ?list (create$ ?list ?count))

	)
	?list
)
;;================================================================
;; Function to list 1 - n choices, based on the multifield given
;; And force the user to back a choice
;;================================================================

(deffunction choice-1-to-n (?choice-list ?allowable-values)
	(bind ?list nil)
	(bind ?choice-list-length (+ (length$ ?choice-list) 1))
	(bind ?count 1)
	(while (neq ?choice-list-length ?count)
		(if (eq ?list nil) then
			(bind ?list (create$ ?count ") " (first$ ?choice-list) crlf ))
		else
			(bind ?list (create$ ?list ?count ") " (first$ ?choice-list) crlf))
		)
		(bind ?choice-list (rest$ ?choice-list))
		(bind ?count (+ ?count 1))

	)
	(bind ?allowable-values (create$ ?allowable-values
		(create-numbers-1-to-n (- ?choice-list-length 1))))
	(bind ?choice (ask-question ?list ?allowable-values))
	?choice
)

;;================================================================
;; Function to list 1 - n choices, based on the multifield given
;; And force the user to back a choice
;; There is a special add on, where if the choice is not a number
;; and it is a 'b' or 'back', we let it through
;;================================================================

(deffunction choice-1-to-n-with-back (?choice-list)
	(bind ?list nil)
	(bind ?choice-list-length (+ (length$ ?choice-list) 1))
	(bind ?count 1)
	(while (neq ?choice-list-length ?count)
		(if (eq ?list nil) then
			(bind ?list (create$ ?count ") " (first$ ?choice-list) crlf ))
		else
			(bind ?list (create$ ?list ?count ") " (first$ ?choice-list) crlf))
		)
		(bind ?choice-list (rest$ ?choice-list))
		(bind ?count (+ ?count 1))

	)
	(bind ?allowable-values (create$ b back
		(create-numbers-1-to-n (- ?choice-list-length 1))))
	(bind ?choice (ask-question 
		(create$ ?list crlf "[Type b or back to go back to the previous screen]: ") 
		?allowable-values))
	?choice
)

;; specifically for numbers

(deffunction number-p ($?question)
	(while TRUE do
		(special-print $?question)
		(bind ?answer (read))
		(if (numberp ?answer) then
			(return ?answer)
		)
		(if (lexemep ?answer) then 
			(bind ?answer (lowcase ?answer))
			(if (check-quit ?answer) then
				(return nil)
			)
		)
	)
)

;; specifically for positive numbers

(deffunction positive-number-p ($?question)
	(while TRUE do
		(special-print $?question)
		(bind ?answer (read))
		(if (numberp ?answer) then
			(if (>= ?answer 0) then
				(return ?answer)
			else
				(printout t "Please input a positive number" crlf)
			)
		)
		(if (lexemep ?answer) then 
			(bind ?answer (lowcase ?answer))
			(if (or
				(check-quit ?answer)
				(check-stop ?answer)
				(check-restart ?answer)
				)
				then
				(return nil)
			else
				(if (not 
					(or 
						(check-print ?answer)
						(check-help ?answer)
					)) then
					(printout t "Please enter a positive number" crlf)
				)
			)
		)
	)
)

;; specifically for positive integers more than 1

(deffunction positive-integer-more-than-one-p ($?question)
	(while TRUE do
		(special-print $?question)
		(bind ?answer (read))
		(if (integerp ?answer) then
			(if (>= ?answer 1) then
				(return ?answer)
			else
				(printout t "Please input a positive number larger than 1" crlf)
			)
		)
		(if (lexemep ?answer) then 
			(bind ?answer (lowcase ?answer))
			(if (or
				(check-stop ?answer)
				(check-quit ?answer)
				(check-restart ?answer)
				) then
				(return nil)
			else
				(if (not 
					(or 
						(check-print ?answer)
						(check-help ?answer)
					)) then
					(printout t "Please enter a positive number larger than 1" crlf)
				)
			
			)
		)
	)
)


;; function to check on floats

(deffunction positive-float-p ($?question)
	(while TRUE do
		(special-print $?question)
		(bind ?answer (read))
		(if (floatp ?answer) then
			(if (>= ?answer 0) then
				(return ?answer)
			else
				(printout t "Please enter a positive number" crlf)
			)

		)
		(if (lexemep ?answer) then 
			(bind ?answer (lowcase ?answer))
			(if (check-quit ?answer) then
				(return nil)
			else
				(printout t "Please enter a positive number" crlf)
			)
		)
	)
)

;; specifically for percentages, between 0-100

(deffunction percentage-p ($?question)
	(while TRUE do
		(special-print $?question)
		(bind ?answer (read))
		(if (and 
			(numberp ?answer)
			(<= ?answer 100)
			(>= ?answer 0)
			) then
			(return ?answer)
		)
		(if (lexemep ?answer) then 
			(bind ?answer (lowcase ?answer))
			(if (check-quit ?answer) then
				(return nil)
			)
		)
	)
)

;; for integer numbers 1 to 10. Usually a rating system of sorts

(deffunction one-to-ten-p ($?question)
	(bind ?response (ask-question ?question 1 2 3 4 5 6 7 8 9 10))
	(return ?response)
)

;; for general numbers 1 to n

(deffunction one-to-n-p (?count $?question)
	(bind ?input "")
	(while (<> ?count 0) do
		(bind ?input (str-cat ?count " " ?input))
		(bind ?count (- ?count 1))
	)
	(bind ?response (ask-question ?question (explode$ ?input)))
	(return ?response)
)

;; for letters a to f

(deffunction a-to-f-p ($?question)
	(bind ?response (ask-question ?question a b c d e f))
	(return ?response)
)

;; for letters A to E

(deffunction a-to-e-p ($?question)
	(bind ?response (ask-question ?question a b c d e))
	(return ?response)
)

;; for letters A to D

(deffunction a-to-d-p ($?question)
	(bind ?response (ask-question ?question a b c d))
	(return ?response)
)

;;for letters A to C

(deffunction a-to-c-p ($?question)
	(bind ?response (ask-question ?question a b c))
	(return ?response)
)

;;for letters A to B

(deffunction a-to-b-p ($?question)
	(bind ?response (ask-question ?question a b))
	(return ?response)
)





;;***************************************************
;; function to retract the data template
;;***************************************************

(deffunction retract-data (?data)
	(do-for-fact
		((?p data))
		(eq ?p:data ?data)
		(retract ?p)
	)
)

(deffunction retract-simple (?data)
	(do-for-all-facts
		((?p ?data))
		(retract ?p)
	)
)

;;***************************************************
;; Get cf of certain data
;;***************************************************

(deffunction get-cf-from-data (?data)
	(do-for-fact
		((?p data))
		(eq ?p:data ?data)
		(return ?p:certainty-factor)
	)
	;;(return x)
)

;;*****************************************************
;; Check if the data exists
;;*****************************************************

(deffunction data-exists (?data)
	(return (any-factp
		((?p data))
		(eq ?p:data ?data)
	))
	;;(return FALSE)
)

;;*****************************************************
;; check if fact exists
;;*****************************************************

(deffunction fact-exists (?fact)
	(return (any-factp ((?p ?fact)) TRUE))
)
;;*****************************************************
;; check if we need to reinit the module
;;*****************************************************

(deffunction check-reinit (?data)
	(return 
		(any-factp ((?p data))
			(eq ?p:data ?data)
		)
	)	
)

;;**************************************************
;; gets data on the template slot
;;**************************************************

(deffunction get-template-slot (?template ?slot)
	(do-for-fact
		((?p ?template))
		(not (eq ?p:slot nil))
		(return ?p:slot)
	)
	(return 0)
)


;;******************************************************
;; Addition for conjunctive evidence
;; Note that since we are using sequence expansion
;; we need to call the function
;; set-sequence-operator-recognition to TRUE
;;******************************************************

(deffunction conjunctive-evidence (?first $?rest)
	(return (min ?first $?rest))
)

;;****************************************
;; Addition for disjunctive evidence
;;****************************************

(deffunction disjunctive-evidence (?first $?rest)
	(return (max ?first $?rest))
)

;;************************************************
;; Function to combine certainty factors together
;;************************************************

(deffunction combine-certainty-factor (?cfA ?cfB)
	(if (and (> ?cfA 0) (> ?cfB 0)) then
		(return (+ ?cfA (* ?cfB (- 1 ?cfA))))
	else
		(if (and (< ?cfA 0) (< ?cfA 0)) then
			(return (+ ?cfA (* ?cfB (+ 1 ?cfA))))
		else
			(return
				(/ 
					(+ ?cfA ?cfB)
					(- 1 (min (abs ?cfA) (abs ?cfB)))
				)
			)
		)
	)

)

;;***************************************************
;; this function will attempt to remove cf1 from the 
;; combined cf3
;; unfortunately if the certainty factor is already 1
;; or -1, there is really no way of separating the two
;;***************************************************

(deffunction uncombine-certainty-factor (?cf3 ?cf1)

	;; no way to remove the cf1 from cf3
	;; since cf3 has been totally blotted out
	;; by cf1s certainty
	(if (= ?cf1 1) then
		(return 1)
	)
	(if (= ?cf1 -1) then
		(return -1)
	)

	(if (and (> ?cf3 0) (> ?cf1 0)) then
		(return (/ (- ?cf3 ?cf1) (- 1 ?cf1)))
	else
		(if (and (< ?cf3 0) (< ?cf1 0)) then
			(return (/ (- ?cf3 ?cf1) (+ 1 ?cf1)))
		else
			(if (> ?cf1 0) then
				;;we know that cf2 is less than 0
				(return (/ (- ?cf3 ?cf1) (+ 1 ?cf3)))
			else
				(return (- ?cf3 (* ?cf1 ?cf3) ?cf1))
			)
		)
	)
)

;;*************************************************
;; Method to uncombine the cfs of goal and subgoal
;;**************************************************

(deffunction uncombine-goals (?subgoal ?goal)
	(do-for-fact
		((?p1 data)
		(?p2 data)
		)
		(and 
			(eq ?p1:data ?subgoal)
			(eq ?p2:data ?goal)
		)
		(modify ?p2
			(certainty-factor (uncombine-certainty-factor 
				?p2:certainty-factor 
				?p1:certainty-factor
			))
		)
	)

)


;;*********************************************
;; To handle whenever there are two hypotheses
;;*********************************************

(defrule deal-with-two-hypothesis (declare (salience 10000))
	?p<- (data
		(data ?r)
		(certainty-factor ?cfA)
	)
	?q<- (data
		(data ?r)
		(certainty-factor ?cfB)
	)
	(test (neq ?p ?q))
	=>
	(retract ?q)
	(modify ?p (certainty-factor (combine-certainty-factor ?cfA ?cfB)))
)
	
;;
;; Function to get the choice in the beginning
;; It will only return the choice if the task has been done
;;

(deffunction get-beginning-choice ($?donefield)
	(bind ?count (length$ ?donefield))
	(bind ?input "")
	(while (> (/ ?count 2) 0) do
		(bind ?input  
			(str-cat 
				(integer (/ ?count 2))
				") " 
				(nth$ (- ?count 1) ?donefield)
			)
			" "
			"-"
			" "
			(nth$ ?count ?donefield)
			crlf
			?input
		)
		(bind ?count (- ?count 2))
	)
	(while TRUE do
		(bind ?choice (one-to-n-p (integer (+ (/ (length$ ?donefield) 2) 2))
			"===================================================" crlf
			"Please input which areas you wish for us to help you assess" crlf		
			?input
			(integer (+ (/ (length$ ?donefield) 2) 1)) ") Reset all" crlf
			(integer (+ (/ (length$ ?donefield) 2) 2)) ") Summary Page" crlf
			"===================================================" crlf

		))
		(if (eq (nth$ (* ?choice 2) ?donefield) Done) then
			(if (yes-or-no-p
				"You have already done this choice" crlf
				"Would you like to redo this section? (Y or N)" crlf
			)then
				(return ?choice)
			else
				(if (eq ?choice 0) then
					(return ?choice)
				)
			)
		else
			(return ?choice)
		)		
	)		
)

(defrule combine-evaluation-certainties (declare (salience 10000))
	?obj1 <- (object (is-a Evaluated-Value) (criteria ?m) (cf ?cf1))
	?obj2 <- (object (is-a Evaluated-Value) (criteria ?m) (cf ?cf2))
	(test	(neq ?obj1 ?obj2))
	=>
	(modify-instance ?obj1 (cf (combine-certainty-factor ?cf1 ?cf2)))
	(send ?obj2 delete)
		
)

