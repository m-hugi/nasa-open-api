#lang racket/base

(require "donki.rkt"
         racket/match)

(provide get-solar-flares
         (struct-out flr)
         (struct-out flr-instrument))

(struct flr
  (flrID
   instruments
   beginTime
   peakTime
   endTime
   classType
   sourceLocation
   activeRegionNum
   linkedEvents ;List of activityIDs
   link))

(struct flr-instrument
  (id
   displayName))

;Returns details on Solar Flare events
(define (get-solar-flares [dates (list "" "")] #:api_key [api_key "DEMO_KEY"])
  (let ([api_json (get-donki-json "FLR" dates api_key)])
    (if (eof-object? api_json) null
      (with-handlers ([exn:fail:contract? (handle-donki-exception exn api_json)])
        (for/list ([f api_json])
          (flr
           (hash-ref f 'flrID)
           (for/list ([i (hash-ref f 'instruments)])
             (flr-instrument
              (hash-ref i 'id)
              (hash-ref i 'displayName)))
           (hash-ref f 'beginTime)
           (hash-ref f 'peakTime)
           (hash-ref f 'endTime)
           (hash-ref f 'classType)
           (hash-ref f 'sourceLocation)
           (let ([arn (hash-ref f 'activeRegionNum)])
             (if (eq? arn 'null) null arn))
           (let ([le_hash (hash-ref f 'linkedEvents)])
             (if (eq? le_hash 'null) null ;Check for linkedEvents
                 (for/list ([a (hash-ref f 'linkedEvents)])
                   (hash-ref a 'activityID))))
           (hash-ref f 'link)))))))