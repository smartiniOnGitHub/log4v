# Change Log

## [0.1.0](https://github.com/smartiniOnGitHub/log4v/releases/tag/0.1.0) (unreleased)
Summary Changelog:
- Doc: First release, with minimal set of features
- Doc: add initial documentation
- Feature: initial implementation (using buffered channel) to log only to system out; 
  note that some public definitions here are used from V integrated logging (log module), 
  for better reuse/consistency
- Feature: set a log format, fixed for now (all in the same row/line): 
  [logger name or context/application name, optional | ] 
  log level | current timestamp in ISO format | message
  Example: `log4v | 2022-01-13 14:52:03.451 | INFO  | info message`.
  Note that escaping of separator char, newlines, etc are not done at the moment.
  To change that format, provide your own function of type `LogFormatter`.
- Feature: if built with debug info (compile option `-cg` or `-g`), 
  a statistic of total number of logged messages is kept
- Feature: add some examples to show usage in multi-thread console application 
  and in a vweb application; show interoperability with v log module 
  and performances, using v log module as reference/baseline
- Test: perform white box testing (testing even some internal details, 
  from the same module)

----
