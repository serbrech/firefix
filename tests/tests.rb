require 'test/unit'
require '../src/firefix.rb'

class Tests < Test::Unit::TestCase
  def test_excluded_folders
    assert_equals true, false
  end
end