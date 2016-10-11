In this experiment, I illustrate one way to improve a pair trading signal for `USDGBP` and the stock `GlaxoSmithKline` listed on **London Stock Exchange** both of which are dominated in sterling. 

Specifically, the cointegration relation

\[\\omega_t=\\log(P^{USDGBP}_t)-\\gamma \\log(P^{GSK}_t) \]

is estimated on separate one-year rolling windows up to two specified dates. I then examine if the the spike in the spread \\(\\omega_t\\) will trigger pair trade.

During first half of the year, although sterling was influenced most strongly on [*24 Febuary*](http://uk.reuters.com/article/uk-britain-eu-poll-idUKKCN0VZ2QI) and *27 June* in 2016. It turned to be that \(\\omega_t\) doesn't exceed the two standard deviation measured from its historical mean. A conservative trader who sets this threshold as his trading rule, will not open a position.

I argue that this fall short occurs not bacause the spread hadn't widen enough on those dates. Rather, it is the constant mean and standard deviation that are inflated as it is estimated globally over  one-year window so they do not capture relevant information over short horizon. 

Instead of rejecting the possiblity of the trading pair, I propose to remedy the problem by applying `change point detection` model as a tool to keep track of changing distributional properties of \(\\omega_t\). To calculate `z-score` in this approach, distance is measured between \(\\omega_t\) and its dynamically changed mean instead of the constant one. An off-the-shelf tool I use to accomplish this purpose is an `r package` [ecp](https://cran.r-project.org/web/packages/ecp/index.html) which is quite a state-of-the-art. 
