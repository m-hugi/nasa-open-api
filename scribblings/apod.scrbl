#lang scribble/manual

@title{APOD (Astronomy Picture of the Day)}

@defproc[(get-apod [date string?]
                   [#:api_key api_key string? "DEMO_KEY"]) (listof apod?)]{
 Returns data for APOD of specified date
 @hspace[4] @italic{(Date must be in format YYYY-MM-DD).}
}

@defstruct[apod ([title           string?]
                 [date            string?]
                 [explanation     string?]
                 [copyright       (or/c string? null?)]
                 [service-version string?]
                 [media-type      string?]
                 [url             string?]
                 [hdurl           string?])]{
 APOD data. Returned by @racket[get-apod].
}