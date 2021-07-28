with
        finished_games as (
                select *,
                (((home_score > away_score) and (home_odds < away_odds)) or
                  (home_score < away_score) and (home_odds > away_odds)) as contrary,
                                (case
                                        when day >= 0 and day <= 26 then 'earlseason'
                                        when day >= 27 and day <= 71 then 'midseason'
                                        when day >= 72 and day <= 98 then 'lateseason'
                                        when day >= 99 then 'postseason'
                                        else day::text end) as phase,
                                (case
                                        when day >= 0 and day <= 26 then 1
                                        when day >= 27 and day <= 71 then 2
                                        when day >= 72 and day <= 98 then 3
                                        when day >= 99 then 100
                                        else 666 end) as phase_num,
                    round(greatest(home_odds, away_odds) * 100, 0) as max_odds
                        from data.games
                where winning_pitcher_id is not null),
        rounded_games as (
                select
                        day, season, phase, phase_num,
                        round(home_odds * 100, 0) as home_odds,
                        round(away_odds * 100, 0) as away_odds,
                                                max_odds,
                        home_score, away_score,
                        contrary,
                        (case when contrary then 1 else 0 end) as contrary_num,
                                                (case
                                                        when contrary then max_odds - 50
                                                        else 0 end) as contrary_points
                from finished_games
        )
select
        phase,
        count(day) as total_games,
        sum(contrary_num) as contrary_games,
        round(100.0 * sum(contrary_num) / count(day), 0) as contrary_pct,
                sum(contrary_points) as total_contrary_points
        from rounded_games
        group by phase, phase_num
        order by phase_num asc
