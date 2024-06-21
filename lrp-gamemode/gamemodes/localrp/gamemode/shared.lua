GM.Name = "LocalRP"
GM.Author = "forever512"
GM.Website = "https://github.com/f0rever512"

DeriveGamemode('sandbox')

CreateConVar('lrp_class', 0, FCVAR_ARCHIVE, 'Set class of player')

team.SetUp(0, 'Гражданин', Color(255, 255, 255))
team.SetUp(1, 'Бездомный', Color(90, 35, 25))
team.SetUp(2, 'Офицер полиции', Color(0, 0, 255))
team.SetUp(3, 'Детектив', Color(0, 0, 255))
team.SetUp(4, 'Оперативник спецназа', Color(0, 0, 255))