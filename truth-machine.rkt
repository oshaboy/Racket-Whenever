#lang s-exp "whenever.rkt"
(clone! 2 (string->number (read-line)))
(defer '(#t) void)
(defer '(1) again '((= (N 2) 2)) displayln (- (N 2) 1))