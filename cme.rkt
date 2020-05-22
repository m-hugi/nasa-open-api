#lang racket/base

(require "donki.rkt")

(provide get-cmes
         (struct-out cme)
         (struct-out cme-instrument)
         (struct-out cmeAnalysis)
         (struct-out enlil)
         (struct-out impact))

(struct cme
  (activityID
   catalog
   startTime
   sourceLocation
   activeRegionNum
   link
   note
   instruments
   cmeAnalyses))

(struct cme-instrument
  (id
   displayName))

(struct cmeAnalysis
  (time21-5
   latitude
   longitude
   halfAngle
   speed
   type
   isMostAccurate
   note
   levelofData
   link
   enlilList))

(struct enlil
  (modelCompletionTime
   au
   estimatedShockArrivalTime
   estimatedDuration
   rmin-re
   kp-18
   kp-90
   kp-135
   kp-180
   isEarthGB
   link
   cmeIDs
   impactList))

(struct impact
  (isGlancingBlow
   location
   arrivalTime))

;Returns data from DONKI CME (Coronal Mass Ejection) Analysis
(define (get-cmes [dates (list "" "")] #:api_key [api_key "DEMO_KEY"])
  (define (handle-bool b) (if (eq? b 'true) #t #f))
  (define (handle-null n) (if (eq? n 'null) null n))
  
  (let ([api_json (get-donki-json "CME" dates api_key)])
    (if (eof-object? api_json) null
        (with-handlers ([exn:fail:contract? (handle-donki-exception exn api_json)])
          (for/list ([c api_json])
            (cme
             (hash-ref c 'activityID)
             (hash-ref c 'catalog)
             (hash-ref c 'startTime)
             (hash-ref c 'sourceLocation)
             (handle-null (hash-ref c 'activeRegionNum))
             (hash-ref c 'link)
             (hash-ref c 'note)
             (for/list ([i (hash-ref c 'instruments)])
               (cme-instrument
                (hash-ref i 'id)
                (hash-ref i 'displayName)))
             (let ([cmea_hash (hash-ref c 'cmeAnalyses)])
               (if (eq? cmea_hash 'null) null ;Check if cmeAnalyses exists
                   (for/list ([ca cmea_hash])
                     (cmeAnalysis
                      (hash-ref ca 'time21_5)
                      (hash-ref ca 'latitude)
                      (hash-ref ca 'longitude)
                      (hash-ref ca 'halfAngle)
                      (hash-ref ca 'speed)
                      (hash-ref ca 'type)
                      (handle-bool (hash-ref ca 'isMostAccurate))
                      (hash-ref ca 'note)
                      (hash-ref ca 'levelOfData)
                      (hash-ref ca 'link)
                      (let ([ca_hash (hash-ref ca 'enlilList)])
                        (if (eq? ca_hash 'null) null ;Check if enlilList exists
                            (for/list ([e (hash-ref ca 'enlilList)])
                              (enlil
                               (hash-ref e 'modelCompletionTime)
                               (hash-ref e 'au)
                               (handle-null (hash-ref e 'estimatedShockArrivalTime))
                               (handle-null (hash-ref e 'estimatedDuration))
                               (handle-null (hash-ref e 'rmin_re))
                               (handle-null (hash-ref e 'kp_18))
                               (handle-null (hash-ref e 'kp_90))
                               (handle-null (hash-ref e 'kp_135))
                               (handle-null (hash-ref e 'kp_180))
                               (handle-bool (hash-ref e 'isEarthGB))
                               (hash-ref e 'link)
                               (handle-null (hash-ref e 'cmeIDs))
                               (let ([im_hash (hash-ref e 'impactList)])
                                 (if (eq? im_hash 'null) null ;Check if impactList exists
                                     (for/list ([im im_hash])
                                       (impact
                                        (handle-bool (hash-ref im 'isGlancingBlow))
                                        (hash-ref im 'location)
                                        (hash-ref im 'arrivalTime)))))))))))))))))))