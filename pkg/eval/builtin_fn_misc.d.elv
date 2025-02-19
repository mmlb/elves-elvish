# Accepts arbitrary arguments and options and does exactly nothing.
#
# Examples:
#
# ```elvish-transcript
# ~> nop
# ~> nop a b c
# ~> nop &k=v
# ```
#
# Etymology: Various languages, in particular NOP in
# [assembly languages](https://en.wikipedia.org/wiki/NOP).
fn nop {|&any-opt= @value| }

# Output the kinds of `$value`s. Example:
#
# ```elvish-transcript
# ~> kind-of lorem [] [&]
# ▶ string
# ▶ list
# ▶ map
# ```
#
# The terminology and definition of "kind" is subject to change.
fn kind-of {|@value| }

# Output a function that takes no arguments and outputs `$value`s when called.
# Examples:
#
# ```elvish-transcript
# ~> var f = (constantly lorem ipsum)
# ~> $f
# ▶ lorem
# ▶ ipsum
# ```
#
# The above example is equivalent to simply `var f = { put lorem ipsum }`;
# it is most useful when the argument is **not** a literal value, e.g.
#
# ```elvish-transcript
# ~> var f = (constantly (uname))
# ~> $f
# ▶ Darwin
# ~> $f
# ▶ Darwin
# ```
#
# The above code only calls `uname` once when defining `$f`. In contrast, if
# `$f` is defined as `var f = { put (uname) }`, every time you invoke `$f`,
# `uname` will be called.
#
# Etymology: [Clojure](https://clojuredocs.org/clojure.core/constantly).
fn constantly {|@value| }

# Calls `$fn` with `$args` as the arguments, and `$opts` as the option. Useful
# for calling a function with dynamic option keys.
#
# Example:
#
# ```elvish-transcript
# ~> var f = {|a &k1=v1 &k2=v2| put $a $k1 $k2 }
# ~> call $f [foo] [&k1=bar]
# ▶ foo
# ▶ bar
# ▶ v2
# ```
fn call {|fn args opts| }

# Output what `$command` resolves to in symbolic form. Command resolution is
# described in the [language reference](language.html#ordinary-command).
#
# Example:
#
# ```elvish-transcript
# ~> resolve echo
# ▶ <builtin echo>
# ~> fn f { }
# ~> resolve f
# ▶ <closure 0xc4201c24d0>
# ~> resolve cat
# ▶ <external cat>
# ```
fn resolve {|command| }

# Evaluates `$code`, which should be a string. The evaluation happens in a
# new, restricted namespace, whose initial set of variables can be specified by
# the `&ns` option. After evaluation completes, the new namespace is passed to
# the callback specified by `&on-end` if it is not nil.
#
# The namespace specified by `&ns` is never modified; it will not be affected
# by the creation or deletion of variables by `$code`. However, the values of
# the variables may be mutated by `$code`.
#
# If the `&ns` option is `$nil` (the default), a temporary namespace built by
# amalgamating the local and upvalue scopes of the caller is used.
#
# If `$code` fails to parse or compile, the parse error or compilation error is
# raised as an exception.
#
# Basic examples that do not modify the namespace or any variable:
#
# ```elvish-transcript
# ~> eval 'put x'
# ▶ x
# ~> var x = foo
# ~> eval 'put $x'
# ▶ foo
# ~> var ns = (ns [&x=bar])
# ~> eval &ns=$ns 'put $x'
# ▶ bar
# ```
#
# Examples that modify existing variables:
#
# ```elvish-transcript
# ~> var y = foo
# ~> eval 'set y = bar'
# ~> put $y
# ▶ bar
# ```
#
# Examples that creates new variables and uses the callback to access it:
#
# ```elvish-transcript
# ~> eval 'var z = lorem'
# ~> put $z
# compilation error: variable $z not found
# [ttz 2], line 1: put $z
# ~> var saved-ns = $nil
# ~> eval &on-end={|ns| set saved-ns = $ns } 'var z = lorem'
# ~> put $saved-ns[z]
# ▶ lorem
# ```
#
# Note that when using variables from an outer scope, only those
# that have been referenced are captured as upvalues (see [closure
# semantics](language.html#closure-semantics)) and thus accessible to `eval`:
#
# ```elvish-transcript
# ~> var a b
# ~> fn f {|code| nop $a; eval $code }
# ~> f 'echo $a'
# $nil
# ~> f 'echo $b'
# Exception: compilation error: variable $b not found
# [eval 2], line 1: echo $b
# Traceback: [... omitted ...]
# ```
fn eval {|code &ns=$nil &on-end=$nil| }

# Imports a module, and outputs the namespace for the module.
#
# Most code should use the [use](language.html#importing-modules-with-use)
# special command instead.
#
# Examples:
#
# ```elvish-transcript
# ~> echo 'var x = value' > a.elv
# ~> put (use-mod ./a)[x]
# ▶ value
# ```
fn use-mod {|use-spec| }

# Shows the given deprecation message to stderr. If called from a function
# or module, also shows the call site of the function or import site of the
# module. Does nothing if the combination of the call site and the message has
# been shown before.
#
# ```elvish-transcript
# ~> deprecate msg
# deprecation: msg
# ~> fn f { deprecate msg }
# ~> f
# deprecation: msg
# [tty 19], line 1: f
# ~> exec
# ~> deprecate msg
# deprecation: msg
# ~> fn f { deprecate msg }
# ~> f
# deprecation: msg
# [tty 3], line 1: f
# ~> f # a different call site; shows deprecate message
# deprecation: msg
# [tty 4], line 1: f
# ~> fn g { f }
# ~> g
# deprecation: msg
# [tty 5], line 1: fn g { f }
# ~> g # same call site, no more deprecation message
# ```
fn deprecate {|msg| }

# Output all IP addresses of the current host.
#
# This should be part of a networking module instead of the builtin module.
#doc:show-unstable
fn -ifaddrs { }
