# gems
require 'nokogiri'
require 'watir'
require 'dotenv'
Dotenv.load

# json
require 'json'

# app
require_relative '../../app/counties.rb'
@counties = Counties.new.sample

require_relative '../../app/parties.rb'
@parties = Parties.new.excluded

require_relative '../../app/case_types.rb'
@case_types = CaseTypes.new.excluded

# lib
require_relative '../../lib/prompts.rb'

# hackaround to quiet terminal warnings
$VERBOSE = nil
