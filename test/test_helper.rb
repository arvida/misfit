require 'rubygems'
require 'test/unit'
require 'shoulda'
require 'stringio'

class Test::Unit::TestCase
  def project_path
    File.join(File.dirname(__FILE__), '..')
  end
end

module Kernel
  def capture_stdout
    out = StringIO.new
    $stdout = out
    yield
    return out
  ensure
    $stdout = STDOUT
  end
end