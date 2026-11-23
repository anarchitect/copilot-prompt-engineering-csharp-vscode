# Project guidelines

- Tests use xUnit. Use [Theory] with [InlineData] for input/output cases, and Assert.Throws for exceptions.
- When fixing a bug, change production code only. Never edit a test just to make it pass.
- Explain changes in two or three plain-language sentences; the team is new to C#.
