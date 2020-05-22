#lang racket/base

(require json
         net/url
         racket/list
         racket/match
         racket/contract)

(provide get-neo
         get-neos
         (struct-out neo)
         (struct-out detailed-neo))

(struct neo ;Less detailed overview of NEO
  (id
   name
   absolute-magnitude-h
   estimated-diameter-min
   estimated-diameter-max
   potentially-hazardous
   closest-approach))

(struct detailed-neo ;NEO with orbital information and all approaches
  (id
   name
   absolute-magnitude-h
   estimated-diameter-min
   estimated-diameter-max
   potentially-hazardous
   orbital-information
   approaches))

(struct approach
  (close-approach-date
   relative-velocity
   miss-distance
   orbiting-body))

(struct orbit
  (orbit-id
   orbit-determination-date
   first-observation-date
   last-observation-date
   data-arc-in-days
   observations-used
   orbit-uncertainty
   minimum-orbit-intersection
   jupiter-tisserand-invariant
   epoch-osculation
   eccentricity
   semi-major-axis
   inclination
   ascending-node-longitude
   orbital-period
   perihelion-distance
   perihelion-argument
   aphelion-distance
   perihelion-time
   mean-anomaly
   mean-motion
   equinox
   orbit-class-type
   orbit-class-description
   orbit-class-range))

