message = {}
message.content = "content"
message.username = ""
message.avatar_url = ""
message.embeds = {{
  author = {
    name = "author name",
    url = "https://discordapp.com",
    icon_url = "https://cdn.discordapp.com/embed/avatars/0.png"
  },
  title = "title",
  url = "https://discordapp.com",
  color = 10547795,
  description = "description",
  thumbnail = {url = "https://cdn.discordapp.com/embed/avatars/0.png"},
  fields = {
    {name="title1",value="text1"},
    {name="title2",value="text2"}
  },
  image = {url = "https://cdn.discordapp.com/embed/avatars/0.png"},
  footer = {icon_url = "https://cdn.discordapp.com/embed/avatars/0.png",text = "footer text"},
  timestamp = "2018-04-01T19:05:02.442Z"
  --timestamp = os.date('%Y-%m-%dT%H:%M:%SZ',tostring(1519828431804):sub(1,-4))
}}
payload = json:encode(message)
print(payload)