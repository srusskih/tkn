# encoding: utf-8

center <<-EOS
  \e[1mDjango QuerySets and Managers\e[0m
EOS

section "Выполнение запросов" do

  center <<-EOS
    Squeryset-ы "ленивы"
  EOS

  code <<-EOS, :python
    from django.contrib.auth.models import User  

    qs = User.objects.all()
    qs = qs.filter(superuser=True)
    user_list = list(qs)
  EOS

  code <<-EOS, :python
    from django.contrib.auth.models import User  

    qs = User.objects.all()
    qs = qs.filter(superuser=True)
    user_list = list(qs)
  EOS

  code <<-EOS, :python
    from django.contrib.auth.models import User  

    qs = User.objects.all()
    qs = qs.filter(superuser=True)

    if qs:
      user_list = list(qs)
  EOS

  center <<-EOS
    QuerySet.count()
  EOS

  code <<-EOS, :sql
    SELECT COUNT(*) from auth_user;
  EOS

  code <<-EOS, :python
    from django.contrib.auth.models import User  

    qs = User.objects
    count = qs.count()  # 1
    count = qs.count()  # 2
    count = qs.count()  # 3
  EOS

  center <<-EOS
    Использование в шаблонах
  EOS

  code <<-EOS, :python
    # views.py
    from django.shortcuts import render
    from django.contrib.auth.models import User  

    
    def index(request):
      users = User.objects.all()
      return render(request, 'index.html', {'users': users})
  EOS

  # 2 requests
  code <<-EOS, :html
    <html>
      <head></head>
      <body>
        There are {{ users.count }} users on the site.
        {% for user in users %}
        <ul>
          <li>{{ user }}</li>
        </ul>
        {% endfor %}
      </body>
    </html>
  EOS

  # 1 request
  code <<-EOS, :html
    <html>
      <head></head>
      <body>
        There are {{ users|length }} users on the site.
        {% for user in users %}
        <ul>
          <li>{{ user }}</li>
        </ul>
        {% endfor %}
      </body>
    </html>
  EOS

  center <<-EOS
    QuerySet.iterator()
  EOS

  code <<-EOS, :python
    users = User.objects.all().iterator()

    for user in users:
      print user.get_full_name()
  EOS

  center <<-EOS
    QuerySet.exists()
  EOS

  code <<-EOS, :python
    users = User.objects.all()
    
    if users.exists():
      print "It's works!"
  EOS

  # slow
  code <<-EOS, :python
    users = User.objects.all()
    
    if user in users:
      print "He is there!"
  EOS

  # faster
  code <<-EOS, :python
    users = User.objects.all()
    
    if users.filter(pk=user.pk).exists():
      print "He is there!"
  EOS

  code <<-EOS, :python
    users = User.objects.all()
    
    if users.exists():
      print "They are!"

      for user in users:
        print user.username
  EOS

  code <<-EOS, :python
    users = User.objects.all()
    
    if users:
      print "They are!"

      for user in users:
        print user.username
  EOS

  center <<-EOS
    filter().filter()  
  EOS

  code <<-EOS, :python
    qs = Tournament.objects.filter(teams__title='7 Kings')
    qs = qs.filter(teams__owner_id=2)
  EOS

  code <<-EOS, :sql
    SELECT *
    FROM "tournament_tournament"
      -- 1
      INNER JOIN "tournament_tournament_teams" 
              ON "tournament_tournament"."id" = "tournament_tournament_teams"."tournament_id" 
      -- 2
      INNER JOIN "player_team"
              ON "tournament_tournament_teams"."team_id" = "player_team"."id"
      -- 3
      INNER JOIN "tournament_tournament_teams" T4 
              ON "tournament_tournament"."id" = T4."tournament_id" 
      -- 4
      INNER JOIN "player_team" T5 
              ON T4."team_id" = T5."id" 
    WHERE
      "player_team"."title" = '7 Kings'
      AND T5."owner_id" = 2
  EOS

  code <<-EOS, :python
    qs = (
      Tournament.objects
      .filter(teams__title='7 Kings')
      .filter(teams__owner_id=2)
      .filter(teams__owner__name=100)
    )
  EOS

  code <<-EOS, :sql
    SELECT * 
    FROM "tournaments_tournament"
      -- 1
      INNER JOIN "tournaments_tournament_teams"
              ON "tournaments_tournament"."id" = "tournaments_tournament_teams"."tournament_id"
      -- 2
      INNER JOIN "players_team"
              ON "tournaments_tournament_teams"."team_id" = "players_team"."id"
      -- 3
      INNER JOIN "tournaments_tournament_teams" T4
              ON "tournaments_tournament"."id" = T4."tournament_id"
      -- 4
      INNER JOIN "players_team" T5
              ON T4."team_id" = T5."id"
      -- 5
      INNER JOIN "tournaments_tournament_teams" T7
              ON "tournaments_tournament"."id" = T7."tournament_id"
      -- 6
      INNER JOIN "players_team" T8
              ON T7."team_id" = T8."id"
      -- 7
      INNER JOIN "players_player" T9
              ON T8."owner_id" = T9."id"
    WHERE      
      "players_team"."title" = 7 Kings 
      AND T5."owner_id" = 2
      AND T9."name" = 100 
  EOS

  code <<-EOS, :python
    qs = Tournament.objects.filter(teams__title='7 Kings',
                                   teams__owner_id=2)
  EOS

  code <<-EOS, :sql
    SELECT *
    FROM "tournaments_tournament" 
      INNER JOIN "tournaments_tournament_teams" 
              ON "tournaments_tournament"."id" = "tournaments_tournament_teams"."tournament_id" 
      INNER JOIN "players_team"
              ON "tournaments_tournament_teams"."team_id" = "players_team"."id"  
    WHERE 
      "players_team"."title" = 7 Kings
      AND "players_team"."owner_id" = 2 
  EOS

  center <<-EOS
    QuerySet()._next_is_sticky()
  EOS

  code <<-EOS, :python
    qs = (
      Tournament.objects.all().
        _next_is_sticky().filter(tournamentteam__team__title='7 Kings').
        .filter(tournamentteam__team__owner_id=2)
    )
  EOS

  code <<-EOS, :sql
    SELECT *
    FROM "tournaments_tournament" 
      INNER JOIN "tournaments_tournament_teams" 
              ON "tournaments_tournament"."id" = "tournaments_tournament_teams"."tournament_id" 
      INNER JOIN "players_team"
              ON "tournaments_tournament_teams"."team_id" = "players_team"."id"  
    WHERE 
      "players_team"."title" = 7 Kings
      AND "players_team"."owner_id" = 2 
  EOS

  center <<-EOS
    select_related()
  EOS

  code <<-EOS, :python
    # 1+N запросов
    teams = Teams.objects.all()
    for team in teams:
      print team.owner.name 

    # 1 запрос
    teams = Teams.objects.select_related('owner').all()
    for team in teams:
      print team.owner.name 
  EOS

  center <<-EOS
    prefetch_related()
  EOS

  code <<-EOS, :python
    # 1+N запросов
    players = Player.objects.select_related('team').all()
    for player in players:
      for team in player.teams.all():
        print team.owner

    # 2 запроса
    players = Player.objects.prefetch_related('teams').all()
    for player in players:
      for team in player.teams.all():
        print team.owner

    [{u'sql': u'QUERY = u\'SELECT "players_player"."id", "players_player"."name" 
    FROM "players_player"\' - PARAMS = ()', u'time': u'0.000'},
     {u'sql': u'QUERY = u\'SELECT "players_team"."id", "players_team"."title", "players_team"."owner_id"
    FROM "players_team" WHERE "players_team"."owner_id" IN (%s, %s)\' - PARAMS = (1, 2)', u'time': u'0.000'}]
  EOS
end
