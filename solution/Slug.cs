using System.Text;

namespace PromptLab;

/// <summary>Turns a blog post title into a URL slug.</summary>
public static class Slug
{
    /// <summary>Creates a URL slug such as <c>hello-world</c> from a title.</summary>
    public static string Create(string title)
    {
        ArgumentNullException.ThrowIfNull(title);

        var slug = new StringBuilder(title.Length);
        var pendingHyphen = false;
        foreach (var c in title.ToLowerInvariant())
        {
            if (!char.IsAsciiLetterOrDigit(c))
            {
                pendingHyphen = true;
                continue;
            }

            if (pendingHyphen && slug.Length > 0)
            {
                slug.Append('-');
            }

            slug.Append(c);
            pendingHyphen = false;
        }

        return slug.ToString();
    }
}
