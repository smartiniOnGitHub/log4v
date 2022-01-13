# Change Log

## [0.1.0](https://github.com/smartiniOnGitHub/log4v/releases/tag/0.1.0) (unreleased)
Summary Changelog:
- Doc: First release, with minimal set of features
- Doc: add initial documentation
- Feature: initial implementation (using unbuffered channel); 
  note that some public definitions here are used from V integrated logging (log module), 
  for better reuse/consistency
- Feature: set a log format, fixed for now (all in the same row/line): 
  [logger name or context/application name, optional | ] 
  log level | current timestamp in ISO format | message
  Example: `log4v | INFO  | 2022-01-13 14:52:03.451 | info message`.
  Note that escaping of separator char, newlines, etc are not done at the moment.
  To change that format, provide your own function of type `LogFormatter`.
- Test: perform white box testing (testing even some internal details, 
  from the same module)

----
