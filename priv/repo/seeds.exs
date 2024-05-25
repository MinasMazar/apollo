# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Apollo.Repo.insert!(%Apollo.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

~w[
gemini://gemini.circumlunar.space/
gemini://geminispace.info/
gemini://minasmazar.srht.site/
gemini://tilde.team/~khuxkm/leo/next.cgi?gemini%3A%2F%2Fminasmazar.srht.site%2F
gemini://obspogon.flounder.online/
] |> Enum.map(fn url ->
  Apollo.Repo.insert!(%Apollo.Gemini.Bookmark{url: url})
end)
