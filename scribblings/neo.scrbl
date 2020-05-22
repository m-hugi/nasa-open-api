#lang scribble/manual

@title{NEO (Near Earth Objects)}

@defproc[(get-neos [dates pair?]
                   [#:api_key       api_key        string? "DEMO_KEY"]
                   [#:diameter_unit diameter_unit (one-of/c 'kilometers 'meters 'miles 'feet) 'kilometers]
                   [#:distance_unit distance_unit (one-of/c 'astronomical 'lunar 'kilometers 'miles) 'kilometers]
                   [#:velocity_unit velocity_unit (one-of/c 'kilometers_per_second 'kilometers_per_hour 'miles_per_hour) 'kilometers_per_hour])
         (listof neo?)]{
 Returns list of @racket[neo] within specified date range.
 
 @hspace[4] @italic{Dates must be in the form of YYYY-MM-DD.
  (endDate is default 7 days after startDate)}

  Examples: @codeblock|{
                   (get-neos)
                   (get-neos (list "2020-01-01" ""))
                   (get-neos (list "2020-01-01" "2020-05-05") #:api_key "DEMO_KEY"
                                                              #:diameter_unit 'feet
                                                              #:distance_unit 'miles
                                                              #:velocity_unit 'miles_per_hour)
                   }|
}

@defproc[(get-neo [asteroid_id string?]
                  [#:api_key       api_key        string? "DEMO_KEY"]
                  [#:diameter_unit diameter_unit (one-of/c 'kilometers 'meters 'miles 'feet) 'kilometers]
                  [#:distance_unit distance_unit (one-of/c 'astronomical 'lunar 'kilometers 'miles) 'kilometers]
                  [#:velocity_unit velocity_unit (one-of/c 'kilometers_per_second 'kilometers_per_hour 'miles_per_hour) 'kilometers_per_hour]) (detiled-neo?)]{
 Returns @racket[detailed-neo] for a specific asteroid ID.

 Examples: @codeblock|{
                   (get-neo "3542519")
                   (get-neo "3542519" #:api_key "DEMO_KEY"
                                      #:diameter_unit 'feet
                                      #:distance_unit 'miles
                                      #:velocity_unit 'miles_per_hour)
                   }|
}

@defstruct[neo ([id                     string?]
                [name                   string?]
                [absolute-magnitude-h   number?]
                [estimated-diameter-min number?]
                [estimated-diameter-max number?]
                [potentially-hazardous    bool?]
                [closest-approach     approach?])]{
 Simplified NEO data returned from @racket[get-neos].
}

@defstruct[detailed-neo ([id                     string?]
                         [name                   string?]
                         [absolute-magnitude-h   number?]
                         [estimated-diameter-min number?]
                         [estimated-diameter-max number??]
                         [potentially-hazardous    bool?]
                         [orbital-information     orbit?]
                         [approaches           (listof approach?)])]{
                         
 A more detailed form of @racket[neo] returned by @racket[get-neo].
                         
 Contains a list of @racket[approach] and an orbital information struct @racket[orbit].
}

@defstruct[orbit ([orbit-id                    string?]
                  [orbit-determination-date    string?]
                  [first-observation-date      string?]
                  [last-observation-date       string?]
                  [data-arc-in-days            number?]
                  [observations-used           number?]
                  [orbit-uncertainty           number?]
                  [minimum-orbit-intersection  number?]
                  [jupiter-tisserand-invariant number?]
                  [epoch-osculation            number?]
                  [eccentricity                number?]
                  [semi-major-axis             number?]
                  [inclination                 number?]
                  [ascending-node-longitude    number?]
                  [orbital-period              number?]
                  [perihelion-distance         number?]
                  [perihelion-argument         number?]
                  [aphelion-distance           number?]
                  [perihelion-time             number?]
                  [mean-anomaly                number?]
                  [mean-motion                 number?]                  
                  [equinox                     string?]
                  [orbit-class-type            string?]
                  [orbit-class-description     string?]
                  [orbit-class-range           string?])]{
 Contains extensive orbital information data. Only occurs in @racket[detailed-neo].
}

@defstruct[approach ([close-approach-date string?]
                     [relative-velocity   number?]
                     [miss-distance       number?]
                     [orbiting-body       string?])]{
 Contains close approach data. Occurs in @racket[detailed-neo] and @racket[neo].
}