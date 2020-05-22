#lang racket/base

(require json
         net/url
         racket/match)

;Shared functions for DONKI (Database Of Notifications, Knowlege, Information) API
(provide get-donki-json
         handle-donki-exception)


(define (handle-donki-exception exn json)
  (when (and (hash? json) (hash-has-key? json 'error))
    (let ([err (hash-ref json 'error)])
      (error (format "Error Code: ~a\n~a\n"
                     (hash-ref err 'code)
                     (hash-ref err 'message))))))

(define (get-donki-json api_type dates api_key)
  ;Build specified API request
  (define api (url "https" #f "api.nasa.gov" #f #t
    (list
     (path/param "DONKI" '())
     (path/param api_type '()))
    ((λ ()
       (match dates
         [(list "" "") `((api_key . ,api_key))]
         [else
          `((api_key   .  ,api_key)
            (startDate . ,(list-ref dates 0))
            (endDate   . ,(list-ref dates 1)))]))) #f))
  (call/input-url api get-pure-port read-json))