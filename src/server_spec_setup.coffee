if typeof window isnt 'undefined'
  root = window
else
  root = global

if !root._spec_setup
  root.chai     = require 'chai'
  root.expect   = chai.expect

  root._spec_setup = true