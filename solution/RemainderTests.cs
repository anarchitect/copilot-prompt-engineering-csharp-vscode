namespace PromptLab.Tests;

public class RemainderTests
{
    [Theory]
    [InlineData(7, 2, 1)]
    [InlineData(-7, 2, -1)]
    public void Remainder_ReturnsRemainder(int a, int b, int expected)
    {
        Assert.Equal(expected, Calculator.Remainder(a, b));
    }

    [Fact]
    public void Remainder_ByZero_Throws()
    {
        Assert.Throws<DivideByZeroException>(() => Calculator.Remainder(1, 0));
    }
}
