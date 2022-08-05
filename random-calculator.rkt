#lang s-exp "whenever.rkt"
(clone! 3 (string->number (read-line)))
(clone! 4 (string->number (read-line)))
(defer '(#t) void)
(defer '(#t) void)
(defer '(1 2 (= (N 6) 0)) println (+ (N 3) (N 4) -2))
(defer '(1 2 (= (N 5) 0)) println (- (N 3) (N 4)))