# TODOS

* Create integration tests that actually hit LinkedIn's API, the stubbing works well for unit tests, but doesn't help if/when LinkedIn introduces bugs or changes their API. Following methods that need integration tests (there are probably more, but these are what I use right now):
** Client#people-search
*** be sure to test the keywords options and the fields options and that id is always returned no matter what
** Client#people

