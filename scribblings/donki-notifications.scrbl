#lang scribble/manual

@title{DONKI Notification System}

@defproc[(get-notifications [dates pair?]
                            [#:api_key api_key string? "DEMO_KEY"]) (listof notification?)]{
 Returns list of @racket[notification] within specified date range

 @hspace[4] @italic{Dates must be in the form of YYYY-MM-DD.
  (By default, startDate is 7 days ago and endDate is the current date)}
}

@defstruct[notification ([messageType      string?]
                         [messageID        string?]
                         [messageURL       string?]
                         [messageIssueTime string?]
                         [messageBody      string?])]{
 DONKI Notification contents. Returned from @racket[get-notifications]
}