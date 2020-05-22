#lang scribble/manual

@title{DONKI CME (Coronal Mass Ejections)}

@defproc[(get-cmes [dates pair?]
                   [#:api_key api_key string? "DEMO_KEY"]) (listof cme?)]{
 Returns list of @racket[cmeAnalysis] within specified date range.
 
 @hspace[4] @italic{Dates must be in the form of YYYY-MM-DD.
  (By default, startDate is 30 days ago and endDate is the current date)}

 Examples: @codeblock|{
                 (get-cmes)
                 (get-cmes (list "2020-01-01" ""))
                 (get-cmes #:api_key "DEMO_KEY")
   }|
}


@defstruct[cme ([activityID      string?]
                [catalog         string?]
                [startTime       string?]
                [sourceLocation  string?]
                [activeRegionNum (or/c number? null?)]
                [link            string?]
                [note            string?]
                [instruments     (listof cme-instrument?)]
                [cmeAnalyse      (or/c (listof cmeAnalysis?) null?)])]{
 CME event data returned from @racket[get-cmes]. Contains lists of @racket[cme-instrument] and @racket[cmeAnalysis].                             
}

@defstruct[cme-instrument ([id          number?]
                           [displayName string?])]{
 Instrument used to record CME data. Found in @racket[cme].
}

@defstruct[cmeAnalysis ([time21-5        string?]
                        [latitude        number?]
                        [longitude       number?]
                        [halfAngle       number?]
                        [speed           number?]
                        [type            string?]
                        [isMostAccurate boolean?]
                        [note            string?]
                        [levelofData     number?]
                        [link            string?]
                        [enlilList      (or/c (listof enlil?) null?)])]{
 CME Analysis data. Found in @racket[cme].
}

@defstruct[enlil ([modelCompletionTime       string?]
                  [au                        number?]
                  [estimatedShockArrivalTime (or/c string? null?)]
                  [estimatedDuration         (or/c number? null?)]
                  [rmin-re                   (or/c number? null?)]
                  [kp-18                     (or/c number? null?)]  
                  [kp-90                     (or/c number? null?)]  
                  [kp-135                    (or/c number? null?)]
                  [kp-180                    (or/c number? null?)]
                  [isEarthGB                 boolean?]
                  [link                      string?]
                  [cmeIDs                    (listof string?)]
                  [impactList                (or/c (listof impact?) null?)])]{
 Enlil data. Found in @racket[cmeAnalysis].
}

@defstruct[impact ([isGlancingBlow boolean?]
                   [location        string?]
                   [arrivalTime     string?])]{
 Instrument used to record impact data. Found in @racket[enlil].
}