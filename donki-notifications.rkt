#lang racket/base

(require "donki.rkt")

(provide get-notifications
         (struct-out notification))

(struct notification
  (messageType
   messageID
   messageURL
   messageIssueTime
   messageBody))

;Returns notifications from the DONKI service
(define (get-notifications [dates (list "" "")] #:api_key [api_key "DEMO_KEY"])
  (let ([api_json (get-donki-json "notifications" dates api_key)])
    (if (eof-object? api_json) null
        (with-handlers ([exn:fail:contract? (handle-donki-exception exn api_json)])
          (for/list ([n api_json])
            (notification
             (hash-ref n 'messageType)
             (hash-ref n 'messageID)
             (hash-ref n 'messageURL)
             (hash-ref n 'messageIssueTime)
             (hash-ref n 'messageBody)))))))
  