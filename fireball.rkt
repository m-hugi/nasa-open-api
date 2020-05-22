#lang racket/base

(require json
         net/url
         racket/list
         racket/match)

(provide get-fireballs
         (struct-out fireball))

(struct fireball
  (date
   lat
   lon
   lat-dir
   lon-dir
   alt
   vel
   energy
   impact-e))

(define (handle-api-exception exn json)
  (when (hash-has-key? json 'code)
    (error (format "Error Code: ~a\n\t~a\n\t~a"
                   (hash-ref json 'code)
                   (hash-ref json 'message)
                   (hash-ref json 'moreInfo)))))

;Returns list of structs containting Fireball events
(define (get-fireballs [dates (list "" "")])
  (define (handle-string-null d) (if (eq? 'null d) null d))
  (define (handle-number-null d)
    (if (eq? 'null d) null
        (let ([result (string->number d)])
          (if (number? result) result null))))
  ;Build Fireball API request
  (define api (url "https" #f "ssd-api.jpl.nasa.gov" #f #t
    (list (path/param "fireball.api" '()))
    ((λ ()
       (match dates
         [(list "" "") `()]
         [else
          `((date-min . ,(list-ref dates 0))
            (date-max . ,(list-ref dates 1)))]))) #f))
  ;Convert API Response to hash table
  (define api_json (call/input-url api get-pure-port read-json))
  (when (eof-object? api_json) ;Check for EOF
    (error "Error connecting to ssd-api.jpl.nasa.gov"))

  ;Convert hash table to struct
  (with-handlers ([exn:fail:contract? (handle-api-exception exn api_json)])
    (unless (string=? (hash-ref api_json 'count) "0")
      (for/list ([f (hash-ref api_json 'data)])
        (fireball
         (handle-string-null (list-ref f 0))  ;date
         (handle-string-null (list-ref f 1))  ;lat
         (handle-string-null (list-ref f 2))  ;lonq
         (handle-string-null (list-ref f 3))  ;lat-dir
         (handle-string-null (list-ref f 4))  ;lon-dir
         (handle-number-null (list-ref f 5))  ;alt
         (handle-number-null (list-ref f 6))  ;vel
         (handle-number-null (list-ref f 7))  ;energy
         (handle-number-null (list-ref f 8))  ;impact-e
        )))))