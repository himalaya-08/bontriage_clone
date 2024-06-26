# -*- coding: utf-8 -*- #

module Rouge
  # @abstract
  # A TemplateLexer is one that accepts a :parent option, to specify
  # which language is being templated.  The lexer class can specify its
  # own default for the parent lexer, which is otherwise defaulted to
  # HTML.
  class TemplateLexer < RegexLexer
    # the parent lexer - the one being templated.
    def parent
      return @parent if instance_variable_defined? :@parent
      @parent = option(:parent) || 'html'
      if @parent.is_a? ::String
        lexer_class = Lexer.find(@parent)
        @parent = lexer_class.new(self.options)
      end
    end

    start { parent.reset! }
  end
end
