with
        finished_games as (
                select *,
                (((home_score > away_score) and (home_odds < away_odds)) or
                  (home_score < away_score) and (home_odds > away_odds)) as contrary,
                                (case
                                        when day >= 1 and day <= 27 then 'earlseason'
                                        when day >= 28 and day <= 72 then 'midseason'
                                        when day >= 73 and day <= 99 then 'lateseason'
                                        when day >= 100 then 'postseason'
                                        else day::text end) as phase
                        from data.games
                where winning_pitcher_id is not null),
        rounded_games as (
                select
                        day, season, phase,
                        round(home_odds * 100, 0) as home_odds,
                        round(away_odds * 100, 0) as away_odds,
                        round(greatest(home_odds, away_odds) * 100, 0) as max_odds,
                        home_score, away_score,
                        contrary,
                        (case when contrary then 1 else 0 end) as contrary_num
                from finished_games
        )
select
        season, phase,
        count(day) as total_games,
        sum(contrary_num) as contrary_games,
                round(100.0 * sum(contrary_num) / count(day), 0) as contrary_pct
        from rounded_games
        group by season, phase
        order by season, phase asc
