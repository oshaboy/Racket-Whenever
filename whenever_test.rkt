#lang s-exp "whenever.rkt"
(displayln 1)
(displayln 2)
(displayln 3)
(defer '(1 (+ 2) (+ 3)) clone! 4 2)
(defer '(1 2 3 4) displayln 4)
(defer '(1 (+ 1 1) 3 4 5) displayln (N 2))
;(display "result is ")
;(displayln result)