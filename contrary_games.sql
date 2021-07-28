with
        finished_games as (
                select *,
                (((home_score > away_score) and (home_odds < away_odds)) or
                  (home_score < away_score) and (home_odds > away_odds)) as contrary
                        from data.games
                where winning_pitcher_id is not null),
        rounded_games as (
                select
                        day, season,
                        round(home_odds * 100, 0) as home_odds,
                        round(away_odds * 100, 0) as away_odds,
                        home_score, away_score,
                        contrary
                from finished_games
        )
select
        day,
        count(day) as total_games,
        count(case when contrary is true then 1 else 0 end) as contrary_games
        from rounded_games
        group by day
        order by day asc
