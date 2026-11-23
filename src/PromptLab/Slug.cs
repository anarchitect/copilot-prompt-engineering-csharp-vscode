using System.Text;

namespace PromptLab;

/// <summary>Turns a blog post title into a URL slug.</summary>
public static class Slug
{
    /// <summary>Creates a URL slug such as <c>hello-world</c> from a title.</summary>
    public static string Create(string title)
    {
        ArgumentNullException.ThrowIfNull(title);

        var dashed = title.ToLowerInvariant().Replace(' ', '-');
        var slug = new StringBuilder(dashed.Length);
        foreach (var c in dashed)
        {
            if (char.IsAsciiLetterOrDigit(c) || c == '-')
            {
                slug.Append(c);
            }
        }

        return slug.ToString();
    }
}