(define (handle-api-exception exn json)
  (define (exception c m) (error (format "API Exception\nError Code: ~a\n\t~a" c m)))
  (cond
    [(hash-has-key? json 'error)
     (let ([error_json (hash-ref json 'error)])
       (exception (hash-ref error_json 'code)
                  (hash-ref error_json 'message)))]
    [(hash-has-key? json 'error_message)
     (exception (hash-ref json 'code)
                (hash-ref json 'error_message))]))

;Returns a less detailed overview of NEOs within specified dates
(define/contract (get-neos [dates   (list "" "")]
                           #:api_key       [api_key       "DEMO_KEY"]
                           #:diameter_unit [diameter_unit 'meters]
                           #:distance_unit [distance_unit 'kilometers]
                           #:velocity_unit [velocity_unit 'kilometers_per_hour])
  (->* ()
       (pair?
        #:api_key       string?
        #:diameter_unit (one-of/c 'kilometers 'meters 'miles 'feet)
        #:distance_unit (one-of/c 'astronomical 'lunar 'kilometers 'miles)
        #:velocity_unit (one-of/c 'kilometers_per_second 'kilometers_per_hour 'miles_per_hour))
       (listof neo?))
  ;Build API request
   (define api (url "https" #f "api.nasa.gov" #f #t
     (list
      (path/param "neo" '())
      (path/param "rest" '())
      (path/param "v1" '())
      (path/param "feed" '()))
     ((λ ()
        (match dates
         [(list "" "") `((api_key . ,api_key))]
         [else
          `((api_key . ,api_key)
            (start_date . ,(list-ref dates 0))
            (end_date   . ,(list-ref dates 1)))]))) #f))

  ;Receive API response
  (define api_json (call/input-url api get-pure-port read-json))
  (when (eof-object? api_json) ;Check for EOF
    (error (format "Error connecting to api.nasa.gov")))
  
  (with-handlers ([exn:fail:contract? (handle-api-exception exn api_json)])
    (begin
      ;Convert NEOs from API Response to neo struct
      (define neo_json (hash-ref api_json 'near_earth_objects))
      (flatten
       (for/list ([i (hash-count neo_json)])
         (for/list ([neo_hash (cdr (hash-iterate-pair neo_json i))])
           (let ([esd_hash (hash-ref neo_hash 'estimated_diameter)]
                 [cad_hash (car (hash-ref neo_hash 'close_approach_data))])
             (neo
              (hash-ref neo_hash 'id)
              (hash-ref neo_hash 'name)
              (hash-ref neo_hash 'absolute_magnitude_h)
              (hash-ref (hash-ref esd_hash diameter_unit) 'estimated_diameter_max)
              (hash-ref (hash-ref esd_hash diameter_unit) 'estimated_diameter_min)
              (hash-ref neo_hash 'is_potentially_hazardous_asteroid)
              (approach
               (hash-ref cad_hash 'close_approach_date_full)
               (string->number (hash-ref (hash-ref cad_hash 'relative_velocity) velocity_unit))
               (string->number (hash-ref (hash-ref cad_hash 'miss_distance) distance_unit))
               (hash-ref cad_hash 'orbiting_body))))))))))

;Returns in-depth information for a singular NEO
(define/contract (get-neo asteroid_id
                          #:api_key       [api_key       "DEMO_KEY"]
                          #:diameter_unit [diameter_unit 'kilometers]
                          #:distance_unit [distance_unit 'kilometers]
                          #:velocity_unit [velocity_unit 'kilometers_per_hour])
    (->* (string?)
         (#:api_key       string?
          #:diameter_unit (one-of/c 'kilometers 'meters 'miles 'feet)
          #:distance_unit (one-of/c 'astronomical 'lunar 'kilometers 'miles)
          #:velocity_unit (one-of/c 'kilometers_per_second 'kilometers_per_hour 'miles_per_hour))
         detailed-neo?)
   ;Build API request
   (define api (url "https" #f "api.nasa.gov" #f #t
     (list
      (path/param "neo" '())
      (path/param "rest" '())
      (path/param "v1" '())
      (path/param "neo" '())
      (path/param asteroid_id '()))
     `((api_key     . ,api_key)) #f))

  ;Receive API response
  (define api_json (call/input-url api get-pure-port read-json))
  (when (eof-object? api_json) ;Check for EOF
    (error (format "Invalid Asteroid ID: ~a\n\tor Error connecting to api.nasa.gov" asteroid_id)))
  
  (with-handlers ([exn:fail:contract? (handle-api-exception exn api_json)])
    (begin
      (let* ([esd_json (hash-ref api_json 'estimated_diameter)]
             [orb_json (hash-ref api_json 'orbital_data)]
             [orc_json (hash-ref orb_json 'orbit_class)])
        (detailed-neo
         (hash-ref api_json 'id)
         (hash-ref api_json 'name)
         (hash-ref api_json 'absolute_magnitude_h)
         (hash-ref (hash-ref esd_json diameter_unit) 'estimated_diameter_max)
         (hash-ref (hash-ref esd_json diameter_unit) 'estimated_diameter_min)
         (hash-ref api_json 'is_potentially_hazardous_asteroid)
         (orbit ;Get detailed orbital information
          (hash-ref orb_json 'orbit_id)
          (hash-ref orb_json 'orbit_determination_date)
          (hash-ref orb_json 'first_observation_date)
          (hash-ref orb_json 'last_observation_date)
          (hash-ref orb_json 'data_arc_in_days)
          (hash-ref orb_json 'observations_used)
          (string->number (hash-ref orb_json 'orbit_uncertainty))
          (string->number (hash-ref orb_json 'minimum_orbit_intersection))
          (string->number (hash-ref orb_json 'jupiter_tisserand_invariant))
          (string->number (hash-ref orb_json 'epoch_osculation))
          (string->number (hash-ref orb_json 'eccentricity))
          (string->number (hash-ref orb_json 'semi_major_axis))
          (string->number (hash-ref orb_json 'inclination))
          (string->number (hash-ref orb_json 'ascending_node_longitude))
          (string->number (hash-ref orb_json 'orbital_period))
          (string->number (hash-ref orb_json 'perihelion_distance))
          (string->number (hash-ref orb_json 'perihelion_argument))
          (string->number (hash-ref orb_json 'aphelion_distance))
          (string->number (hash-ref orb_json 'perihelion_time))
          (string->number (hash-ref orb_json 'mean_anomaly))
          (string->number (hash-ref orb_json 'mean_motion))
          (hash-ref orb_json 'equinox)
          (hash-ref orc_json 'orbit_class_type)
          (hash-ref orc_json 'orbit_class_description)
          (hash-ref orc_json 'orbit_class_range))
         ;Convert close_approach_data to a list of structs
         (flatten
          (for/list ([h (hash-ref api_json 'close_approach_data)])
            (approach
             (hash-ref h 'close_approach_date_full)
             (string->number (hash-ref (hash-ref h 'relative_velocity) velocity_unit))
             (string->number (hash-ref (hash-ref h 'miss_distance) distance_unit))
             (hash-ref h 'orbiting_body)))))))))