#lang scribble/manual

@title{SSD/CNEOS Fireball}

@defproc[(get-fireballs [dates pair?]) (listof fireball)]{
 Returns a list of @racket[fireball] within specified date range.
                   
 @hspace[4] @italic{Dates must be in the form of YYYY-MM-DD, YYYY-MM-DDThh:mm:ss, YYYY-MM-DD_hh:mm:ss or YYYY-MM-DD hh:mm:ss.
  If the date range is left blank, all events will be returned}

  Examples: @codeblock|{
                   (get-fireballs)
                   (get-fireballs (list "2020-01-01" "2020-02-02"))
   }|
}

@defstruct[fireball ([date     (or/c string? null)]
                     [lat      (or/c string? null)]
                     [lon      (or/c string? null)]
                     [lat-dir  (or/c string? null)]
                     [lon-dir  (or/c string? null)]
                     [alt      (or/c number? null)]
                     [vel      (or/c number? null)]
                     [energy   (or/c number? null)]
                     [impact-e (or/c number? null)])]{
 Fireball event data returned from @racket[get-fireballs].
}