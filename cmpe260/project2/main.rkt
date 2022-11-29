; harun resid ergen
; 2019400141
; compiling: yes
; complete: yes

#lang racket

(provide (all-defined-out))

; 10 points
(define := (lambda (var value) (list var value)))
; 10 points
(define -- (lambda args (list 'let args)))
; 10 points
(define @ (lambda (bindings expr) (append bindings expr)))
; 20 points
(define split_at_delim (lambda (delim args)
  (foldr
    (lambda (element next)
      (cond [(eqv? element delim) (cons '() next)]
            [else(cons (cons element (car next)) (cdr next))]
      )
    )
    (list '()) args
  )
))
; 30 points
(define parse_expr (lambda (lst)
  (if (list? lst)
    ;then
    (if (= (length lst) 1)
      ;then
      (if (list? (first lst))
        ;then
        (if (member ':= (first lst))
          ;then
          (insert-at '() 0 (parse_expr(first lst)))
          ;else
          (parse_expr (first lst))
        )
          ;else
          (first lst)
      )
          ;else
          (map parse_expr(parse lst))
    )
    ;else
    lst
  )
))
(define parse (lambda(sub-expr)
  (cond [(member '+ sub-expr) (insert-at (split_at_delim '+ sub-expr) 0 '+)]
        [else (cond [(member '* sub-expr) (insert-at (split_at_delim '* sub-expr) 0 '*)]
                    [else (cond [(member '-- sub-expr)  (apply -- (remove '() (split_at_delim '-- sub-expr)))]
                                [else (cond [(member '@ sub-expr) (append(apply --(remove '() (split_at_delim '-- (first(apply @ (split_at_delim '@ sub-expr)))))) (second(split_at_delim '@ sub-expr)))]
                                            [else (cond [(member ':= sub-expr) (:= (cadaar(split_at_delim ':= sub-expr))
                                                                                   (cond [(number? (caadr(split_at_delim ':= sub-expr))) (caadr(split_at_delim ':= sub-expr))]
                                                                                         [else (cadar(second(split_at_delim ':= sub-expr)))]
                                                                                   )
                                                                               )
                                                        ]                                                                       
                                                        [else sub-expr]
                                                  )
                                            ]
                                      )
                                ]
                          )
                    ]
              )
        ]
  )
))
 
(define insert-at (lambda (lst pos element)
  (define-values (before after) (split-at lst pos))
  (append before (cons element after))
))
; 20 points
(define eval_expr (lambda (expr)
  (eval(parse_expr expr))
))
