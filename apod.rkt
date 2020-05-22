#lang racket/base

(require json
         net/url
         racket/match)

(provide get-apod
         (struct-out apod))

(struct apod
  (title
   date
   explanation
   copyright
   service-version
   media-type
   url
   hdurl))

(define (handle-api-exception exn json)
  (define (exception c m)
    (error (format "API Exception\nError Code: ~a\n\t~a" c m)))
  (cond
    [(hash-has-key? json 'error)
     (let ([error_json (hash-ref json 'error)])
       (exception (hash-ref error_json 'code)
                  (hash-ref error_json 'message)))]
    [(hash-has-key? json 'msg)
     (exception (hash-ref json 'code)
                (hash-ref json 'msg))]))

;Returns the Information/Link of APOD (Astronomy Picture of the Day)
(define (get-apod [date ""] #:api_key [api_key "DEMO_KEY"])
  ;Build API for APOD
  (define api (url "https" #f "api.nasa.gov" #f #t
    (list
     (path/param "planetary" '())
     (path/param "apod" '()))
    ((λ ()
       (match date
         ["" `((api_key . ,api_key))]
         [else
          `((api_key . ,api_key)
            (date    . ,date))]))) #f))
  (define api_json (call/input-url api get-pure-port read-json))
  (when (eof-object? api_json) ;Check for EOF
    (error (format "Error connecting to api.nasa.gov")))

  (with-handlers ([exn:fail:contract? (handle-api-exception exn api_json)])
    (apod
     (hash-ref api_json 'title)
     (hash-ref api_json 'date)
     (hash-ref api_json 'explanation)
     (if (hash-has-key? api_json 'copyright) ;Check for copyright
         (hash-ref api_json 'copyright) null)
     (hash-ref api_json 'service_version)
     (hash-ref api_json 'media_type)
     (hash-ref api_json 'url)
     (hash-ref api_json 'hdurl))))