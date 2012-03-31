# encoding: UTF-8
module Colorize
  def colorize(text, color_code)
    "<p style='color:#{color_code};'>#{text}</p>"
  end

  def red(text) 
    colorize(text, '#FF0000') 
  end

  def green(text) 
    colorize(text, '#00CD00') 
  end

  def debug text
    puts text if $-v
  end
end