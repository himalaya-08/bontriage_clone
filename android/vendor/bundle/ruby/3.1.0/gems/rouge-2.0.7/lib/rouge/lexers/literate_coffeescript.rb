# -*- coding: utf-8 -*- #

module Rouge
  module Lexers
    class LiterateCoffeescript < RegexLexer
      tag 'literate_coffeescript'
      title "Literate CoffeeScript"
      desc 'Literate coffeescript'
      aliases 'litcoffee'
      filenames '*.litcoffee'

      def markdown
        @markdown ||= Markdown.new(options)
      end

      def coffee
        @coffee ||= Coffeescript.new(options)
      end

      start { markdown.reset!; coffee.reset! }

      state :root do
        rule /^(    .*?\n)+/m do
          delegate coffee
        end

        rule /^([ ]{0,3}(\S.*?|)\n)*/m do
          delegate markdown
        end
      end
    end
  end
end
