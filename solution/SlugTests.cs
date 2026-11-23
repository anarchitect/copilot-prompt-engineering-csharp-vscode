namespace PromptLab.Tests;

public class SlugTests
{
    [Fact]
    public void Create_SimpleTitle_ReturnsLowercaseWithHyphen()
    {
        Assert.Equal("hello-world", Slug.Create("Hello World"));
    }

    // Generated in Exercise 2 from the examples table.
    [Theory]
    [InlineData("Hello World", "hello-world")]
    [InlineData("  Hello,   World!  ", "hello-world")]
    [InlineData("Hello,World", "hello-world")]
    [InlineData("C# & .NET 10", "c-net-10")]
    [InlineData("Top 10 Tips", "top-10-tips")]
    [InlineData("", "")]
    [InlineData("!!!", "")]
    public void Create_ReturnsExpectedSlug(string title, string expected)
    {
        Assert.Equal(expected, Slug.Create(title));
    }

    [Fact]
    public void Create_Null_ThrowsArgumentNullException()
    {
        Assert.Throws<ArgumentNullException>(() => Slug.Create(null!));
    }
}
