#lang racket

(require
    racket/date
    2htdp/batch-io
    net/head
    net/smtp)

; config
(define sender "user@gmail.com")
(define receiver '("user@gmail.com"))
(define password "password")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define date (current-date))
(define title
    (string-append
        "the title at date "
        (~a (date-year date))
        (~a (date-month date) #:min-width 2 #:align 'right #:left-pad-string "0")
        (~a (date-day date) #:min-width 2 #:align 'right #:left-pad-string "0")))
(define header (standard-message-header
                    sender
                    receiver
                    '()
                    '()
                    title))
(define body (read-file "./data/data.txt"))

(smtp-send-message
    "smtp.exmail.qq.com"
    sender
    receiver
    header
    (list body)
    #:auth-user sender
    #:auth-passwd password)

(write-file (string-append "./data/" title) body)