namespace PromptLab.Tests;

public class SlugTests
{
    [Fact]
    public void Create_SimpleTitle_ReturnsLowercaseWithHyphen()
    {
        Assert.Equal("hello-world", Slug.Create("Hello World"));
    }
}
