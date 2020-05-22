#lang scribble/manual

@title{DONKI Solar Flares}

@defproc[(get-solar-flare [dates pair?]
                          [#:api_key       api_key        string? "DEMO_KEY"]) (listof flr?)]{
 Returns list of @racket[flr] within specified date range.
                 
 
 
 @hspace[4] @italic{Dates must be in the form of YYYY-MM-DD.
  (By default, startDate is 30 days ago and endDate is the current date)}
}

@defstruct[flr ([flrID           string?]
                [instruments     (listof flr-instrument?)]
                [beginTime       string?]
                [peakTime        string?]
                [endTime         string?]
                [classType       string?]
                [sourceLocation  string?]
                [activeRegionNum (or/c number? null?)]
                [linkedEvents    (listof string?)]
                [link            string?])]{
 Solar Flare data returned from @racket[get-solar-flare].
}


@defstruct[flr-instrument ([id          number?]
                           [displayName string?])]{
 Instrument used to record Solar Flare data. Found in @racket[flr].
}
