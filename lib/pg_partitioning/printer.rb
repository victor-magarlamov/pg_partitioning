module PgPartitioning
  module Printer
    COLORS = [GREEN="\e[32m", WHITE="\e[0m", RED="\e[31m"]
  
    def text_color(color)
      print color
    end

    def print_row(mes, color = WHITE)
      text_color color
      print mes + "\n"
      text_color WHITE
    end
    
    def info(mes)
      print_row mes, GREEN
    end
    
    def alert(mes)
      print_row mes, RED
    end
    
    def message(mes)
      print_row mes
    end
  end
end

