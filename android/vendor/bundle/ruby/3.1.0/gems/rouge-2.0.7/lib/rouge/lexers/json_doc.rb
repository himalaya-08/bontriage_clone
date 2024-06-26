# -*- coding: utf-8 -*- #

module Rouge
  module Lexers
    load_lexer 'json.rb'

    class JSONDOC < JSON
      desc "JavaScript Object Notation with extenstions for documentation"
      tag 'json-doc'

      prepend :root do
        rule %r(//.*?$), Comment::Single
        rule /(\.\.\.)/, Comment::Single
      end
    end
  end
end
