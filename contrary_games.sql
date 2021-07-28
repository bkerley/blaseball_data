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
                        round(
                                (case when home_odds > away_odds
                                        then home_odds else away_odds end) * 100, 0) as max_odds,
                        home_score, away_score,
                        contrary,
                        (case when contrary then 1 else 0 end) as contrary_num
                from finished_games
        )
select
        max_odds,
        count(day) as total_games,
        sum(contrary_num) as contrary_games,
                round(100.0 * sum(contrary_num) / count(day), 0) as contrary_pct
        from rounded_games
        group by max_odds
        order by max_odds asc
