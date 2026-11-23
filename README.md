# Prompt engineering with GitHub Copilot in VS Code (C#)

> **Current as of November 2026:** VS Code 1.146, .NET 10 (LTS), GitHub Copilot with the **Copilot harness**.
> A 30-minute, hands-on exercise for beginners. Local VS Code on Windows only.

You will practise the prompt techniques that still matter most:

1. **Show an example** (zero-shot vs one-shot).
2. **Be specific:** goal, examples, constraints, and how to check.
3. **One step at a time:** generate, test, then repair with the exact error.
4. **Write your rules down once** with custom instructions (bonus).

| Part | Time |
| --- | --- |
| Setup | 4 min |
| Exercise 1: Show an example | 7 min |
| Exercise 2: Make a vague prompt specific | 7 min |
| Exercise 3: Repair with the exact error | 7 min |
| Bonus: Custom instructions | 5 min |

## The prompt recipe

Use this checklist for every prompt in this exercise. It comes from GitHub's
[prompt engineering guidance](https://docs.github.com/copilot/concepts/prompting-and-context/prompt-engineering).

1. **Goal first.** Start with what you want, then list the details. Most important requirements first.
2. **Context.** Open or attach the files that matter. Close the ones that don't.
3. **Examples.** Give sample inputs and outputs, or a sample test.
4. **Constraints.** Say what must *not* change, and do one step at a time.
5. **Check.** Say how to verify the result, such as "run `dotnet test`". Then review it yourself.

---

## Setup (≈4 min)

**You need:**

1. VS Code 1.146 or later, signed in to GitHub Copilot (**Help > About** shows the version).
2. A .NET 10 SDK, 10.0.100 or later: <https://dotnet.microsoft.com/download/dotnet/10.0>.
3. The **C# Dev Kit** extension. VS Code recommends it when you open the folder.
4. Git.

> [!NOTE]
> Company account? Ask your admin whether Copilot agents are allowed. Use only this sample code; never paste secrets or customer data into a prompt.

**Steps:**

1. Clone and open the repository:

   ```powershell
   git clone https://github.com/anarchitect/copilot-prompt-engineering-csharp-vscode.git
   cd copilot-prompt-engineering-csharp-vscode
   code .
   ```

2. If VS Code asks, select **Yes, I trust the authors** (agents can't edit files in Restricted Mode).
3. Open the terminal (`` Ctrl+` ``) and run:

   ```powershell
   dotnet test
   ```

4. Open the Chat view with `Ctrl+Alt+I`. In the chat input, check these controls:

   | Control | Choose |
   | --- | --- |
   | **Session Target** | **Copilot** (the default; don't pick *Local*, which is being retired) |
   | **Agent** | Each exercise tells you: **Ask** or **Agent** |
   | **Language model** | **Auto**, or any model you have |
   | **Permissions** | **Manual permissions** |

> **✅ Checkpoint 1:** `dotnet test` reports **Passed: 1**, and the chat input shows **Copilot** as the Session Target.

**What's in the project:**

1. `src/PromptLab/Calculator.cs`: `Add`, `Subtract`, `Multiply`, `Divide` for whole numbers.
2. `src/PromptLab/Slug.cs`: turns a blog title into a URL slug, like `Hello World` → `hello-world`. **It has a bug.** Don't fix it yet.
3. `tests/PromptLab.Tests`: xUnit tests. You will add more.

---

## Exercise 1: Show an example (≈7 min)

**Technique:** Copilot copies the patterns it can see. A prompt with no example is *zero-shot*; adding one example is *one-shot*.
Ghost text (the dimmed suggestion at your cursor) uses your **open files** as context, so open the right ones.

1. Close all editor tabs. Open `src/PromptLab/Calculator.cs`, then `tests/PromptLab.Tests/CalculatorTests.cs`.
2. **Zero-shot.** In `CalculatorTests.cs`, replace the line `// Exercise 1 starts here.` with this comment, then press `Enter`:

   ```csharp
   // Test Subtract
   ```

3. Wait for the dimmed suggestion. If none appears, open the Command Palette (`Ctrl+Shift+P`) and run **Trigger Inline Suggestion**. Press `Tab` to accept it. Note the style it chose (often a single `[Fact]` with one hard-coded case).
4. Delete the comment and the generated test.
5. **One-shot.** Paste this example test and comment inside the class:

   ```csharp
   [Theory]
   [InlineData(2, 3, 5)]
   [InlineData(-4, 1, -3)]
   public void Add_ReturnsSum(int a, int b, int expected)
   {
       Assert.Equal(expected, Calculator.Add(a, b));
   }

   // Tests for Subtract, Multiply and Divide in the same style as Add_ReturnsSum.
   // Divide is integer division (7 / 2 = 3) and throws DivideByZeroException when b is 0.
   ```

6. Put the cursor at the end of the last comment line and press `Enter`. Accept each suggestion with `Tab`, then press `Enter` for the next one, until all three operations are tested.
   Hover over a suggestion to show its toolbar, where you can step through alternative suggestions.
7. Save (`Ctrl+S`) and run `dotnet test`.

> **✅ Checkpoint 2:** The new tests use `[Theory]` and `[InlineData]` like your example, and `dotnet test` reports **Failed: 0**.
>
> A test failed? Check its expected value. Copilot can guess wrong (for example `7 / 2 = 3.5`); correct it by hand.
> No ghost text at all? Select the comment, press `Ctrl+I`, type `Write these tests`, and press `Enter`.

---

## Exercise 2: Make a vague prompt specific (≈7 min)

**Technique:** A vague prompt makes Copilot guess. Tests written from guesses often lock in today's bugs.

1. In the Chat view, start a new chat (`Ctrl+N`). Check **Copilot**, set the agent to **Ask** (read-only), and send:

   ```text
   write tests for slug
   ```

2. Read the answer. What did Copilot have to guess: the language, the test framework, the rules? Did it test what `Slug.Create` *should* do, or what it does *today*? Don't apply anything.
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
   Step 1 only: change only that test file. Do not change src/PromptLab/Slug.cs, even if tests fail.
   Run dotnet test and tell me which tests fail.
   ```

   This prompt follows the recipe: **goal** (first line), **context** (`#` files), **examples** (the list), **constraints** ("Step 1 only", "Do not change Slug.cs"), and **check** ("Run dotnet test").

4. Approve the `dotnet test` command when asked. Open each file from the changed-files list in the Chat view, review the highlighted edits, and select **Keep** (or **Undo**). Edits are already saved to disk.

> **✅ Checkpoint 3:** `SlugTests.cs` has the new tests, `Slug.cs` is unchanged (`git status`), and the agent reports **3 failing** cases: `"  Hello,   World!  "`, `"Hello,World"` and `"C# & .NET 10"`.
> These failures are good: they are the bug, found by the spec. If the agent changed `Slug.cs`, select **Undo** for that file.

---

## Exercise 3: Repair with the exact error (≈7 min)

**Technique:** Generate, test, repair. Give Copilot the *exact* failure text, not "it's broken", and limit what it may change.

1. In the terminal, run `dotnet test`. Select the three `[FAIL]` lines and their `Expected` / `Actual` lines, and copy them (`Ctrl+C`).
2. In the **same** chat (it already knows the task), type this prompt, pasting your failure output where shown:

   ```text
   Step 2: dotnet test fails with:

   <paste the failure output here>

   Fix Slug.Create so all tests pass.
   Change only src/PromptLab/Slug.cs, keep the method signature, and do not edit any tests.
   Run dotnet test and explain the fix in two sentences.
   ```

3. Approve `dotnet test`. Open `Slug.cs` from the changed-files list in the Chat view, review the edits, then select **Keep**.
4. Confirm it yourself:

   ```powershell
   dotnet test
   git status
   ```

> **✅ Checkpoint 4:** `dotnet test` reports **Failed: 0**. In this step only `Slug.cs` changed; no tests were weakened.
> Still red? Paste the *new* failure into the same chat and repeat step 2.

---

## Bonus: Write your rules down once (≈5 min)

**Technique:** Instead of repeating "use `[Theory]`" or "don't edit tests" in every prompt, put the rules in a custom instructions file. Copilot adds it to chat requests in this repo. It doesn't affect ghost text.

1. Create `.github/copilot-instructions.md` with:

   ```markdown
   # Project guidelines

   - Tests use xUnit. Use [Theory] with [InlineData] for input/output cases, and Assert.Throws for exceptions.
   - When fixing a bug, change production code only. Never edit a test just to make it pass.
   - Explain changes in two or three plain-language sentences; the team is new to C#.
   ```

2. Save it. Optional: run **Chat: Open Customizations** from the Command Palette and select **Instructions** to see it listed.
3. Start a new chat (`Ctrl+N`) with **Agent** and send a short prompt that doesn't mention any rules:

   ```text
   Add Calculator.Remainder(int a, int b) with tests. Run dotnet test.
   ```

> **✅ Checkpoint 5:** Without being told in the prompt, the new tests use `[Theory]`/`[InlineData]` (and `Assert.Throws` for dividing by zero), the explanation is short, and `dotnet test` reports **Failed: 0**.
> Instructions guide Copilot; they don't guarantee it. Always review the result.

---

## Older advice you can skip

You may see these in older Copilot training. In a Copilot harness session, do this instead:

| Older advice | Do this now |
| --- | --- |
| `/fix`, `/tests`, `/explain` | Say it in plain language, for example "Fix this failure and run the tests." Type `/` to see current commands (`/plan`, `/compact`, `/fork`). |
| `@workspace` or other `@` participants | Not supported in Copilot harness sessions. Attach files with `#`, or ask and let the agent search. |
| "Output a unified diff only" or "output code only" | The agent edits files directly. Review its changes with **Keep**/**Undo** in the Chat view and with `git diff`. |
| `Ctrl+Enter` completions panel | Hover over a ghost-text suggestion and use its toolbar to step through alternatives. |
| "Act as a mentor" at the start of every chat | Put lasting preferences in `.github/copilot-instructions.md`. |
| Ask / Edit / Agent *modes* | Pick **Copilot** as Session Target, then an agent (**Ask**, **Agent**, or `/plan`) and a permission level. |

## Troubleshooting

| Problem | Fix |
| --- | --- |
| No Copilot features | Sign in from the Copilot menu in the Status Bar. |
| **Copilot** missing from Session Target | Update VS Code to 1.146 or later, or ask your admin. |
| No ghost text | Run **Trigger Inline Suggestion**, or use `Ctrl+I` with the same comment as the prompt. |
| Agent can't edit files | Trust the folder: run **Workspaces: Manage Workspace Trust**. |
| `dotnet` or the SDK not found | Install a .NET 10 SDK, then restart VS Code. |
| `warning NU1900` during build | NuGet can't reach its vulnerability feed (common on company networks). Safe to ignore here. |
| `Ctrl+I` opens **Ask in Chat** | The file is in a chat session; that's fine, or set `inlineChat.askInChat` to `false`. |
| Answers drift or get slow | Start a new chat (`Ctrl+N`) for each new task. |
| Stuck | Compare with the reference answers in [`solution/`](solution). |

## Quick reference

| Action | Shortcut |
| --- | --- |
| Open the Chat view | `Ctrl+Alt+I` |
| New chat (Chat view focused) | `Ctrl+N` |
| Inline chat in the editor | `Ctrl+I` |
| Accept / dismiss ghost text | `Tab` / `Esc` |
| Accept the next word of ghost text | `Ctrl+Right Arrow` |
| Attach a file to a chat prompt | Type `#`, or select **Add Context** |
| Command Palette | `Ctrl+Shift+P` |

## Learn more

1. [Prompt engineering for GitHub Copilot](https://docs.github.com/copilot/concepts/prompting-and-context/prompt-engineering)
2. [Inline suggestions](https://code.visualstudio.com/docs/editing/ai-powered-suggestions)
3. [Add context to chat](https://code.visualstudio.com/docs/chat/copilot-chat-context)
4. [Use custom instructions](https://code.visualstudio.com/docs/agent-customization/custom-instructions)
5. [AI features cheat sheet](https://code.visualstudio.com/docs/agents/reference/ai-features-cheat-sheet)
6. [Choose an agent harness](https://code.visualstudio.com/docs/agents/run/agent-harnesses)
7. Companion exercise: [Using GitHub Copilot with C# in VS Code](https://github.com/anarchitect/using-github-copilot-with-csharp-vscode)

## Attribution and license

The exercise ideas (zero-shot vs one-shot tests, open-tab context, step-by-step prompts, and generate-test-repair)
are adapted from the demos in [ps-copilot-sandbox/copilot-fundamentals-training](https://github.com/ps-copilot-sandbox/copilot-fundamentals-training)
(MIT, © 2023 Jürgen Efeish), rewritten for C#, .NET 10 and the VS Code Copilot harness, with outdated steps removed.
This repository is licensed under [MIT](LICENSE). It is not an official GitHub or Microsoft publication.
