# NCAABasketball
Backtesting a sports betting strategy

This repository reads in NCAA basketball data from several sources and joins them all together. Then a sports betting strategy back test is performed. 

prepare_data.R is a really useful tool for anyone looking at historical NCAA basketball scores and odds. The script brings in score, conference, odds, and rankings data, then masters all the data (through a combination of fuzzyjoin and manual mastering) in order to allow all tables to be joined on each other. This script is up to date for the 2018-2019 season, but may not be maintained in future seasons. 

test_strategy.R uses the mastered data to backtest a specific betting strategy. The strategy in question is to always bet on an unranked home team playing a ranked conference opponent. This script could potentially be tweaked for any number of different NCAA gambling strategies you are looking to backtest.
