namespace PromptLab;

/// <summary>A tiny integer calculator.</summary>
public static class Calculator
{
    /// <summary>Returns <paramref name="a"/> plus <paramref name="b"/>.</summary>
    public static int Add(int a, int b) => a + b;

    /// <summary>Returns <paramref name="a"/> minus <paramref name="b"/>.</summary>
    public static int Subtract(int a, int b) => a - b;

    /// <summary>Returns <paramref name="a"/> times <paramref name="b"/>.</summary>
    public static int Multiply(int a, int b) => a * b;

    /// <summary>
    /// Integer division: the result is rounded toward zero (7 / 2 = 3).
    /// Throws <see cref="DivideByZeroException"/> when <paramref name="b"/> is 0.
    /// </summary>
    public static int Divide(int a, int b) => a / b;
}
