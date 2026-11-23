# Slug rules

`Slug.Create` returns lowercase ASCII letters and digits.
Replace each run of other characters with one hyphen; trim outer hyphens.
For null, throw `ArgumentNullException`.

| Title | Slug |
| --- | --- |
| `"Hello World"` | `"hello-world"` |
| `"  Hello,   World!  "` | `"hello-world"` |
| `"Hello,World"` | `"hello-world"` |
| `"C# & .NET 10"` | `"c-net-10"` |
| `"Top 10 Tips"` | `"top-10-tips"` |
| `""` | `""` |
| `"!!!"` | `""` |
