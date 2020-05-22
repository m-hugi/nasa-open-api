#lang scribble/manual


@require[(for-label racket/base
                    nasa-open-api)]

@title{NASA Open API}
@author+email["Michiah Hugi" "mhugijr@outlook.com"]

@defmodule[nasa-open-api]

This module provides an interface to a handufl of NASA's Open APIs.

Note: It is recommended that you sign up for a NASA API Key. By default, "DEMO_KEY" is used and is limited in requests.

@hspace[4] @italic{More information can be found at @hyperlink["https://api.nasa.gov/" "api.nasa.gov"]}

@include-section["apod.scrbl"]
@include-section["fireball.scrbl"]
@include-section["neo.scrbl"]
@include-section["cme.scrbl"]
@include-section["donki-notifications.scrbl"]
@include-section["solar-flare.scrbl"]

