# -*- coding: utf-8 -*- #

module Rouge
  module Lexers
    class Shell < RegexLexer
      title "shell"
      desc "Various shell languages, including sh and bash"

      tag 'shell'
      aliases 'bash', 'zsh', 'ksh', 'sh'
      filenames '*.sh', '*.bash', '*.zsh', '*.ksh',
                '.bashrc', '.zshrc', '.kshrc', '.profile', 'PKGBUILD'

      mimetypes 'application/x-sh', 'application/x-shellscript'

      def self.analyze_text(text)
        text.shebang?(/(ba|z|k)?sh/) ? 1 : 0
      end

      KEYWORDS = %w(
        if fi else while do done for then return function
        select continue until esac elif in
      ).join('|')

      BUILTINS = %w(
        alias bg bind break builtin caller cd command compgen
        complete declare dirs disown echo enable eval exec exit
        export false fc fg getopts hash help history jobs kill let
        local logout popd printf pushd pwd read readonly set shift
        shopt source suspend test time times trap true type typeset
        ulimit umask unalias unset wait
      ).join('|')

      state :basic do
        rule /#.*$/, Comment

        rule /\b(#{KEYWORDS})\s*\b/, Keyword
        rule /\bcase\b/, Keyword, :case

        rule /\b(#{BUILTINS})\s*\b(?!\.)/, Name::Builtin

        rule /^\S*[\$%>#] +/, Generic::Prompt

        rule /(\b\w+)(=)/ do |m|
          groups Name::Variable, Operator
        end

        rule /[\[\]{}()=]/, Operator
        rule /&&|\|\|/, Operator

        rule /<<</, Operator # here-string
        rule /<<-?\s*(\'?)\\?(\w+)\1/ do |m|
          lsh = Str::Heredoc
          token lsh
          heredocstr = Regexp.escape(m[2])

          push do
            rule /\s*#{heredocstr}\s*\n/, lsh, :pop!
            rule /.*?\n/, lsh
          end
        end
      end

      state :double_quotes do
        # NB: "abc$" is literally the string abc$.
        # Here we prevent :interp from interpreting $" as a variable.
        rule /(?:\$#?)?"/, Str::Double, :pop!
        mixin :interp
        rule /[^"`\\$]+/, Str::Double
      end

      state :ansi_string do
        rule /\\./, Str::Escape
        rule /[^\\']+/, Str::Single
        mixin :single_quotes
      end

      state :single_quotes do
        rule /'/, Str::Single, :pop!
        rule /[^']+/, Str::Single
      end

      state :data do
        rule /\s+/, Text
        rule /\\./, Str::Escape
        rule /\$?"/, Str::Double, :double_quotes
        rule /\$'/, Str::Single, :ansi_string

        # single quotes are much easier than double quotes - we can
        # literally just scan until the next single quote.
        # POSIX: Enclosing characters in single-quotes ( '' )
        # shall preserve the literal value of each character within the
        # single-quotes. A single-quote cannot occur within single-quotes.
        rule /'/, Str::Single, :single_quotes

        rule /\*/, Keyword

        rule /;/, Text
        rule /[^=\*\s{}()$"'`\\<]+/, Text
        rule /\d+(?= |\Z)/, Num
        rule /</, Text
        mixin :interp
      end

      state :curly do
        rule /}/, Keyword, :pop!
        rule /:-/, Keyword
        rule /[a-zA-Z0-9_]+/, Name::Variable
        rule /[^}:"`'$]+/, Punctuation
        mixin :root
      end

      state :paren do
        rule /\)/, Keyword, :pop!
        mixin :root
      end

      state :math do
        rule /\)\)/, Keyword, :pop!
        rule %r([-+*/%^|&]|\*\*|\|\|), Operator
        rule /\d+/, Num
        mixin :root
      end

      state :case do
        rule /\besac\b/, Keyword, :pop!
        rule /\|/, Punctuation
        rule /\)/, Punctuation, :case_stanza
        mixin :root
      end

      state :case_stanza do
        rule /;;/, Punctuation, :pop!
        mixin :root
      end

      state :backticks do
        rule /`/, Str::Backtick, :pop!
        mixin :root
      end

      state :interp do
        rule /\\$/, Str::Escape # line continuation
        rule /\\./, Str::Escape
        rule /\$\(\(/, Keyword, :math
        rule /\$\(/, Keyword, :paren
        rule /\${#?/, Keyword, :curly
        rule /`/, Str::Backtick, :backticks
        rule /\$#?(\w+|.)/, Name::Variable
      end

      state :root do
        mixin :basic
        mixin :data
      end
    end
  end
end
