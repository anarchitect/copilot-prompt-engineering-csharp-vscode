namespace PromptLab.Tests;

public class CalculatorTests
{
    // One-shot example from Exercise 1.
    [Theory]
    [InlineData(2, 3, 5)]
    [InlineData(-4, 1, -3)]
    public void Add_ReturnsSum(int a, int b, int expected)
    {
        Assert.Equal(expected, Calculator.Add(a, b));
    }

    // Tests for Subtract, Multiply and Divide in the same style as Add_ReturnsSum
    [Theory]
    [InlineData(5, 3, 2)]
    [InlineData(3, 5, -2)]
    public void Subtract_ReturnsDifference(int a, int b, int expected)
    {
        Assert.Equal(expected, Calculator.Subtract(a, b));
    }

    [Theory]
    [InlineData(4, 3, 12)]
    [InlineData(-2, 3, -6)]
    public void Multiply_ReturnsProduct(int a, int b, int expected)
    {
        Assert.Equal(expected, Calculator.Multiply(a, b));
    }

    [Theory]
    [InlineData(6, 3, 2)]
    [InlineData(7, 2, 3)]
    [InlineData(-7, 2, -3)]
    public void Divide_ReturnsQuotient(int a, int b, int expected)
    {
        Assert.Equal(expected, Calculator.Divide(a, b));
    }

    [Fact]
    public void Divide_ByZero_Throws()
    {
        Assert.Throws<DivideByZeroException>(() => Calculator.Divide(1, 0));
    }
}
