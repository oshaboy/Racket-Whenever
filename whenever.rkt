#lang racket
(provide (except-out (all-from-out racket) #%module-begin) (rename-out (whenever-module-begin #%module-begin)))

(define-syntax whenever-module-begin
    (syntax-rules () 
        ((_ body ...)
            (#%module-begin
            (letrec 
                (
                    [proglist  (list 'body ...)]
                    [proglen (length proglist)]
                    [how_many_of_each_line (make-vector proglen 1)] 
                    ;The N function returns how many of a line there are.
                    [N (lambda (linenum) 
                        (vector-ref how_many_of_each_line (sub1 linenum)))]
                    ;The clone function takes a linenum and clones it a certain number of times.
                    [clone! (lambda (linenum times)
                        (vector-set! how_many_of_each_line (sub1 linenum) (+ (N linenum) times)))]
                    [ns (module->namespace 'racket)] ;The namespace containing N and clone going into the eval. 
                    [whenever_result (void)]
                    ;This evaluates a cond list 
                    [my-eval (lambda (list)
                        ;it's evaluated twice in order to get rid of the quotes
                        (map (lambda (x) (eval x ns)) (eval list ns))
                    )]
                    ;Gets the list of defer conditions and list of again conditions
                    [get_defer+again_lists+new_line (lambda (line) 
                        (let (
                        [defer_list '()]
                        [again_list '()]
                        [identifier (car line)]
                        [new_line line]
                        )
                        
                        (for ([_ (in-naturals)]
                        #:break (not (or (equal? identifier 'defer)  (equal? identifier 'again))))
                        
                        (cond
                        [(equal? identifier 'defer) (set! defer_list (append defer_list (my-eval (cadr new_line))))]
                        [(equal? identifier 'again) (set! again_list (append again_list (my-eval (cadr new_line))))])
                        (set! new_line (cddr new_line))
                        (set! identifier (car new_line)))

                        (values defer_list again_list new_line)))]
                    ;Check if the current line can run
                    [is_condition_list (lambda (cond_list)
                        (let* (
                        [cond_lines (filter exact-integer? cond_list)]
                        [cond_bools (filter boolean? cond_list)]
                        
                        )
                        (if (ormap identity cond_bools )
                            #t
                            (ormap (lambda (x) (positive? (N x)))  cond_lines)
                        )
                        ))]
                    ;Check if all lines are deferred or executed. 
                    [halt_condition (lambda ()
                        (let (
                            (i 0)
                            (result #t))
                        (for ([line proglist])
                        #:break (not result)
                                (let-values (((defer_list _ __)(get_defer+again_lists+new_line line)))
                                (if (or  (is_condition_list defer_list) (zero? (vector-ref how_many_of_each_line i)))
                                    (void)
                                    (set! result #f))
                                (set! i (add1 i))))
                        result))]
                    ;main execution loop
                    [exec_loop (lambda ()
                        (let* (
                            ;get a random line
                            [linenum (random proglen)]
                            [potential_line (list-ref proglist linenum)]
                            [count_of_line (vector-ref how_many_of_each_line linenum)])
                        (define-values (defer_list again_list new_potential_line) (get_defer+again_lists+new_line potential_line))

                        ;if we're done return
                        (if (halt_condition) 
                        whenever_result
                        ;otherwise check if the line is deferred and avalible. 
                        (begin
                        (if (and (positive? count_of_line) (not (is_condition_list defer_list)))
                        (begin
                            (set! whenever_result (eval new_potential_line ns))
                            (vector-set! how_many_of_each_line linenum (- count_of_line (if (is_condition_list again_list) 0 1))))
                        (void))
                        (exec_loop)))))])
                ;actual code run
                (namespace-set-variable-value! 'N N #f ns)
                (namespace-set-variable-value! 'clone! clone! #f ns)
                (exec_loop))))))

