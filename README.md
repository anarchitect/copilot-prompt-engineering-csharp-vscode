# Prompt engineering with GitHub Copilot in VS Code (C#)

Documentation checked on 23 November 2026 against [VS Code 1.147](https://code.visualstudio.com/updates/v1_147).
Use the VS Code Chat view on Windows with the Copilot harness and .NET 10 (LTS).
Allow about 25 minutes after installing the prerequisites, plus 8 optional minutes.
These are estimates. If a response stalls, use the reference fallback.

You will practise:

1. Showing an example (zero-shot vs one-shot).
2. Stating the goal, examples, constraints, and checks.
3. Generating tests, running them, and repairing code with the exact error.
4. Specifying a useful response format (optional).
5. Reusing project guidance with custom instructions (optional).

| Part | Time |
| --- | --- |
| Setup | 4 min |
| Exercise 1: show an example | 7 min |
| Exercise 2: make a vague prompt specific | 7 min |
| Exercise 3: repair with the exact error | 7 min |
| Optional: improve the response format | 3 min |
| Optional: custom instructions | 5 min |

## The prompt recipe

Use this checklist for every prompt in this exercise. It comes from GitHub's
[prompt engineering guidance](https://docs.github.com/copilot/concepts/prompting-and-context/prompt-engineering).

1. Goal: start with what you want, then list the details. Put important requirements first.
2. Context: attach the files the answer needs.
3. Examples: give sample inputs and outputs, or a sample test.
4. Constraints: say what must not change. Split larger tasks into steps.
5. Check: say how to verify the result, such as "run `dotnet test`". Review it yourself.

---

## Setup (about 4 min)

Install these before the lab:

1. Current stable VS Code, signed in with an account that has GitHub Copilot access. **Help > About** shows the version.
2. A .NET 10 SDK, 10.0.100 or later: <https://dotnet.microsoft.com/download/dotnet/10.0>. Install the latest serviced .NET 10 SDK; a .NET 11 SDK alone does not satisfy this project's `global.json`.
3. The **C# Dev Kit** extension. VS Code recommends it when you open the folder.
4. Git.

> [!NOTE]
> Company account? Ask your admin whether Copilot agents are allowed. Use only this sample code; never paste secrets or customer data into a prompt.

Steps:

1. Clone and open the repository:

   ```powershell
   git clone https://github.com/anarchitect/copilot-prompt-engineering-csharp-vscode.git
   cd copilot-prompt-engineering-csharp-vscode
   code .
   ```

2. Review the sample repository before trusting it. If VS Code asks, select **Yes, I trust the authors** only if you trust this code. Agents can't edit files in Restricted Mode.
3. Open the terminal (`` Ctrl+` ``) and run:

   ```powershell
   dotnet test
   ```

4. Open the Chat view with `Ctrl+Alt+I`. In the chat input, check these controls:

   | Control | Choose |
   | --- | --- |
   | **Session Target** | **Copilot** (not **Cloud** or **Local**) |
   | **Agent** | Each exercise tells you: **Ask** or **Agent** |
   | **Language model** | **Auto**, or any model you have |
   | **Permissions** | **Manual permissions** |

   Keep this setup for every exercise. Copilot works on your local files;
   **Local** names a different, deprecated harness. Review approvals before
   choosing **Allow Once**. Some commands run without a prompt.

   Can't see the agent picker? Select **Add Context → Agent… → Ask**.
   Once selected, click the **Ask** button to switch to **Agent**.
   **Interactive** and **Plan** are separate controls in the mode menu.

> Checkpoint 1: `dotnet test` reports `Passed: 1`. Choose **Copilot** before sending the first chat prompt.

What's in the project:

1. `src/PromptLab/Calculator.cs`: `Add`, `Subtract`, `Multiply`, `Divide` for integers.
2. `src/PromptLab/Slug.cs`: turns a blog title into a URL slug, like `Hello World` → `hello-world`. It has a bug. Don't fix it yet.
3. `tests/PromptLab.Tests`: xUnit tests. You will add more.
4. `solution/`: reference answers, not compiled by `PromptLab.slnx`. Don't attach them to the exercise prompts.

---

## Exercise 1: show an example (about 7 min)

A prompt without an example is zero-shot; one with a single example is one-shot.
Both use your attached code as context. Compare them in Chat before applying edits.

1. Start a new **Ask** chat (`Ctrl+N`, with Chat focused). Attach
   `src/PromptLab/Calculator.cs` and `tests/PromptLab.Tests/CalculatorTests.cs`
   using **Add Context** or the `#` file picker.
2. Send:

   ```text
   Suggest xUnit tests for Calculator.Subtract. Do not edit files.
   ```

3. Note its test style and chosen cases. Do not apply the answer.
   Start another **Ask** chat, attach the same files, and send:

   ```text
   Suggest xUnit tests for Calculator.Subtract. Do not edit files.
   Follow this example's naming and parameterized test style:

   [Theory]
   [InlineData(2, 3, 5)]
   [InlineData(-4, 1, -3)]
   public void Add_ReturnsSum(int a, int b, int expected)
   {
       Assert.Equal(expected, Calculator.Add(a, b));
   }
   ```

4. Compare the responses. Did the example change the style or cases?
   They may already match; one example does not guarantee a different answer.
5. In the second chat, select **Agent** and send:

   ```text
   Add tests for Add, Subtract, Multiply and Divide in
   tests/PromptLab.Tests/CalculatorTests.cs only, using the example's style.
   Include positive and negative inputs, 7 / 2 = 3, and -7 / 2 = -3.
   Use Assert.Throws<DivideByZeroException> for a zero divisor.
   Do not change production code, SlugTests.cs, or dependencies.
   Run dotnet test and report the actual results.
   ```

6. Review the test diff in Chat. In the VS Code terminal, run:

   ```powershell
   git diff -- src/PromptLab
   git diff -- tests/PromptLab.Tests/CalculatorTests.cs
   dotnet test
   ```

> Checkpoint 2: Add, Subtract, Multiply, and Divide have input/output tests. Check integer division (`7 / 2 = 3`, `-7 / 2 = -3`) and an `Assert.Throws<DivideByZeroException>` test for a zero divisor. Use `[Theory]`/`[InlineData]` for multiple input/output cases; an exception test can use `[Fact]`. All tests pass.

If AI is unavailable or you are running out of time, copy [`solution/CalculatorTests.cs`](solution/CalculatorTests.cs) over the exercise test file and run `dotnet test`.
This fallback completes the code checkpoint, not the AI comparison.

If a test fails, compare its expected value with the calculator's documented behavior. Correct an incorrect generated assertion; do not change correct tests merely to get a passing run.

---

## Exercise 2: make a vague prompt specific (about 7 min)

A vague prompt leaves requirements unstated. Tests based on existing behavior can preserve a bug.

1. In the Chat view, start a new chat (`Ctrl+N`). Check **Copilot**, set the agent to **Ask** (read-only), and send:

   ```text
   write tests for slug
   ```

2. Read the answer. Which details came from the repository, and which did Copilot assume? Did it test what `Slug.Create` should do, or what it does today? Don't apply anything.
3. Start a new chat (`Ctrl+N`) and set the agent to **Agent**. Type `#` and choose `src/PromptLab/Slug.cs`, then type `#` again and choose `tests/PromptLab.Tests/SlugTests.cs` (not the copies in `solution/`). Then paste and send:

   ```text
   Add xUnit tests for Slug.Create to tests/PromptLab.Tests/SlugTests.cs.

   Required behaviour (this is the spec, not what the code does today):
   - Return lowercase. Keep only letters a-z and digits 0-9.
   - Replace each run of other characters with a single hyphen.
   - Never start or end with a hyphen.
   - Throw ArgumentNullException for null.

   Examples (title -> slug):
   "Hello World" -> "hello-world"
   "  Hello,   World!  " -> "hello-world"
   "Hello,World" -> "hello-world"
   "C# & .NET 10" -> "c-net-10"
   "Top 10 Tips" -> "top-10-tips"
   "" -> ""
   "!!!" -> ""

   Use one [Theory] with [InlineData] for the examples and a [Fact] for null.
   Keep the existing passing test. Do not add dependencies.
   Step 1 only: change only that test file. Do not change src/PromptLab/Slug.cs, even if tests fail.
   Run dotnet test and tell me which tests fail.
   ```

   Compare this prompt with the recipe: goal, attached files, examples, a file boundary, and a test command.

4. Review and approve the `dotnet test` command if asked. Inspect the diff of `SlugTests.cs` from the response. The experimental editor working set above the chat input offers **Keep** and **Undo** for tracked edits. Edits are already saved; **Keep** clears the pending-review state.
   Also run these commands, because edits made through terminal commands might not appear in that list:

   ```powershell
   git diff -- src/PromptLab/Slug.cs
   git diff -- tests/PromptLab.Tests/SlugTests.cs
   dotnet test
   ```

> Checkpoint 3: The first diff is empty. The second adds the seven examples and the null test without removing the original test. With exactly those tests, there are 3 failures: `"  Hello,   World!  "`, `"Hello,World"` and `"C# & .NET 10"`. Their actual values are `"--hello---world--"`, `"helloworld"` and `"c--net-10"`, respectively.
> If the agent changed production code, undo only that unintended edit. If it generated different tests, compare them with the prompt before expecting the same count.

If AI is unavailable, copy [`solution/SlugTests.cs`](solution/SlugTests.cs) over the exercise test file and run `dotnet test`. Keep the failing tests for the repair step.

---

## Exercise 3: repair with the exact error (about 7 min)

Give Copilot the exact failure text, not "it's broken", and limit what it may change.

1. Before the repair, record the current test-file changes:

   ```powershell
   git diff -- tests/PromptLab.Tests
   dotnet test
   ```

   Copy the failing test names and their `Expected` / `Actual` lines (`Ctrl+C`). Use your actual output, including any additional failures.
2. In the **same** chat (it already knows the task), type this prompt, pasting your failure output where shown:

   ```text
   Step 2: dotnet test fails with:

   <paste the failure output here>

   Fix Slug.Create so all tests pass.
   Change only src/PromptLab/Slug.cs, keep the method signature, and do not edit any tests.
   Run dotnet test and explain the fix in two sentences.
   ```

3. Review any requested actions. Inspect the `Slug.cs` diff and keep it only if it meets the spec.
4. Confirm it yourself:

   ```powershell
   dotnet test
   git diff -- src/PromptLab/Slug.cs
   git diff -- tests/PromptLab.Tests
   ```

> Checkpoint 4: All tests pass. The source diff implements the spec. The test diff is identical to the one you recorded before the repair.
> `git diff` is cumulative from the last commit, so earlier exercise tests should still appear. `git status` alone cannot prove that no tests changed during this step.

If tests still fail, paste the new failure into the same chat and repeat step 2.
If AI is unavailable, copy [`solution/Slug.cs`](solution/Slug.cs) over the exercise source file and rerun the checks. Do not copy or weaken tests during the repair.

---

## Optional: improve the response format (about 3 min)

Use an output contract when you need a reviewable answer, not another code edit.

1. Start a new **Ask** chat. Attach the repaired `src/PromptLab/Slug.cs` and `tests/PromptLab.Tests/SlugTests.cs`. Paste the source diff from Exercise 3 to show the original code, then send `Explain this fix`.
2. Read the answer, then ask it to revise that response:

   ```text
   Rewrite your explanation for a beginner reviewing this repair.
   Return exactly three bullets, in this order:
   - Cause: explain the original bug in one sentence.
   - Change: explain how the repaired code handles separators in one sentence.
   - Check: give the command I should run and one test example with its expected result.
   No code blocks or introductory paragraph. Do not edit files.
   Do not claim you ran tests. If a claim is not supported by the attached files
   or this conversation, say what needs checking instead of inventing evidence.
   ```

3. Check the format and facts against the files. Run `dotnet test` yourself.

> Checkpoint: The answer separates cause, change, and verification. It suggests a check rather than claiming an unobserved test run. A shorter answer is useful only if it remains accurate.

## Optional: write your rules down once (about 5 min)

Custom instructions store reusable project guidance for chat requests.
They do not affect ghost text and do not guarantee compliance.
Existing tests already show a style, so matching that style does not by itself prove the instructions were used.

1. Create `.github/copilot-instructions.md` in the repository root with:

   ```markdown
   # Project guidelines

   - Tests use xUnit. Use [Theory] with [InlineData] for input/output cases, and Assert.Throws for exceptions.
   - When fixing a bug, change production code only. Never edit a test just to make it pass.
   - Explain changes in two or three plain-language sentences; the team is new to C#.
   ```

2. Save it. Run **Chat: Open Customizations** from the Command Palette and select **Instructions** to confirm discovery.
3. Start a new chat (`Ctrl+N`) with **Agent** and send a prompt without repeating the custom instructions:

   ```text
   Add Calculator.Remainder(int a, int b) using C# integer remainder semantics.
   Include positive and negative inputs and a zero divisor. Do not add dependencies.
   Run dotnet test.
   ```

4. Check the response's **References** section for the instructions file, where available. Discovery alone does not prove that guidance was included or followed.

> Checkpoint: Review the changes and run `dotnet test`. Input/output tests should follow the existing theory style. Check `7 % 2 = 1`, `-7 % 2 = -1`, and a `DivideByZeroException` for a zero divisor. Confirm the explanation follows your guidance.

For an offline reference, copy `solution/Calculator.cs` to `src/PromptLab/Calculator.cs` and `solution/RemainderTests.cs` to `tests/PromptLab.Tests/RemainderTests.cs`. Run `dotnet test`. This verifies the implementation, not instruction loading.

---

## Older advice you can skip

You may see these in older Copilot training. In a Copilot harness session, do this instead:

| Older advice | Do this now |
| --- | --- |
| `/fix`, `/tests`, `/explain` | Say it in plain language, for example "Fix this failure and run the tests." Type `/` to see commands available in your session. Use `/plan` when you need a plan. |
| `@workspace` or other `@` participants | Not supported in Copilot harness sessions. Attach files with `#`, or ask and let the agent search. |
| "Output a unified diff only" for an implementation task | Agent can edit files directly. Review the changes with `git diff`. A response format is still useful for explanations and read-only reviews. |
| "Act as a mentor" at the start of every chat | State the audience and desired explanation directly. Optionally put recurring preferences in `.github/copilot-instructions.md`. |
| Ask / Edit / Agent *modes* | Pick **Copilot** as Session Target, then an agent (**Ask**, **Agent**, or `/plan`) and a permission level. |

## Troubleshooting

| Problem | Fix |
| --- | --- |
| No Copilot features | Sign in from the Copilot menu in the Status Bar. |
| **Copilot** missing from Session Target | Update to your organization's current approved VS Code release and check [harness requirements](https://code.visualstudio.com/docs/agents/run/agent-harnesses#_copilot). Ask your admin if access is restricted. |
| Agent can't edit files | Trust the folder: run **Workspaces: Manage Workspace Trust**. |
| `dotnet` or the SDK not found | Install a .NET 10 SDK, then restart VS Code. |
| `warning NU1900` during build | NuGet couldn't retrieve vulnerability data. Check connectivity, proxy configuration, and NuGet feeds; this warning is not evidence that packages are safe. A warnings-as-errors build needs the feed issue resolved. |
| Answers drift or get slow | Start a new chat (`Ctrl+N`) for each new task. |
| Stuck | Compare with the reference answers in [`solution/`](solution). |

## Validate the reference path

Maintainers can run these from a fresh clone with unchanged starter files in PowerShell 7:

```powershell
dotnet build PromptLab.slnx --warnaserror
dotnet test PromptLab.slnx --no-build
.\scripts\Test-Solution.ps1
```

The script uses a disposable copy under `.validation/` and removes it afterwards.
It checks the starter, each core code checkpoint, and the optional remainder implementation separately:

| Reference stage | Passed | Failed | Total |
| --- | --- | --- | --- |
| Starter | 1 | 0 | 1 |
| Exercise 1 | 11 | 0 | 11 |
| Exercise 2 | 16 | 3 | 19 |
| Exercise 3 | 19 | 0 | 19 |
| Optional remainder | 22 | 0 | 22 |

These counts describe the supplied reference tests, not every possible Copilot response.
The checks do not invoke Copilot or verify VS Code controls, response wording, or instruction loading.
The CI workflow runs the build, starter tests, and script on Windows and Linux; the learner steps remain Windows-focused.

A live VS Code 1.147 Chat trial confirmed the Copilot harness, Ask selection,
file attachments, and a read-only test suggestion without file edits.
A recurring Settings modal interrupted further UI automation.
The complete Chat exercise and optional steps are not yet UI-verified.

## Quick reference

| Action | Shortcut |
| --- | --- |
| Open the Chat view | `Ctrl+Alt+I` |
| New chat (Chat view focused) | `Ctrl+N` |
| Attach a file to a chat prompt | Type `#`, or select **Add Context** |
| Command Palette | `Ctrl+Shift+P` |

## Learn more

1. [Prompt engineering for GitHub Copilot](https://docs.github.com/copilot/concepts/prompting-and-context/prompt-engineering)
2. [Use the Chat view](https://code.visualstudio.com/docs/agents/run/chat-view)
3. [Add context to chat](https://code.visualstudio.com/docs/chat/copilot-chat-context)
4. [Use custom instructions](https://code.visualstudio.com/docs/agent-customization/custom-instructions)
5. [AI features cheat sheet](https://code.visualstudio.com/docs/agents/reference/ai-features-cheat-sheet)
6. [Choose an agent harness](https://code.visualstudio.com/docs/agents/run/agent-harnesses)
7. Companion exercise: [Using GitHub Copilot with C# in VS Code](https://github.com/anarchitect/using-github-copilot-with-csharp-vscode)
8. [Review AI-generated code edits](https://code.visualstudio.com/docs/agents/run/review-code-edits)
9. [Manage approvals and permissions](https://code.visualstudio.com/docs/agents/run/approvals)
10. [Plan work with agents](https://code.visualstudio.com/docs/agents/run/planning). Use `/plan` for larger tasks; it is not needed for this small repair. `/research` is a preview limited to VS Code Insiders.
11. [.NET support policy](https://dotnet.microsoft.com/platform/support/policy/dotnet-core)

## Attribution and license

The exercise ideas (zero-shot vs one-shot tests, file context, step-by-step prompts, and generate-test-repair)
are adapted from the demos in [ps-copilot-sandbox/copilot-fundamentals-training](https://github.com/ps-copilot-sandbox/copilot-fundamentals-training)
(MIT, © 2023 Jürgen Efeish), rewritten for C#, .NET 10 and the VS Code Copilot harness, with outdated steps removed.
This repository is licensed under [MIT](LICENSE). It is not an official GitHub or Microsoft publication.
